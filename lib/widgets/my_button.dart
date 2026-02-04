import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isIcy = false,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isIcy;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isPrimary
        ? const Color(0xFF4FC3F7)
        : (isIcy ? const Color(0xFFEAF6FF) : Colors.white);

    final Color textColor = isPrimary ? Colors.white : const Color(0xFF2E5E7A);

    final Color borderColor = isPrimary
        ? const Color(0xFF81D4FA)
        : const Color(0xFFCFEAFF);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: isPrimary ? 12 : 6,
          shadowColor: Colors.black26,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: StadiumBorder(
            side: BorderSide(color: borderColor, width: 1.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
