import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Stateful widget for picking a date
class DatePickerField extends StatefulWidget {
  final String label;
  final String hintText;
  final Function(DateTime?) onDateSelected;
  final String? Function(String?)? validator;

  const DatePickerField({
    required this.label,
    required this.hintText,
    required this.onDateSelected,
    this.validator,
    super.key,
  });

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ThemeData pickerTheme = isDarkMode
        ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          )
        : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.grey[300]!,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          );

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          readOnly: true,
          controller: _controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: pickerTheme,
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              _controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              widget.onDateSelected(pickedDate);
            }
          },
          decoration: InputDecoration(
            icon: const Icon(
              Icons.calendar_today_rounded,
            ),
            border: InputBorder.none,
            labelText: widget.label,
            hintText: widget.hintText,
          ),
        ),
      ),
    );
  }
}

/// Stateful widget for picking a time
class TimePickerField extends StatefulWidget {
  final String label;
  final String hintText;
  final Function(TimeOfDay?) onTimeSelected;
  final String? Function(String?)? validator;

  const TimePickerField({
    required this.label,
    required this.hintText,
    required this.onTimeSelected,
    this.validator,
    super.key,
  });

  @override
  _TimePickerFieldState createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ThemeData pickerTheme = isDarkMode
        ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          )
        : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.grey[300]!,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          );

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          readOnly: true,
          controller: _controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: pickerTheme,
                  child: child!,
                );
              },
            );

            if (pickedTime != null) {
              _controller.text =
                  pickedTime.format(context); // Format based on locale
              widget.onTimeSelected(pickedTime);
            }
          },
          decoration: InputDecoration(
            icon: const Icon(
              Icons.access_time,
            ),
            border: InputBorder.none,
            labelText: widget.label,
            hintText: widget.hintText,
          ),
        ),
      ),
    );
  }
}
