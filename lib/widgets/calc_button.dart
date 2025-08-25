import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  const CalcButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isLarge = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isPrimary ? scheme.primary : scheme.surfaceVariant;
    final fg = isPrimary ? scheme.onPrimary : scheme.onSurfaceVariant;

    return SizedBox(
      height: isLarge ? 56 : 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          elevation: 1,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
