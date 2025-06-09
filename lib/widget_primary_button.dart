import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final IconData icon;

  const PrimaryButton({
    required this.onPressed,
    required this.title,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white), // Subtle icon
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0078D4), // Fluent UI primary color
        foregroundColor: Colors.white, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2), // Sharper corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0, // Fluent UI buttons are usually flat
      ),
    );
  }
}
