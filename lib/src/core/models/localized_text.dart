import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

class LocaLizedText extends Equatable {
  final String en;
  final String ar;

  LocaLizedText({
    required this.en,
    required this.ar,
  });

  factory LocaLizedText.fromJson(Map<String, dynamic> json) {
    return LocaLizedText(
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ar': ar,
    };
  }

  @override
  List<Object?> get props => [en, ar];

  String get text => SMText.isEnglish ? en : ar;
}
