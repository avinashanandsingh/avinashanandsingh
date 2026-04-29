import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'package:intl/intl.dart';

enum FieldType { text, number, name, email, phone, password, multiline, date }

class CustomFormField extends StatefulWidget {
  final String hintText;
  final FieldType type;
  final bool isRequired;
  final String? pattern;
  final double? min;
  final double? max;
  final String? initialValue;
  //final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final IconData? prefixIcon;
  final bool readOnly;
  const CustomFormField({
    super.key,
    required this.hintText,
    this.type = FieldType.text,
    this.isRequired = false,
    this.pattern,
    this.min,
    this.max,
    this.initialValue,
    //this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.readOnly = false,
  });

  @override
  CustomFormFieldState createState() => CustomFormFieldState();
}

class CustomFormFieldState extends State<CustomFormField> {
  late TextEditingController _controller;
  bool _obscureText = true;
  bool multiline = false;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    multiline = false;
  }

  /// 🔹 GET VALUE
  String get value => _controller.text;

  /// 🔹 SET VALUE
  void setValue(String val) {
    _controller.text = val;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(), // Header
            textTheme: TextTheme.of(context),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextTheme.of(context).labelSmall,
              ), // Buttons
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats the date: 2026-04-27
        _controller.text = DateFormat('dd-MM-yyyy').format(picked.toLocal());
      });
    }
  }

  /// 🔹 KEYBOARD TYPE
  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case FieldType.number:
        return TextInputType.number;
      case FieldType.name:
        return TextInputType.name;
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.date:
        return TextInputType.datetime;
      case FieldType.multiline:
        setState(() {
          multiline = true;
        });
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  /// 🔹 VALIDATION
  String? _validate(String? value) {
    // Required
    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return '${widget.hintText} required';
    }

    if (value == null || value.trim().isEmpty) return null;

    // Email validation
    if (widget.type == FieldType.email) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Enter a valid email';
      }
    }

    // Number validation
    if (widget.type == FieldType.number) {
      final number = double.tryParse(value);
      if (number == null) {
        return '${widget.hintText} must be a valid number';
      }

      if (widget.min != null && number < widget.min!) {
        return 'Min value is ${widget.min}';
      }

      if (widget.max != null && number > widget.max!) {
        return 'Max value is ${widget.max}';
      }
    }

    // Pattern validation
    if (widget.pattern != null) {
      final regex = RegExp(widget.pattern!);
      if (!regex.hasMatch(value)) {
        return '${widget.hintText} must be in valid format';
      }
    }

    return null;
  }

  /// 🔹 PASSWORD TOGGLE
  Widget? _buildSuffixIcon() {
    if (widget.type == FieldType.password) {
      return IconButton(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.type == FieldType.date) {
      return IconButton(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
        onPressed: () {
          _selectDate(context);
        },
      );
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prefixIcon != null) {
      return TextFormField(
        controller: _controller,
        keyboardType: _getKeyboardType(),
        maxLines: multiline ? 3 : 1,
        obscureText: widget.type == FieldType.password ? _obscureText : false,
        validator: _validate,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        style: TextTheme.of(context).bodySmall,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: AppColors.primary,
            size: 20,
          ),
          suffixIcon: _buildSuffixIcon(),
        ),
      );
    } else {
      return TextFormField(
        controller: _controller,
        keyboardType: _getKeyboardType(),
        maxLines: multiline ? 3 : 1,
        obscureText: widget.type == FieldType.password ? _obscureText : false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: _validate,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        readOnly: widget.readOnly,
        style: TextTheme.of(context).bodySmall,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8),
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14),
          border: const OutlineInputBorder(),
          suffixIcon: _buildSuffixIcon(),
        ),
      );
    }
  }
}
