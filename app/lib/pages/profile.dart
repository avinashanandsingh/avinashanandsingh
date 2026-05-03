import 'package:app/components/alert.dart';
import 'package:app/components/custom_form_field.dart';
import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/models/profile.dart';
import 'package:app/pages/signin.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'change_password.dart';
import 'payment_history.dart';
import 'enrolled_courses.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, this.data});
  final ProfileData? data;
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  static const Color primaryPurple = AppColors.primary;
  final formKey = GlobalKey<FormState>();
  late ProfileData model = widget.data!;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: false,
          titleTextStyle: TextTheme.of(context).headlineMedium,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(text: "First Name"),
                CustomFormField(
                  hintText: "First Name",
                  type: FieldType.name,
                  prefixIcon: Icons.person_outline,
                  isRequired: true,
                  initialValue: widget.data?.firstName,
                  onChanged: (value) {
                    setState(() {
                      model.firstName = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Label(text: "Last Name"),
                CustomFormField(
                  hintText: "Last Name",
                  type: FieldType.name,
                  prefixIcon: Icons.person_outline,
                  isRequired: true,
                  initialValue: widget.data?.lastName,
                  onChanged: (value) {
                    setState(() {
                      model.lastName = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Label(text: "Email Address"),
                CustomFormField(
                  hintText: "Email Address",
                  type: FieldType.email,
                  prefixIcon: Icons.email_outlined,
                  isRequired: true,
                  initialValue: widget.data?.email,
                  onChanged: (value) {
                    setState(() {
                      model.email = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Label(text: "Phone"),
                CustomFormField(
                  hintText: "Phone",
                  type: FieldType.phone,
                  prefixIcon: Icons.phone_outlined,
                  isRequired: true,
                  initialValue: widget.data?.phone,
                  onChanged: (value) {
                    setState(() {
                      model.phone = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Label(text: "Profession"),
                CustomFormField(
                  hintText: "Profession",
                  type: FieldType.text,
                  initialValue: widget.data?.profession,
                  onChanged: (value) {
                    setState(() {
                      model.profession = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Label(text: "Monthly Income"),
                CustomFormField(
                  hintText: "Monthly Income",
                  type: FieldType.number,
                  initialValue: widget.data?.income?.toString(),
                  onChanged: (value) {
                    setState(() {
                      model.income = double.parse(value);
                    });
                  },
                ),
                const SizedBox(height: 32),

                Text("REFERED BY", style: TextTheme.of(context).headlineSmall),
                const SizedBox(height: 8),
                Label(text: "First Name"),
                CustomFormField(
                  hintText: "First Name",
                  type: FieldType.text,
                  prefixIcon: Icons.person_outline,
                  readOnly: true,
                  initialValue: widget.data?.referedby?.firstName,
                ),
                const SizedBox(height: 16),
                Label(text: "Last Name"),
                CustomFormField(
                  hintText: "Last Name",
                  type: FieldType.text,
                  prefixIcon: Icons.person_outline,
                  readOnly: true,
                  initialValue: widget.data?.referedby?.lastName,
                ),
                const SizedBox(height: 16),
                Label(text: "Email Address"),
                CustomFormField(
                  hintText: "Email Address",
                  type: FieldType.email,
                  prefixIcon: Icons.email_outlined,
                  readOnly: true,
                  initialValue: widget.data?.referedby?.email,
                ),
                const SizedBox(height: 32),
                /* 
              _buildLabel("What motivated you to join?"),
              _buildTextField("Write your answer here", maxLines: 4),
              const SizedBox(height: 16),

              _buildLabel("What outcome do you desire?"),
              _buildTextField("Write your answer here", maxLines: 4),
              const SizedBox(height: 16), */
                // Checkbox and Agreement Text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                        side: BorderSide(color: Colors.grey.shade400),
                        activeColor: primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          children: const [
                            TextSpan(
                              text:
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                            ),
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        Loader.show(context);
                        String? id = await Service.user.update(model);
                        if (id != null) {
                          Alert.success(
                            context,
                            "Profile updated successfully",
                          );
                        }
                        Loader.hide(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Submit", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
                _buildMenuItem(
                  "Reset Password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePassword(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  "Payment History",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentHistory(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  "Enrolled Courses",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnrolledCourses(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32),

                // Delete Account
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Delete Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                "Delete Account",
                                style: TextStyle(fontSize: 18),
                              ),
                              content: const Text(
                                "Are you sure you, want to delete?\nThis action cannot be undone.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignIn(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                    padding: EdgeInsets.all(3),
                                  ),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }
}
