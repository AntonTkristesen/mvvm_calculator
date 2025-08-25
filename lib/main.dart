import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/calculator_view_model.dart';
import 'services/calculator_service.dart';
import 'views/calculator_page.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CalculatorService>(create: (_) => CalculatorService()),
        ChangeNotifierProvider<CalculatorViewModel>(
          create: (context) => CalculatorViewModel(context.read<CalculatorService>()),
        ),
      ],
      child: MaterialApp(
        title: 'MVVM Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const CalculatorPage(),
      ),
    );
  }
}
