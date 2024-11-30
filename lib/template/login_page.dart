import 'package:color_picker/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:color_picker/template/register_page.dart';
import 'package:flutter/material.dart';
import 'package:color_picker/widgets/button_widget.dart';
import 'package:color_picker/widgets/input_widget.dart';
import 'package:color_picker/widgets/notification_widget.dart';

class LoginPage extends StatefulWidget {
  final Color currentColor;
  final Color borderColor;
  final Color textColor;

  const LoginPage({
    super.key,
    required this.currentColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _authService.loginWithEmail(email, password, context);

    // Check if the widget is still mounted
    if (!mounted) return;

    if (user != null) {
      pushNotificationMessage(
        context: context,
        message: 'CONNECTED WITH SUCCESS',
        type: MessageType.success,
      );
      Navigator.pop(context);
    } else {
      pushNotificationMessage(
        context: context,
        message: 'INVALID USER OR PASSWORD',
        type: MessageType.error,
      );
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.currentColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icône de retour
          onPressed: () {
            Navigator.pop(context); // Retour à la page précédente
          },
          color: widget.textColor, // Couleur personnalisée de l'icône
        ),
      ),
      body: Container(
        color: widget.currentColor, // Couleur de fond
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 180.0, 30.0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 25, color: widget.textColor),
                ),
              ),
              const SizedBox(height: 30),
              input(
                  controller: _emailController,
                  hintText: 'EMAIL',
                  icon: Icons.person,
                  currentColor: widget.currentColor,
                  textColor: widget.textColor,
                  borderColor: widget.borderColor),
              const SizedBox(height: 20),
              input(
                  controller: _passwordController,
                  hintText: 'PASSWORD',
                  icon: Icons.password_outlined,
                  currentColor: widget.currentColor,
                  textColor: widget.textColor,
                  borderColor: widget.borderColor,
                  isPasswordInput: true),
              const SizedBox(height: 30),
              // Row pour aligner les boutons sur la même ligne
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                button(
                  label: 'LOGIN',
                  themeColor: widget.currentColor,
                  borderColor: widget.borderColor,
                  textColor: widget.textColor,
                  onPressed: _login,
                  icon: Icons.login,
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    _navigateToPage(RegisterPage(
                      currentColor: widget.currentColor,
                      borderColor: widget.borderColor,
                      textColor: widget.textColor,
                    ));
                  },
                  child: Text('REGISTER',
                      style: TextStyle(color: widget.textColor)),
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
