import 'package:app/models/user.dart';

class ProfileData {
  String? id;
  String? avatar;
  String? role;
  String? firstName;
  String? lastName;
  String? dob;
  String? gender;
  String? about;
  String? address;
  int? countryId;
  int? stateId;
  int? cityId;
  String? postalCode;
  String? email;
  String? phone;
  String? profession;
  String? currency;
  double? income;
  DateTime? lastLoginAt;
  UserBasicData? referedby;
  ProfileData({
    this.id,
    this.avatar,
    this.firstName,
    this.lastName,
    this.gender,
    this.address,
    this.about,
    this.email,
    this.phone,
    this.profession,
    this.currency,
    this.income,
    this.countryId,
    this.stateId,
    this.referedby,
    this.cityId,
    this.postalCode,
    this.lastLoginAt,
    this.dob,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as String?,
      avatar: json['avatar'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      about: json['about'] as String?,
      countryId: json['countryid']?.toInt(),
      stateId: json['stateid'] as int?,
      cityId: json['cityid'] as int?,
      postalCode: json['postal_code'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
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
      'avatar': avatar,
      'first_name': firstName,
      'last_name': lastName,
      'dob': dob,
      'gender': gender,
      'address': address,
      'about': about,
      'countryid': countryId,
      'stateid': stateId,
      'cityid': cityId,
      'postal_code': postalCode,
      'email': email,
      'phone': phone,
      'profession': profession,
      'currency': currency,
      'income': income,
      'last_login_at': lastLoginAt,
    };
  }
}
