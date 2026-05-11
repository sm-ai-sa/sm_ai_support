import 'package:equatable/equatable.dart';

/// Model representing an ICE server configuration for WebRTC
class IceServerModel extends Equatable {
  final String urls;
  final String? username;
  final String? credential;

  const IceServerModel({
    required this.urls,
    this.username,
    this.credential,
  });

  factory IceServerModel.fromJson(Map<String, dynamic> json) {
    return IceServerModel(
      urls: json['urls'] is List ? (json['urls'] as List).first as String : json['urls'] as String,
      username: json['username'] as String?,
      credential: json['credential'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'urls': urls,
        if (username != null) 'username': username,
        if (credential != null) 'credential': credential,
      };

  /// Convert to WebRTC-compatible config map
  Map<String, dynamic> toWebRTCConfig() => toJson();

  IceServerModel copyWith({
    String? urls,
    String? username,
    String? credential,
  }) {
    return IceServerModel(
      urls: urls ?? this.urls,
      username: username ?? this.username,
      credential: credential ?? this.credential,
    );
  }

  @override
  List<Object?> get props => [urls, username, credential];
}
