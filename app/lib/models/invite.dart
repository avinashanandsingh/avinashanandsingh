class InviteData {
  String? firstName;
  String? lastName;
  String? email;
  String? referredat;
  InviteData({this.firstName, this.lastName, this.email, this.referredat});

  factory InviteData.fromJson(Map<String, dynamic> json) {
    return InviteData(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      referredat: json['referredat'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'referredat': referredat,
    };
  }
}
