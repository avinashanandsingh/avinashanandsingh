import 'package:app/components/custom_form_field.dart';
import 'package:app/components/label.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _newPassword => _newPasswordController.text;

  bool get _hasMinLength => _newPassword.length >= 10;
  bool get _hasUppercase => _newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _newPassword.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _newPassword.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _newPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  double get _strengthProgress {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecial) score++;
    return score / 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA), // Soft background app color
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Assume we pop back
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Change Password',
                      style: TextTheme.of(context).headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Password Strength Card
                  _buildRequirementsCard(),
                  const SizedBox(height: 32),

                  Label(text: "New Password"),
                  CustomFormField(
                    hintText: "New password",
                    type: FieldType.password,
                    isRequired: true,
                  ),
                  const SizedBox(height: 20),
                  Label(text: "Confirm Password"),
                  CustomFormField(
                    hintText: "Confirm password",
                    type: FieldType.password,
                    isRequired: true,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2B0A5E),
                          Color(0xFF5D20A6),
                        ], // Deep purple gradient
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement change password action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Confirm and Change Password',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC79A4A), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Strength & Requirements',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Check items
          _buildRequirementRow('At least 10 characters', _hasMinLength),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one uppercase letter', _hasUppercase),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one lowercase letter', _hasLowercase),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one number', _hasNumber),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one special character', _hasSpecial),
          const SizedBox(height: 16),
          // Progress bar
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check
              : Icons.circle_outlined, // Check if met, circle if not
          color: isMet ? Colors.green : Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isMet ? Colors.black87 : Colors.grey.shade600,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4A2396)),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.grey.shade500,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }
}
