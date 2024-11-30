import 'package:color_picker/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:color_picker/widgets/button_widget.dart';
import 'package:color_picker/widgets/input_widget.dart';
import 'package:color_picker/widgets/notification_widget.dart';

class RegisterPage extends StatefulWidget {
  final Color currentColor;
  final Color borderColor;
  final Color textColor;

  const RegisterPage({
    super.key,
    required this.currentColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isGoodLength = false;
  bool hasLetter = false;
  bool hasSpecialChar = false;

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roleController.text.isEmpty ? "user" : _roleController.text.trim();

    if (email.isNotEmpty && isGoodLength && hasLetter && hasSpecialChar) {
      User? user = await _authService.registerWithEmail(email, password, role, context);

      if (!mounted) return;

      if (user != null) {
        // Registration successful
        pushNotificationMessage(
          context: context,
          message: 'REGISTRATION SUCCESSFUL !',
          type: MessageType.success,
        );
        Navigator.pop(context);
      } else {
        // Registration failed
        pushNotificationMessage(
          context: context,
          message: 'REGISTRATION FAILED',
          type: MessageType.error,
        );
      }
    } else {
      pushNotificationMessage(
        context: context,
        message: 'PLEASE FILL IN ALL FIELDS.',
        type: MessageType.error,
      );
    }
  }

  void _validatePassword(String password) {
    setState(() {
      isGoodLength = password.length >= 8;
      hasLetter = RegExp(r'[1-9]').hasMatch(password);
      hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.currentColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: widget.textColor,
        ),
      ),
      body: Container(
        color: widget.currentColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 180.0, 30.0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'REGISTER',
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
                borderColor: widget.borderColor,
              ),
              const SizedBox(height: 20),
              input(
                controller: _roleController,
                hintText: 'ROLE',
                icon: Icons.admin_panel_settings_rounded,
                currentColor: widget.currentColor,
                textColor: widget.textColor,
                borderColor: widget.borderColor,
              ),
              const SizedBox(height: 20),
              input(
                controller: _passwordController,
                hintText: 'PASSWORD',
                icon: Icons.password_outlined,
                currentColor: widget.currentColor,
                textColor: widget.textColor,
                borderColor: widget.borderColor,
                isPasswordInput: true,
                onChanged: _validatePassword,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPasswordValidationIndicator(
                      isGoodLength, '8 characters', widget.textColor),
                  _buildPasswordValidationIndicator(
                      hasLetter, '1 letter', widget.textColor),
                  _buildPasswordValidationIndicator(
                      hasSpecialChar, '1 special', widget.textColor),
                ],
              ),
              
              const SizedBox(height: 30),
              button(
                label: 'REGISTER',
                themeColor: widget.currentColor,
                borderColor: widget.borderColor,
                textColor: widget.textColor,
                onPressed: _register,
                icon: Icons.login,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordValidationIndicator(
      bool condition, String text, Color textColor) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check_rounded : Icons.close_rounded,
          color: textColor,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ],
    );
  }
}
