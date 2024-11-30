import 'package:flutter/material.dart';

Widget button({
  required String label,
  required Color themeColor,
  required Color borderColor,
  required Color textColor,
  required VoidCallback onPressed,
  required IconData icon,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: themeColor,
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: textColor.withOpacity(1),
          blurRadius: 0,
          offset: const Offset(4, 3),
        ),
      ],
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: textColor, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
