class SignUpData {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  SignUpData({
    // ignore: non_constant_identifier_names
    this.firstName,
    // ignore: non_constant_identifier_names
    this.lastName,
    this.email,
    this.phone,
    this.password,
  });

  factory SignUpData.fromJson(Map<String, dynamic> json) {
    return SignUpData(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}
