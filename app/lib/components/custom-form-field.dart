import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';

enum FieldType { text, number, email, phone, password }

class CustomFormField extends StatefulWidget {
  final String hintText;
  final FieldType type;
  final bool isRequired;
  final String? pattern;
  final double? min;
  final double? max;
  final String? initialValue;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final IconData? prefixIcon;
  const CustomFormField({
    super.key,
    required this.hintText,
    this.type = FieldType.text,
    this.isRequired = false,
    this.pattern,
    this.min,
    this.max,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
  });

  @override
  CustomFormFieldState createState() => CustomFormFieldState();
}

class CustomFormFieldState extends State<CustomFormField> {
  late TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  /// 🔹 GET VALUE
  String get value => _controller.text;

  /// 🔹 SET VALUE
  void setValue(String val) {
    _controller.text = val;
  }

  /// 🔹 KEYBOARD TYPE
  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case FieldType.number:
        return TextInputType.number;
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  /// 🔹 VALIDATION
  String? _validate(String? value) {
    //print("custom field value: ${widget.isRequired}");
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
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
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
        obscureText: widget.type == FieldType.password ? _obscureText : false,
        validator: _validate,
        autovalidateMode: AutovalidateMode.always,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(widget.prefixIcon, color: AppColors.primary),
          suffixIcon: _buildSuffixIcon(),
        ),
      );
    } else {
      return TextFormField(
        controller: _controller,
        keyboardType: _getKeyboardType(),
        obscureText: widget.type == FieldType.password ? _obscureText : false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: _validate,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8),
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          suffixIcon: _buildSuffixIcon(),
        ),
      );
    }
  }
}
