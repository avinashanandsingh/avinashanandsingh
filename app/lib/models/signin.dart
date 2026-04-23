class SigninData {
  String? username;
  String? password;
  SigninData({this.username, this.password});

  factory SigninData.fromJson(Map<String, dynamic> json) {
    return SigninData(
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
