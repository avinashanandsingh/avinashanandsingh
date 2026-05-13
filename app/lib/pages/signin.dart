import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/models/signin.dart';
import 'package:app/services/storage.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/components/custom_form_field.dart';
import 'package:app/helpers/convert.dart';
import 'package:app/pages/forgot_password.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/helpers/globals.dart';
import '../theme/theme.dart';
import 'signup.dart';

class SignIn extends StatefulWidget {
  final Widget? redirect;
  const SignIn({super.key, this.redirect});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //bool _obscurePassword = true;
  late SigninData model = SigninData();
  Storage store = Storage();
  @override
  void initState() {
    super.initState();
    model = SigninData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () {
            if (widget.redirect != null) {
              navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (context) => widget.redirect!),
              );
            } else {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushReplacementNamed("/home");
            }
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop / Tablet Landscape
            return _buildRightPanel(context);
          } else {
            // Mobile
            return _buildRightPanel(context);
          }
        },
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (MediaQuery.of(context).size.width <= 800) ...[
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/login_illustration.svg',
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                Label(text: 'Username'),
                CustomFormField(
                  hintText: "Username",
                  prefixIcon: Icons.email_outlined,
                  type: FieldType.text,
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      model.username = value.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Label(text: 'Password'),
                CustomFormField(
                  hintText: "Password",
                  type: FieldType.password,
                  prefixIcon: Icons.password_outlined,
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      model.password = Convert.toBase64(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPassword(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientTop,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Loader.show();
                      dynamic result = await Identity.instance.signin(model);
                      Loader.hide();
                      if (result?['errors'] != null) {
                        dynamic error = result?['errors'][0];
                        String msg =
                            error['extensions']['originalError']['message'];
                        Alert.show(msg, isError: true);
                      } else {
                        String token = result['data']['signin'];
                        await store.set("token", token);
                        if (widget.redirect != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => widget.redirect!,
                            ),
                          );
                        } else {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushReplacementNamed("/home");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientTop,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const SignUp()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextTheme.of(context).labelSmall,
                        children: [
                          TextSpan(
                            text: 'Sign Up',
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
          ),
        ),
      ),
    );
  }
}
