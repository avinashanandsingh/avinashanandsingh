import 'package:app/components/custom_form_field.dart';
import 'package:app/components/custom_select_field.dart';
import 'package:app/components/label.dart';
import 'package:app/components/loader.dart';
import 'package:app/models/common.dart';
import 'package:app/models/geo.dart';
import 'package:app/models/profile.dart';
import 'package:app/pages/signin.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
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
  late Future<List<CountryData>> countryList = Future.value([]);
  late Future<List<StateData>> stateList = Future.value([]);
  late Future<List<CityData>> cityList = Future.value([]);
  late Future<List<EnumData>> genderList = Future.value([]);
  @override
  void initState() {
    super.initState();
    genderList = Service.common.enumList('gender');
    if (mounted) {
      countryList = Service.common.countryList();
      if (model.countryId != null) {
        stateList = Service.common.stateList(model.countryId!);
      }

      if (model.stateId != null) {
        cityList = Service.common.cityList(model.countryId!, model.stateId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: false,
          titleTextStyle: TextTheme.of(context).headlineMedium,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == "CHPW") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePassword(),
                    ),
                  );
                } else if (value == "ORDH") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentHistory(),
                    ),
                  );
                } else if (value == "DELA") {
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
                } else if (value == "ENRC") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnrolledCourses(),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'ORDH',
                  padding: EdgeInsets.all(8),
                  height: 10,
                  child: Text(
                    'Order History',
                    style: TextTheme.of(context).labelSmall,
                  ),
                ),
                PopupMenuItem(
                  value: 'ENRC',
                  padding: EdgeInsets.all(8),
                  height: 10,
                  child: Text(
                    'Enrolled Courses',
                    style: TextTheme.of(context).labelSmall,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'CHPW',
                  padding: EdgeInsets.all(8),
                  height: 10,
                  child: Text(
                    'Change Password',
                    style: TextTheme.of(context).labelSmall,
                  ),
                ),
                PopupMenuItem(
                  value: 'DELA',
                  padding: EdgeInsets.all(8),
                  height: 10,
                  child: Text(
                    'Delete Account',
                    style: TextTheme.of(context).labelSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(text: "About"),
                CustomFormField(
                  hintText: "About",
                  type: FieldType.multiline,
                  initialValue: widget.data?.about,
                  onChanged: (value) {
                    setState(() {
                      model.about = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
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
                Label(text: "Date of Birth"),
                CustomFormField(
                  hintText: "Date of Birth",
                  type: FieldType.date,
                  initialValue: widget.data?.dob,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      model.dob = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Label(text: "Gender"),
                CustomSelectField<EnumData>(
                  options: genderList,
                  initialValue: model.gender != null
                      ? EnumData(value: model.gender)
                      : null,
                  displayStringForOption: (option) => option.value!,
                  onSelected: (value) {
                    setState(() {
                      model.gender = value?.value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Label(text: "Address"),
                CustomFormField(
                  hintText: "Address",
                  type: FieldType.multiline,
                  initialValue: widget.data?.address,
                  onChanged: (value) {
                    setState(() {
                      model.address = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Label(text: "Country ${widget.data?.country?.name}"),

                CustomSelectField(
                  options: countryList,
                  initialValue: widget.data?.country,
                  displayStringForOption: (CountryData country) =>
                      country.name!,
                  onSelected: (CountryData? value) {
                    var list = Service.common.stateList(value?.id ?? 0);
                    setState(() {
                      model.countryId = value?.id;
                      stateList = list;
                    });
                  },
                ),

                const SizedBox(height: 16),
                Label(text: "State"),

                CustomSelectField(
                  options: stateList,
                  initialValue: widget.data?.state,
                  displayStringForOption: (StateData state) => state.name!,
                  onSelected: (StateData? value) {
                    if (model.countryId == null) {
                      Alert.show("Please select country first", isError: true);
                      return;
                    }

                    var list = Service.common.cityList(
                      model.countryId!,
                      value?.id,
                    );
                    setState(() {
                      model.stateId = value?.id;
                      cityList = list;
                    });
                  },
                ),

                const SizedBox(height: 16),
                Label(text: "City"),
                CustomSelectField(
                  options: cityList,
                  initialValue: widget.data?.city,
                  displayStringForOption: (CityData city) => city.name!,
                  onSelected: (CityData? value) {
                    setState(() {
                      model.cityId = value?.id;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Label(text: "Postal Code"),
                CustomFormField(
                  hintText: "Postal Code",
                  type: FieldType.text,
                  prefixIcon: Icons.location_on_outlined,
                  initialValue: widget.data?.postalCode,
                  onChanged: (value) {
                    setState(() {
                      model.postalCode = value;
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
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        Loader.show();
                        dynamic result = await Service.user.update(model);
                        Loader.hide();
                        if (result!['data']!['updateProfile'] != null) {
                          Alert.show(
                            "Profile updated successfully",
                            isError: false,
                          );
                        } else {
                          dynamic error = result!['errors']![0];
                          Loader.hide();
                          String msg =
                              error?.extensions?.originalError?.message;
                          Alert.show(msg, isError: true);
                        }
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
                /* _buildMenuItem(
                  "Change Password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePassword(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32), */
                /* _buildMenuItem(
                  "Order History",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentHistory(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32), */
                /* _buildMenuItem(
                  "Enrolled Courses",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnrolledCourses(),
                      ),
                    );
                  },
                ), */
                /* const Divider(height: 32),

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
                const SizedBox(height: 32), */
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
