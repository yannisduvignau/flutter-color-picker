import 'package:flutter/material.dart';

enum MessageType { success, error, warning, maintenance}

void pushNotificationMessage({
  required BuildContext context,
  required String message,
  required MessageType type,
}) {
  IconData icon;
  Color backgroundColor;
  Color textColor;

  // Choisir l'icône, la couleur de fond et la couleur du texte en fonction du type de message
  switch (type) {
    case MessageType.success:
      icon = Icons.check_circle_rounded;
      backgroundColor = Colors.green;
      textColor = Colors.white;
      break;
    case MessageType.error:
      icon = Icons.error_outline;
      backgroundColor = Colors.red;
      textColor = Colors.white;
      break;
    case MessageType.warning:
      icon = Icons.warning_amber_rounded;
      backgroundColor = Colors.orange;
      textColor = Colors.black;
      break;
    case MessageType.maintenance:
      icon = Icons.design_services_rounded;
      backgroundColor = Colors.grey;
      textColor = Colors.black;
      break;
  }

  // Affichage de la SnackBar avec le message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor, // Fond du message
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor), // Icône correspondant au type
          const SizedBox(width: 10), // Espacement entre l'icône et le texte
          Text(
            message,
            style: TextStyle(color: textColor), // Couleur du texte
          ),
        ],
      ),
    ),
  );
}
