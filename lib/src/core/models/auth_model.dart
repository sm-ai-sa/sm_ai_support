import 'package:equatable/equatable.dart';

/// Customer model for authentication responses
class CustomerModel extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String phone;

  const CustomerModel({
    required this.id,
    this.name,
    this.email,
    required this.phone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, name, email, phone];
}

/// Send OTP request model
class SendOtpRequest extends Equatable {
  final String phone;
  final String? name; // Optional name parameter for registration

  const SendOtpRequest({
    required this.phone,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'phone': phone,
    };

    if (name != null && name!.isNotEmpty) {
      data['name'] = name!;
    }

    return data;
  }

  @override
  List<Object?> get props => [phone, name];
}

/// Send OTP response model
class SendOtpResponse extends Equatable {
  final String token; // Temporary token for verification
  final int statusCode;

  const SendOtpResponse({
    required this.token,
    required this.statusCode,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      token: json['result']['token'] as String,
      statusCode: json['statusCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': {
        'token': token,
      },
      'statusCode': statusCode,
    };
  }

  @override
  List<Object?> get props => [token, statusCode];
}

/// Verify OTP request model
class VerifyOtpRequest extends Equatable {
  final String phone;
  final String otp;
  final String? sessionId; // Optional session ID to link with existing session

  const VerifyOtpRequest({
    required this.phone,
    required this.otp,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'phone': phone,
      'otp': otp,
    };
    
    if (sessionId != null) {
      data['sessionId'] = sessionId!;
    }
    
    return data;
  }

  @override
  List<Object?> get props => [phone, otp, sessionId];
}

/// Verify OTP response result model
class VerifyOtpResult extends Equatable {
  final String token; // Final authentication token
  final CustomerModel customer;

  const VerifyOtpResult({
    required this.token,
    required this.customer,
  });

  factory VerifyOtpResult.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResult(
      token: json['token'] as String,
      customer: CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'customer': customer.toJson(),
    };
  }

  @override
  List<Object?> get props => [token, customer];
}

/// Verify OTP response model
class VerifyOtpResponse extends Equatable {
  final VerifyOtpResult result;
  final int statusCode;

  const VerifyOtpResponse({
    required this.result,
    required this.statusCode,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      result: VerifyOtpResult.fromJson(json['result'] as Map<String, dynamic>),
      statusCode: json['statusCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.toJson(),
      'statusCode': statusCode,
    };
  }

  @override
  List<Object?> get props => [result, statusCode];
}

/// Auto-login customer data model
class CustomerData extends Equatable {
  final String countryCode;
  final String phone;
  final String name;

  const CustomerData({
    required this.countryCode,
    required this.phone,
    required this.name,
  });

  /// Get full phone number (country code + phone)
  String get fullPhoneNumber => '$countryCode$phone';

  Map<String, dynamic> toJson() {
    return {
      'phone': fullPhoneNumber,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [countryCode, phone, name];
}

