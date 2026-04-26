import 'dart:ui';
import 'package:app/components/custom_form_field.dart';
import 'package:app/models/inquiry.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class InquiryDialog extends StatefulWidget {
  const InquiryDialog({super.key});
  static const Color primaryPurple = AppColors.primary;
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const InquiryDialog();
      },
    );
  }

  @override
  State<InquiryDialog> createState() => InviteDialogState();
}

class InviteDialogState extends State<InquiryDialog> {
  final formKey = GlobalKey<FormState>();
  late InquiryData model = InquiryData();
  @override
  void initState() {
    super.initState();
    model = InquiryData();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(240),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withAlpha(150),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(30),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "How Can We Help?",
                    style: TextTheme.of(context).headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Our team typically responds to all inquiries within 24 hours.",
                    textAlign: TextAlign.center,
                    style: TextTheme.of(context).labelSmall,
                  ),
                  const SizedBox(height: 28),
                  CustomFormField(
                    hintText: "Subject",
                    prefixIcon: Icons.subject,
                    type: FieldType.text,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        model.subject = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    hintText: "Message",
                    //prefixIcon: Icons.message,
                    type: FieldType.multiline,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        model.message = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              dynamic result = await Identity.instance
                                  .newInquiry(model);
                              if (result!['data']!['newInquiry'] != null) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Thank you. Your inquiry is now in our system.",
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.cardBackground,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.cardBackground,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            "Submit",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
