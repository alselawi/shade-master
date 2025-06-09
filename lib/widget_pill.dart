import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  final String label;
  final VoidCallback onClose;
  final Color? color;

  const Pill({super.key, required this.label, required this.onClose, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.black38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: c.withValues(blue: c.b + 30, red: c.r + 30, green: c.g + 30),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
