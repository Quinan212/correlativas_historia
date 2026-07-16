import 'package:flutter/material.dart';

class Insignia extends StatelessWidget {
  final String text;
  final Color border;
  final Color bg;
  final Color fg;
  const Insignia(
      {super.key,
      required this.text,
      required this.border,
      required this.bg,
      required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(text,
          style:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
