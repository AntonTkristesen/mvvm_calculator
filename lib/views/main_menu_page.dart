import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sessions_view_model.dart';
import '../viewmodels/calculator_view_model.dart';
import 'calculator_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionsVm = context.watch<SessionsViewModel>();
    final sessions = sessionsVm.sessions;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculator — Main Menu')),
      body: sessions.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = sessions[i];
                return Dismissible(
                  key: ValueKey(s.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Close session?'),
                            content: Text('Close "${s.title}" and discard its state?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Close')),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) => sessionsVm.removeSession(s.id),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.38),
                    title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('Created ${s.createdAt}'),
                    leading: const Icon(Icons.calculate),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () => _openSession(context, s.id),
                    onLongPress: () => _renameDialog(context, s.id, s.title),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final title = await _titleDialog(context);
          final newSession = sessionsVm.createSession(title: title);
          // ignore: use_build_context_synchronously
          _openSession(context, newSession.id);
        },
        icon: const Icon(Icons.add),
        label: const Text('New calculator'),
      ),
    );
  }

  Future<String?> _titleDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Name this calculation (optional)'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., Budget, Homework #2…'),
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Skip')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Create')),
        ],
      ),
    );
  }

  void _openSession(BuildContext context, String id) {
    final sessionsVm = context.read<SessionsViewModel>();
    final s = sessionsVm.byId(id);
    if (s == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<CalculatorViewModel>.value(
          value: s.vm, // Pass the existing VM instance for this session
          child: CalculatorPage(sessionId: s.id, sessionTitle: s.title),
        ),
      ),
    );
  }

  void _renameDialog(BuildContext context, String id, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename calculation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) {
            context.read<SessionsViewModel>().renameSession(id, v);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<SessionsViewModel>().renameSession(id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              'No calculations yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap “New calculator” to start a session. Each one has its own state.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
