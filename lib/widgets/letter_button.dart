// lib/widgets/letter_button.dart

import 'package:flutter/material.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final VoidCallback? onTap;

  const LetterTile({
    super.key,
    required this.letter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => print('Tapped on letter: $letter'),
      child: SizedBox(
        width: 70,
        height: 80,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}