import 'package:app/models/user.dart';

class ProfileData {
  String? id;
  String? role;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  int? countryId;
  int? stateId;
  int? cityId;
  String? profession;
  String? currency;
  double? income;
  DateTime? lastLoginAt;
  UserBasicData? referedby;
  ProfileData({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profession,
    this.currency,
    this.income,
    this.countryId,
    this.stateId,
    this.referedby,
    this.cityId,
    this.lastLoginAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      countryId: json['countryid']?.toInt(),
      stateId: json['stateid'] as int?,
      cityId: json['cityid'] as int?,
      profession: json['profession'] as String?,
      currency: json['currency'] as String?,
      income: json['income']?.toDouble(),
      referedby: UserBasicData.fromJson(json['referby']),
      lastLoginAt: DateTime.parse(json['last_login_at']),
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
      'countryid': countryId,
      'stateid': stateId,
      'cityid': cityId,
      'profession': profession,
      'currency': currency,
      'income': income,
      'last_login_at': lastLoginAt,
    };
  }
}
