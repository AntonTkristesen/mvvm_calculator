import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

/// A lifecycle wrapper that shows "Welcome" on cold start
/// and "Welcome back" when app resumes from background.
class LifecycleHandler extends StatefulWidget {
  final Widget child;
  const LifecycleHandler({super.key, required this.child});

  @override
  State<LifecycleHandler> createState() => _LifecycleHandlerState();
}

class _LifecycleHandlerState extends State<LifecycleHandler>
    with WidgetsBindingObserver {
  bool _welcomeShown = false;
  bool _wasBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Cold start: wait one frame, then show "Welcome".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_welcomeShown) {
        _welcomeShown = true;
        _toast('Welcome');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _wasBackground = true;
    }
    if (state == AppLifecycleState.resumed) {
      if (_welcomeShown && _wasBackground) {
        _wasBackground = false;
        _toast('Welcome back');
      }
    }
  }

  void _toast(String msg) {
    showToast(
      msg,
      position: ToastPosition.bottom,
      duration: const Duration(seconds: 7),
      radius: 12,
      textPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
