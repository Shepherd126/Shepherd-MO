import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPasswordField;
  final bool hidePassword;
  final bool isDark;
  final Function(String?)? onSaved;
  final FocusNode focusNode;
  final Function()? togglePasswordView;
  final double width;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPasswordField = false,
    this.hidePassword = false,
    required this.isDark,
    this.onSaved,
    required this.focusNode,
    required this.width,
    this.togglePasswordView,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        obscureText: isPasswordField ? hidePassword : false,
        validator: (value) {
          if (value!.isEmpty) {
            return 'This field is required.';
          }
          if (isPasswordField && value.length < 5) {
            return 'Password must be at least 5 characters long.';
          }
          return null;
        },
        onSaved: onSaved,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          prefixIcon:
              Icon(prefixIcon, color: isDark ? Colors.white : Colors.black),
          suffixIcon: isPasswordField
              ? IconButton(
                  onPressed: togglePasswordView,
                  icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility),
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                )
              : null,
        ),
      ),
    );
  }
}
