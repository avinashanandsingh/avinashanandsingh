import 'package:app/components/custom_form_field.dart';
import 'package:app/components/loader.dart';
import 'package:app/helpers/convert.dart';
import 'package:app/models/register.dart';
import 'package:app/pages/verify_otp.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

import 'signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  late RegisterData model;
  late String confirmPassword = '';
  late bool showError = false;
  late bool loader = false;
  @override
  void initState() {
    super.initState();
    model = RegisterData();
    confirmPassword = '';
    showError = false;
    loader = true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushReplacementNamed("/signin");
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start Your Learning Journey.',
                            style: TextTheme.of(context).headlineLarge,
                          ),
                          const SizedBox(height: 15),
                          CustomFormField(
                            hintText: "First Name",
                            type: FieldType.text,
                            isRequired: true,
                            prefixIcon: Icons.person_outline,
                            onChanged: (value) {
                              setState(() {
                                model.firstName = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomFormField(
                            hintText: "Last Name",
                            type: FieldType.text,
                            isRequired: true,
                            prefixIcon: Icons.person_outline,
                            onChanged: (value) {
                              setState(() {
                                model.lastName = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomFormField(
                            hintText: "Phone",
                            type: FieldType.phone,
                            isRequired: true,
                            prefixIcon: Icons.phone_outlined,
                            onChanged: (value) {
                              setState(() {
                                model.phone = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomFormField(
                            hintText: "Email Address",
                            type: FieldType.email,
                            isRequired: true,
                            prefixIcon: Icons.email_outlined,
                            onChanged: (value) {
                              setState(() {
                                model.email = value;
                              });
                            },
                          ),

                          const SizedBox(height: 15),
                          CustomFormField(
                            hintText: "Password",
                            type: FieldType.password,
                            isRequired: true,
                            prefixIcon: Icons.password_outlined,
                            pattern:
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                            onChanged: (value) {
                              setState(() {
                                model.password = Convert.toBase64(value);
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomFormField(
                            hintText: "Confirm Password",
                            type: FieldType.password,
                            isRequired: true,
                            pattern:
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                            prefixIcon: Icons.password_outlined,
                            onChanged: (value) {
                              setState(() {
                                confirmPassword = Convert.toBase64(value);
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if (showError) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Passwords must match!',
                                style: AppTheme.errorStyle,
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Creating account, you are agree to terms',
                              style: TextTheme.of(context).labelSmall,
                            ),
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (model.password != confirmPassword) {
                                  setState(() {
                                    showError = true;
                                  });
                                }
                                if (formKey.currentState!.validate()) {
                                  Loader.show(context);
                                  try {
                                    dynamic result = await Identity.instance
                                        .signup(model);
                                    if (result!['data']!['signup'] != null) {
                                      Loader.hide(context);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const VerifyOtp(),
                                        ),
                                      );
                                    } else {
                                      dynamic error = result!['errors']![0];
                                      Loader.hide(context);
                                      String msg = error
                                          ?.extensions
                                          ?.originalError
                                          ?.message;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            msg,
                                            style: GoogleFonts.montserrat(
                                              color: AppColors.error,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    Loader.hide(context);
                                    print(e);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gradientTop,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'CREATE ACCOUNT',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const SignIn(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Have an account? ',
                                  style: GoogleFonts.inter(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
                                      style: GoogleFonts.montserrat(
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
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
