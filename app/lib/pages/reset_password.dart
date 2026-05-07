import 'package:app/components/custom_form_field.dart';
import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/helpers/convert.dart';
import 'package:app/pages/signin.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../components/layout.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  String newPassword = '';
  String confirmPassword = '';

  @override
  void initState() {
    super.initState();
    newPassword = '';
    confirmPassword = '';
  }

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ─── OTP helpers ────────────────────────────────────────────────────────────
  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  bool get _hasMinLength => newPassword.length >= 8;
  bool get _hasUppercase => newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => newPassword.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => newPassword.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      newPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  double get _strengthProgress {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecial) score++;
    return score / 5;
  }

  Color get _strengthColor {
    if (_strengthProgress <= 0.2) return Colors.redAccent;
    if (_strengthProgress <= 0.4) return Colors.orange;
    if (_strengthProgress <= 0.6) return const Color(0xFFD4AF37);
    if (_strengthProgress <= 0.8) return Colors.lightGreen;
    return Colors.green;
  }

  String get _strengthLabel {
    if (newPassword.isEmpty) return '';
    if (_strengthProgress <= 0.2) return 'Very Weak';
    if (_strengthProgress <= 0.4) return 'Weak';
    if (_strengthProgress <= 0.6) return 'Fair';
    if (_strengthProgress <= 0.8) return 'Strong';
    return 'Very Strong';
  }

  // ─── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;

    if (_otpValue.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the complete 6-digit OTP',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passwords do not match',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    Loader.show();
    var result = await Service.identity.reset(
      _otpValue,
      Convert.toBase64(newPassword),
    );
    Loader.hide();
    if (result['data'] != null) {
      bool succeed = result['data']['reset']['succeed'];
      String message = result['data']['reset']['message'];
      if (succeed) {
        _showSuccessDialog();
      } else {
        Alert.show(message, isError: true);
      }
    } else {
      dynamic error = result!['errors']![0];
      String msg = error?.extensions?.originalError?.message;
      Alert.show(msg, isError: true);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientTop, AppColors.gradientGold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientTop.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Password Reset\nSuccessful!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your password has been updated.\nPlease log in with your new password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignIn()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradientTop,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'GO TO LOGIN',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reset Password'),
          centerTitle: false,
          titleTextStyle: TextTheme.of(context).headlineSmall,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 52,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Reset Password',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Enter the OTP sent to your email and\ncreate a new password.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── OTP Section ────────────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.pin_rounded,
                    title: 'Verification Code',
                  ),
                  const SizedBox(height: 12),
                  _buildOtpRow(),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        print('Resend OTP');
                      },
                      style: TextButton.styleFrom(
                        overlayColor: Colors.transparent,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          children: const [
                            TextSpan(text: "Didn't receive it? "),
                            TextSpan(
                              text: 'Resend OTP',
                              style: TextStyle(
                                color: AppColors.gradientTop,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Password Requirements ─────────────────────────
                  _buildRequirementsCard(),
                  const SizedBox(height: 28),
                  Label(text: 'New Password'),
                  const SizedBox(height: 10),
                  CustomFormField(
                    hintText: 'Enter new password',
                    isRequired: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    type: FieldType.password,
                    onChanged: (value) {
                      setState(() {
                        // Trigger strength evaluation
                        newPassword = value;
                      });
                    },
                  ),
                  if (newPassword.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildStrengthBar(),
                  ],
                  const SizedBox(height: 20),

                  Label(text: 'Confirm Password'),
                  const SizedBox(height: 10),
                  CustomFormField(
                    hintText: 'Re-enter new password',
                    prefixIcon: Icons.lock_outline_rounded,
                    isRequired: true,
                    type: FieldType.password,
                    onChanged: (value) {
                      setState(() {
                        // Trigger strength evaluation
                        confirmPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // ── Submit Button ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientTop,
                          AppColors.gradientBottom,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientTop.withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'RESET PASSWORD',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Back to Login link ─────────────────────────────
                  Center(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SignIn()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'Remember your password? ',
                          style: TextTheme.of(context).labelSmall,
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextTheme.of(context).labelSmall?.copyWith(
                                color: AppColors.gradientTop,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  // ─── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gradientTop.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gradientTop.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: AppColors.gradientTop,
            ),
            const SizedBox(width: 6),
            Text(
              'Back',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gradientTop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accentGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientTop.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: false,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.gradientTop,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => _onOtpChanged(value, index),
          ),
        );
      }),
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
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementRow('At least 8 characters', _hasMinLength),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one uppercase letter', _hasUppercase),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one lowercase letter', _hasLowercase),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one number', _hasNumber),
          const SizedBox(height: 6),
          _buildRequirementRow('At least one special character', _hasSpecial),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: isMet ? Colors.green : Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: isMet ? Colors.black87 : Colors.grey.shade600,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthBar() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _strengthProgress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _strengthLabel,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _strengthColor,
          ),
        ),
      ],
    );
  }
}
