import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';

import 'services/calculator_service.dart';
import 'viewmodels/sessions_view_model.dart';
import 'views/main_menu_page.dart';
import 'lifecycle_handler.dart';

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
        ChangeNotifierProvider<SessionsViewModel>(
          create: (context) =>
              SessionsViewModel(context.read<CalculatorService>()),
        ),
      ],
      child: OKToast( // 👈 enables toast overlay
        child: const LifecycleHandler(
          child: MaterialApp(
            title: 'MVVM Calculator',
            debugShowCheckedModeBanner: false,
            home: MainMenuPage(),
          ),
        ),
      ),
    );
  }
}
