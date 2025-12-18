// ============================================================
// FILE: lib/widgets/task_checkbox.dart
// COPY THIS CODE INTO: lib/widgets/task_checkbox.dart
// ============================================================

import 'package:flutter/material.dart';

class TaskCheckbox extends StatefulWidget {
  final String taskName;
  final Function(bool) onChanged;

  TaskCheckbox({
    required this.taskName,
    required this.onChanged,
  });

  @override
  _TaskCheckboxState createState() => _TaskCheckboxState();
}

class _TaskCheckboxState extends State<TaskCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
            widget.onChanged(isChecked);
          });
        },
      ),
      title: Text(
        widget.taskName,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}