import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
import '../viewmodels/calculator_view_model.dart';
import '../widgets/calc_button.dart';
import '../viewmodels/sessions_view_model.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  final String sessionId;
  final String sessionTitle;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalculatorViewModel>();
    final sessionsVm = context.watch<SessionsViewModel>();

      final buttons = [
      'C', '±', '⌫', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '−',
      '1', '2', '3', '+',
      '0', '.', '='
      ];

    return Scaffold(
      appBar: AppBar(
        title: Text(sessionTitle),
        actions: [
          IconButton(
            tooltip: 'Send result to another calculator',
            onPressed: () => _pickTargetAndSend(context, sessionsVm),
            icon: const Icon(Icons.send),
          ),
          IconButton(
            tooltip: 'Rename',
            onPressed: () => _renameDialog(context),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Close session',
            onPressed: () {
              context.read<SessionsViewModel>().removeSession(sessionId);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  alignment: Alignment.bottomRight,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    vm.display,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
            ),
            _Keyboard(
              buttons: buttons,
              onTap: (label) {
                switch (label) {
                  case 'C':
                    vm.clearAll();
                    break;
                  case '±':
                    vm.toggleSign();
                    break;
                  case '⌫':
                    vm.backspace();
                    break;
                  case '+':
                  case '−':
                  case '×':
                  case '÷':
                    vm.setOperator(label);
                    break;
                  case '=':
                    vm.equals();
                    break;
                  case '.':
                    vm.inputDot();
                    break;
                  default:
                    vm.inputDigit(label);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTargetAndSend(
      BuildContext context, SessionsViewModel sessionsVm) async {
    // Build a list of other sessions to send to
    final others = sessionsVm.sessions.where((s) => s.id != sessionId).toList();

    if (others.isEmpty) {
      showToast("No other calculators open", position: ToastPosition.bottom);
      return;
    }

    final selectedId = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Send result to…'),
        children: [
          for (final s in others)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, s.id),
              child: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );

    if (selectedId == null) return;

    final ok =
        sessionsVm.transferValue(fromId: sessionId, toId: selectedId);
    if (ok) {
      final targetTitle = sessionsVm.byId(selectedId)?.title ?? 'Calculator';
      showToast('Sent to "$targetTitle"', position: ToastPosition.bottom);
    } else {
      showToast('Failed to send', position: ToastPosition.bottom);
    }
  }

  void _renameDialog(BuildContext context) {
    final sessionsVm = context.read<SessionsViewModel>();
    final current = sessionsVm.byId(sessionId)?.title ?? sessionTitle;
    final controller = TextEditingController(text: current);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename calculation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) {
            sessionsVm.renameSession(sessionId, v);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              sessionsVm.renameSession(sessionId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({
    required this.buttons,
    required this.onTap,
  });

  final List<String> buttons;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: buttons.length,
          itemBuilder: (context, index) {
            final label = buttons[index];
            final isPrimary = ['+', '−', '×', '÷', '='].contains(label);

            return CalcButton(
              label: label,
              onPressed: () => onTap(label),
              isPrimary: isPrimary,
            );
          },
        ),
      ),
    );
  }
}

