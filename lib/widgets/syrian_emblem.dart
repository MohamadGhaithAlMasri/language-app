import 'package:flutter/material.dart';

class SyrianEmblem extends StatelessWidget {
  final double size;
  const SyrianEmblem({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size * 1.4,
      width: size * 1.8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/logo_3_14.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
