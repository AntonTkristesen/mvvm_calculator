import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const height = 430.0;
          return SizedBox(
            width: width,
            height: height,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              children: buttons.map((label) {
                final isPrimary = ['+', '−', '×', '÷', '='].contains(label);
                final isWideZero = label == '0';
                if (isWideZero) {
                  return GridTile(
                    child: GridTileBar(
                      title: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CalcButton(
                              label: '0',
                              onPressed: () => onTap('0'),
                              isPrimary: false,
                              isLarge: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalcButton(
                              label: '.',
                              onPressed: () => onTap('.'),
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CalcButton(
                              label: '=',
                              onPressed: () => onTap('='),
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return CalcButton(
                  label: label,
                  onPressed: () => onTap(label),
                  isPrimary: isPrimary,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
