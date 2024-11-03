import 'package:flutter/material.dart';

class CustomCheckboxField extends StatefulWidget {
  final String enabledLabel;
  final String disabledLabel;
  final Icon enabledIcon;
  final Icon disabledIcon;

  const CustomCheckboxField({
    super.key,
    required this.enabledLabel,
    required this.disabledLabel,
    required this.enabledIcon,
    required this.disabledIcon,
  });

  @override
  _CustomCheckboxFieldState createState() => _CustomCheckboxFieldState();
}

class _CustomCheckboxFieldState extends State<CustomCheckboxField> {
  bool isPublic = false;
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: TextField(
              enabled: false,
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                icon: isPublic ? widget.enabledIcon : widget.disabledIcon,
                border: InputBorder.none,
                labelText:
                    isPublic ? widget.enabledLabel : widget.disabledLabel,
              ),
            ),
            value: isPublic,
            onChanged: (value) => setState(() => isPublic = value!),
            controlAffinity: ListTileControlAffinity.trailing,
            checkColor: Colors.white,
            activeColor: Colors.blue,
            tileColor: Colors.transparent,
            dense: true,
          ),
        ),
      ),
    );
  }
}
