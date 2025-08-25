import 'package:flutter/foundation.dart';
import '../services/calculator_service.dart';
import 'calculator_view_model.dart';

class CalcSession {
  CalcSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.vm,
  });

  final String id;
  String title;
  final DateTime createdAt;
  final CalculatorViewModel vm;
}

class SessionsViewModel extends ChangeNotifier {
  SessionsViewModel(this._service);

  final CalculatorService _service;

  final Map<String, CalcSession> _sessions = {};
  List<CalcSession> get sessions =>
      _sessions.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  CalcSession createSession({String? title}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final vm = CalculatorViewModel(_service);
    final session = CalcSession(
      id: id,
      title: (title ?? '').trim().isNotEmpty ? title!.trim() : 'Calculation $id',
      createdAt: DateTime.now(),
      vm: vm,
    );
    _sessions[id] = session;
    notifyListeners();
    return session;
  }

  void renameSession(String id, String newTitle) {
    final s = _sessions[id];
    if (s == null) return;
    final t = newTitle.trim();
    if (t.isEmpty) return;
    s.title = t;
    notifyListeners();
  }

  void removeSession(String id) {
    _sessions.remove(id);
    notifyListeners();
  }

  CalcSession? byId(String id) => _sessions[id];

  // ----------------------
  // Result transfer between sessions
  // ----------------------

  /// Transfers the *current value* from `fromId` to the target session `toId`.
  /// Returns true if both sessions exist and the value was applied.
  bool transferValue({required String fromId, required String toId}) {
    final from = _sessions[fromId];
    final to = _sessions[toId];
    if (from == null || to == null) return false;

    final value = from.vm.exportValue();
    to.vm.applyExternalValue(value);
    // No notifyListeners() needed—the target VM notifies its own listeners.
    return true;
  }
}
