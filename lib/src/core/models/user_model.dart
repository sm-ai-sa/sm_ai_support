import 'package:equatable/equatable.dart';

/// User model for registration
class UserModel extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String countryCode;

  const UserModel({
    this.fullName = '',
    this.phoneNumber = '',
    this.countryCode = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? countryCode,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  /// Get full phone number with country code
  String get fullPhoneNumber {
    if (phoneNumber.isEmpty) return '';
    String phone = phoneNumber;
    if (phone.startsWith("0")) {
      phone = phone.substring(1);
    }
    return '$countryCode$phone';
  }

  @override
  List<Object?> get props => [fullName, phoneNumber, countryCode];
}
