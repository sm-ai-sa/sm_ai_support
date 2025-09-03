import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Tenant model representing tenant configuration data
class TenantModel extends Equatable {
  /// Unique identifier for the tenant
  final String tenantId;
  
  /// Primary color for the tenant's theme
  final String mainColor;
  
  /// Tenant name
  final String name;
  
  /// URL for the tenant's logo
  final String logo;

  const TenantModel({
    required this.tenantId,
    required this.mainColor,
    required this.name,
    required this.logo,
  });

  /// Factory constructor to create TenantModel from JSON
  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      tenantId: (json['id']).toString(),
      mainColor: json['mainColor'] as String? ?? '#000000',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
    );
  }

  /// Convert TenantModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'mainColor': mainColor,
      'name': name,
      'logo': logo,
    };
  }

  /// Create a copy of this TenantModel with updated fields
  TenantModel copyWith({
    String? tenantId,
    String? mainColor,
    String? name,
    String? logo,
  }) {
    return TenantModel(
      tenantId: tenantId ?? this.tenantId,
      mainColor: mainColor ?? this.mainColor,
      name: name ?? this.name,
      logo: logo ?? this.logo,
    );
  }

  /// Convert color string to Flutter Color object
  Color get primaryColor {
    try {
      // Remove # if present and ensure it's a valid hex color
      String colorStr = mainColor.replaceFirst('#', '');
      if (colorStr.length == 6) {
        return Color(int.parse('FF$colorStr', radix: 16));
      }
      return Colors.black; // Default color
    } catch (e) {
      return Colors.black; // Default color if parsing fails
    }
  }

  /// Create a dummy tenant model for error cases
  factory TenantModel.dummy() {
    return const TenantModel(
      tenantId: '1',
      mainColor: '#7283F3',
      name: 'Unicode',
      logo: 'https://sm-dev-bucket.blr1.cdn.digitaloceanspaces.com/files/public/logos/SMLogoBlack.png',
    );
  }

  @override
  List<Object?> get props => [tenantId, mainColor, name, logo];
}

/// Response wrapper for tenant API
class TenantResponse extends Equatable {
  final TenantModel tenant;

  const TenantResponse({required this.tenant});

  factory TenantResponse.fromJson(Map<String, dynamic> json) {
    return TenantResponse(
      tenant: TenantModel.fromJson(json['result'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': tenant.toJson(),
    };
  }

  @override
  List<Object?> get props => [tenant];
}
