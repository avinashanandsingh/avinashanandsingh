import 'package:flutter/material.dart';

class DateFormField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final DateTime? initialValue;
  final void Function(DateTime?)? onChanged;
  final bool isRequired;
  final String? requiredErrorMessage;
  final FormFieldValidator<DateTime>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(DateTime)? dateFormat;

  const DateFormField({
    super.key,
    this.hintText = 'Select a date',
    this.labelText,
    this.initialValue,
    this.onChanged,
    this.isRequired = false,
    this.requiredErrorMessage = 'This field is required',
    this.validator,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
  });

  @override
  State<DateFormField> createState() => _DateFormFieldState();
}

class _DateFormFieldState extends State<DateFormField> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
    _controller = TextEditingController(
      text: _selectedDate != null ? _formatDate(_selectedDate!) : '',
    );
  }

  @override
  void didUpdateWidget(DateFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedDate = widget.initialValue;
      _controller.text = _selectedDate != null
          ? _formatDate(_selectedDate!)
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    if (widget.dateFormat != null) {
      return widget.dateFormat!(date);
    }
    // Default format: yyyy-MM-dd
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
            bodyLarge: TextStyle(color: Colors.black),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatDate(picked);
      });
      if (widget.onChanged != null) {
        widget.onChanged!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      style: TextTheme.of(context).labelSmall,
      readOnly: false,
      onTap: () => _selectDate(context),

      validator: (value) {
        if (widget.isRequired && _selectedDate == null) {
          return widget.requiredErrorMessage;
        }
        if (widget.validator != null) {
          return widget.validator!(_selectedDate);
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextTheme.of(
          context,
        ).bodySmall?.copyWith(color: Colors.grey),
        labelStyle: TextTheme.of(
          context,
        ).bodyMedium?.copyWith(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
      ),
    );
  }
}
