class CalculatorService {
  double evaluate(double a, String operator, double b) {
    switch (operator) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) throw const FormatException('Division by zero');
        return a / b;
      default:
        throw const FormatException('Unknown operator');
    }
  }
}
