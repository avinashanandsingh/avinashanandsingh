import 'package:app/components/custom_form_field.dart';
import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/pages/reset_password.dart';
import 'package:app/pages/signin.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    email = '';
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    Loader.show();
    var result = await Service.identity.forgot(email.trim());
    Loader.hide();
    if (result['data'] != null) {
      bool succeed = result['data']['forgot']['succeed'];
      String message = result['data']['forgot']['message'];
      if (succeed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResetPassword(email: email.trim())),
        );
      } else {
        Alert.show(message, isError: true);
      }
    } else {
      dynamic error = result!['errors']![0];
      String msg = error?.extensions?.originalError?.message;
      Alert.show(msg, isError: true);
    }
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Form state ─────────────────────────────────────────────────────────────
  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'We\'ll email you a link to reset your password.',
            style: TextTheme.of(context).labelMedium,
          ),
          const SizedBox(height: 36),

          // Email field
          Label(text: 'Email Address'),
          CustomFormField(
            hintText: 'Email Address',
            type: FieldType.email,
            prefixIcon: Icons.mail_outline_rounded,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          const SizedBox(height: 32),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientTop,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.gradientTop.withAlpha(150),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'SEND OTP',
                style: TextTheme.of(context).labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Or', style: TextTheme.of(context).labelSmall),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 24),

          // Remember password prompt
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
        ],
      ),
    );
  }
}
