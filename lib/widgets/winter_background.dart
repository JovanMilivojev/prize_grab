import 'package:flutter/material.dart';

class WinterBackground extends StatelessWidget {
  const WinterBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.18,
    this.imagePath = 'assets/images/PrizeGrabBG.png',
  });

  final Widget child;
  final double overlayOpacity;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pozadinska slika
        Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),

        //Overlay
        Positioned.fill(
          child: Container(
            color: const Color(0xFFB3E5FC).withOpacity(overlayOpacity),
          ),
        ),

        // Sadrzaj ekrana
        SafeArea(child: child),
      ],
    );
  }
}
