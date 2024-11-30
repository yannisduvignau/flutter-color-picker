import 'package:flutter/material.dart';

Widget input({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required Color currentColor,
  required Color textColor,
  required Color borderColor,
  bool? isPasswordInput = false, // Défaut à `false`
  ValueChanged<String>? onChanged
}) {
  return Container(
    decoration: BoxDecoration(
      color: currentColor.withOpacity(1),
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: textColor.withOpacity(1),
          blurRadius: 0,
          offset: const Offset(4, 3),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isPasswordInput ?? false,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: textColor),
        labelText: hintText,
        labelStyle: TextStyle(color: textColor.withOpacity(0.85)),
        filled: true,
        fillColor: currentColor,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 3.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    ),
  );
}
