import 'package:app/components/custom_form_field.dart';
import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/helpers/convert.dart';
import 'package:app/services/service.dart';
import 'package:app/theme/theme.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordData {
  String newPassword = '';
  String confirmPassword = '';
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late ChangePasswordData model = ChangePasswordData();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    model = ChangePasswordData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get _newPassword => model.newPassword;

  bool get _hasMinLength => _newPassword.length >= 8;
  bool get _hasUppercase => _newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _newPassword.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _newPassword.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _newPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA), // Soft background app color
      appBar: AppBar(
        title: Text('Change Password'),
        centerTitle: false,
        titleTextStyle: TextTheme.of(context).headlineMedium,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Password Strength Card
                    _buildRequirementsCard(),
                    const SizedBox(height: 32),

                    Label(text: "New Password"),
                    CustomFormField(
                      hintText: "New password",
                      type: FieldType.password,
                      isRequired: true,
                      onChanged: (value) {
                        setState(() {
                          model.newPassword = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Label(text: "Confirm Password"),
                    CustomFormField(
                      hintText: "Confirm password",
                      type: FieldType.password,
                      isRequired: true,
                      onChanged: (value) {
                        setState(() {
                          model.confirmPassword = value;
                        });
                      },
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
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            Loader.show();
                            var result = await Service.identity.changePassword(
                              newPassword: Convert.toBase64(model.newPassword),
                            );
                            Loader.hide();
                            if (result!['data']!['changePassword'] != null) {
                              var data = result['data']['changePassword'];
                              var succeed = data['succeed'];
                              String msg =
                                  data['message'] ??
                                  'Password changed successfully';
                              Alert.show(msg, isError: !succeed);
                            } else {
                              dynamic error = result!['errors']![0];
                              String msg =
                                  error?.extensions?.originalError?.message;
                              Alert.show(msg, isError: true);
                            }
                          }
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
}
