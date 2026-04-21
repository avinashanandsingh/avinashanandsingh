class UserData {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? profession;
  String? currency;
  double? income;
  String? status;
  UserData({
    this.id,
    // ignore: non_constant_identifier_names
    this.firstName,
    // ignore: non_constant_identifier_names
    this.lastName,
    this.email,
    this.phone,
    this.profession,
    this.currency,
    this.income,
    this.status,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profession: json['profession'] as String?,
      currency: json['currency'] as String?,
      income: json['income'] as double?,
      status: json['status'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profession': profession,
      'currency': currency,
      'income': income,
      'status': status,
    };
  }
}
