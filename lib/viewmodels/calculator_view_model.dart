import 'package:flutter/foundation.dart';
import '../services/calculator_service.dart';

class CalculatorViewModel extends ChangeNotifier {
  CalculatorViewModel(this._service);

  final CalculatorService _service;

  String _display = '0';
  String _current = '0';
  String? _operator;
  double? _accumulator;
  bool _nextStartsFresh = false;
  String? _error;

  String get display => _error ?? _display;

  // Input handlers
  void inputDigit(String digit) {
    if (_error != null) _clearError();
    if (_nextStartsFresh) {
      _current = digit == '0' ? '0' : digit;
      _nextStartsFresh = false;
    } else {
      _current = (_current == '0') ? digit : (_current + digit);
    }
    _display = _current;
    notifyListeners();
  }

  void inputDot() {
    if (_error != null) _clearError();
    if (_nextStartsFresh) {
      _current = '0.';
      _nextStartsFresh = false;
    } else if (!_current.contains('.')) {
      _current = '$_current.';
    }
    _display = _current;
    notifyListeners();
  }

  void toggleSign() {
    if (_error != null) _clearError();
    if (_current.startsWith('-')) {
      _current = _current.substring(1);
    } else if (_current != '0') {
      _current = '-$_current';
    }
    _display = _current;
    notifyListeners();
  }

  void backspace() {
    if (_error != null) _clearError();
    if (_nextStartsFresh) return;
    if (_current.length <= 1 || (_current.length == 2 && _current.startsWith('-'))) {
      _current = '0';
    } else {
      _current = _current.substring(0, _current.length - 1);
    }
    _display = _current;
    notifyListeners();
  }

  void clearAll() {
    _accumulator = null;
    _operator = null;
    _current = '0';
    _display = '0';
    _error = null;
    _nextStartsFresh = false;
    notifyListeners();
  }

  void setOperator(String op) {
    if (_error != null) _clearError();
    try {
      final currentVal = double.parse(_current);
      if (_accumulator == null) {
        _accumulator = currentVal;
      } else if (_operator != null && !_nextStartsFresh) {
        // Chain: perform pending operation first
        _accumulator = _service.evaluate(_accumulator!, _operator!, currentVal);
      }
      _operator = op;
      _current = _formatNumber(_accumulator!);
      _display = _current;
      _nextStartsFresh = true;
      notifyListeners();
    } catch (e) {
      _setError('Error');
    }
  }

  void equals() {
    if (_error != null) _clearError();
    if (_operator == null || _accumulator == null) return;
    try {
      final b = double.parse(_current);
      final result = _service.evaluate(_accumulator!, _operator!, b);
      _accumulator = null;
      _operator = null;
      _current = _formatNumber(result);
      _display = _current;
      _nextStartsFresh = true;
      notifyListeners();
    } on FormatException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Error');
    }
  }

  // Helpers
  String _formatNumber(double n) {
    // Trim trailing .0 and keep up to 12 significant digits
    final s = n.toStringAsPrecision(12);
    final normalized = double.parse(s).toString();
    return normalized;
  }

  void _setError(String msg) {
    _error = msg;
    _display = msg;
    _nextStartsFresh = true;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    _display = _current;
  }
}
