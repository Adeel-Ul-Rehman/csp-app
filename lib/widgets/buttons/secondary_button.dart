// lib/widgets/buttons/secondary_button.dart
import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDanger;
  final bool isFullWidth;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDanger = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDanger ? AppColors.accentRed : AppColors.primaryBlue,
        side: BorderSide(
          color: isDanger ? AppColors.accentRed : AppColors.primaryBlue,
          width: 1.5,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      child: Text(text),
    );
  }
}