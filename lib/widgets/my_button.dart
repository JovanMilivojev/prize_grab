import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final textColor = isPrimary ? Colors.white : const Color(0xFF1D5DFF);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shadowColor: Colors.black26,
          backgroundColor: isPrimary ? const Color(0xFFE40018) : Colors.white,
          foregroundColor: textColor,
          shape: const StadiumBorder(),
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
