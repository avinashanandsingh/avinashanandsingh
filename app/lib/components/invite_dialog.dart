import 'dart:ui';
import 'package:app/components/custom_form_field.dart';
import 'package:app/models/invite.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

void showInviteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const InviteDialog();
    },
  );
}

class InviteDialog extends StatefulWidget {
  const InviteDialog({super.key});
  static const Color primaryPurple = AppColors.primary;

  @override
  State<InviteDialog> createState() => InviteDialogState();
}

class InviteDialogState extends State<InviteDialog> {
  final formKey = GlobalKey<FormState>();
  late String firstName = '';
  late String lastName = '';
  late String email = '';

  @override
  void initState() {
    super.initState();
    firstName = '';
    lastName = '';
    email = '';
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
                    "Invite a Friend",
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Share inner peace with your friends and family",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomFormField(
                    hintText: "First Name",
                    prefixIcon: Icons.person_outline,
                    type: FieldType.text,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),
                  //_buildTextField("First Name", Icons.person_outline),
                  const SizedBox(height: 16),
                  CustomFormField(
                    hintText: "Last Name",
                    prefixIcon: Icons.person_outline,
                    type: FieldType.text,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),
                  //_buildTextField("Last Name", Icons.person_outline),
                  const SizedBox(height: 16),
                  CustomFormField(
                    hintText: "Eamil Address",
                    prefixIcon: Icons.email_outlined,
                    type: FieldType.email,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        email = value;
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
                              InviteData inviteData = InviteData();
                              inviteData.firstName = firstName;
                              inviteData.lastName = lastName;
                              inviteData.email = email.toLowerCase();
                              inviteData.referredat = DateTime.now()
                                  .toIso8601String();

                              dynamic result = await Identity.instance.refer(
                                inviteData,
                              );
                              if (result!['data']!['refer'] != null) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Invite sent successfully!",
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
                            "Invite",
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
