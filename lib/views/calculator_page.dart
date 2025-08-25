import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_view_model.dart';
import '../widgets/calc_button.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

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
      appBar: AppBar(title: const Text('MVVM Calculator')),
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
    // 4 columns grid, with "0" spanning two columns
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = 430.0;
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
