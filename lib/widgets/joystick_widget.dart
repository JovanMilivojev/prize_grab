import 'package:flutter/material.dart';

class JoystickWidget extends StatelessWidget {
  const JoystickWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFB3E5FC).withOpacity(0.55),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF90CAF9), width: 2),
      ),
      child: Center(
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFBBD7FF), width: 2),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 6),
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
