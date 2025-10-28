import 'package:flutter/material.dart';

import '../../constant/locale.dart';

enum SMSupportLocale {
  ar,
  en;

  /// Get current locale `ar_SA` or `en_US`
  Locale get currentLocale =>
      this == SMSupportLocale.ar ? LocalizationsData.supportLocale.first : LocalizationsData.supportLocale.last;

  /// Check if the locale is `Arabic`
  bool get isArabic => this == SMSupportLocale.ar;

  /// Check if the locale is `English`
  bool get isEnglish => this == SMSupportLocale.en;

  /// Get the locale code
  String get localeCode {
    switch (this) {
      case SMSupportLocale.ar:
        return "ar";
      case SMSupportLocale.en:
        return "en";
    }
  }

  /// from string
  static SMSupportLocale fromString(String locale) {
    switch (locale) {
      case "ar":
        return SMSupportLocale.ar;
      case "en":
        return SMSupportLocale.en;
      default:
        return SMSupportLocale.ar;
    }
  }
}

enum SMSupportCountry { sa }

extension SMPayCountryExt on SMSupportCountry {
  String get countryCode {
    switch (this) {
      case SMSupportCountry.sa:
        return "SA";
    }
  }
}

enum TicketStatus {
  active,
  closed;

  bool get isActive => this == TicketStatus.active;
  bool get isClosed => this == TicketStatus.closed;

  static TicketStatus fromString(String status) {
    if (status == 'active') {
      return TicketStatus.active;
    } else if (status == 'closed') {
      return TicketStatus.closed;
    } else {
      return TicketStatus.active;
    }
  }
}

enum BaseStatus { initial, loading, success, failure }

extension StringX on String {
  BaseStatus toBaseStatus() {
    switch (this) {
      case 'initial':
        return BaseStatus.initial;
      case 'loading':
        return BaseStatus.loading;
      case 'success':
        return BaseStatus.success;
      case 'failure':
        return BaseStatus.failure;
      default:
        return BaseStatus.initial;
    }
  }
}

extension BaseStatusX on BaseStatus {
  bool get isInitial => this == BaseStatus.initial;

  bool get isLoading => this == BaseStatus.loading;

  bool get isSuccess => this == BaseStatus.success;

  bool get isFailure => this == BaseStatus.failure;
}

enum MediaType {
  image,
  video,
  file,
  other;

  bool get isImage => this == MediaType.image;

  bool get isVideo => this == MediaType.video;

  bool get isFile => this == MediaType.file;

  bool get isOther => this == MediaType.other;
}

enum ChangedBy {
  customer,
  admin;

  bool get isCustomer => this == ChangedBy.customer;
  bool get isAdmin => this == ChangedBy.admin;

  static ChangedBy fromString(String changedBy) {
    switch (changedBy) {
      case "customer":
        return ChangedBy.customer;
      case "admin":
        return ChangedBy.admin;
      default:
        return ChangedBy.customer;
    }
  }
}

enum GeneralStatus {
  active,
  deleted;

  bool get isActive => this == GeneralStatus.active;
  bool get isDeleted => this == GeneralStatus.deleted;

  static GeneralStatus fromString(String status) {
    if (status == 'active') {
      return GeneralStatus.active;
    } else if (status == 'deleted') {
      return GeneralStatus.deleted;
    } else {
      return GeneralStatus.active;
    }
  }
}

enum SessionStatus {
  active,
  closed,
  failed;

  bool get isActive => this == SessionStatus.active;
  bool get isClosed => this == SessionStatus.closed;
  bool get isFailed => this == SessionStatus.failed;

  static SessionStatus fromString(String status) {
    return SessionStatus.values.firstWhere((e) => e.name == status.toLowerCase());
  }
}

// "ADMIN", "CUSTOMER", "SYSTEM", "BOT"
enum SessionMessageSenderType {
  admin,
  customer,
  system,
  bot;

  bool get isAdmin => this == SessionMessageSenderType.admin;
  bool get isCustomer => this == SessionMessageSenderType.customer;
  bool get isSystem => this == SessionMessageSenderType.system;
  bool get isBot => this == SessionMessageSenderType.bot;

  static SessionMessageSenderType fromString(String senderType) {
    return SessionMessageSenderType.values.firstWhere((e) => e.name == senderType.toLowerCase());
  }
}

enum SessionMessageContentType {
  text,
  audio,
  image,
  video,
  file,
  assignment,
  closeSession,
  reopenSession,
  closeSessionBySystem,
  authorized,
  unauthorized,
  needAuth,
  unsupportedMedia;

  bool get isText => this == SessionMessageContentType.text;
  bool get isAudio => this == SessionMessageContentType.audio;
  bool get isImage => this == SessionMessageContentType.image;
  bool get isVideo => this == SessionMessageContentType.video;
  bool get isFile => this == SessionMessageContentType.file;
  bool get isAssignment => this == SessionMessageContentType.assignment;
  bool get isCloseSession => this == SessionMessageContentType.closeSession;
  bool get isReopenSession => this == SessionMessageContentType.reopenSession;
  bool get isCloseSessionBySystem => this == SessionMessageContentType.closeSessionBySystem;
  bool get isAuthorized => this == SessionMessageContentType.authorized;
  bool get isUnauthorized => this == SessionMessageContentType.unauthorized;
  bool get isNeedAuth => this == SessionMessageContentType.needAuth;
  bool get isUnsupportedMedia => this == SessionMessageContentType.unsupportedMedia;

  static SessionMessageContentType fromString(String contentType) {
    return switch (contentType.toUpperCase()) {
      'TEXT' => SessionMessageContentType.text,
      'AUDIO' => SessionMessageContentType.audio,
      'IMAGE' => SessionMessageContentType.image,
      'VIDEO' => SessionMessageContentType.video,
      'FILE' => SessionMessageContentType.file,
      'ASSIGNMENT' => SessionMessageContentType.assignment,
      'CLOSE_SESSION' => SessionMessageContentType.closeSession,
      'REOPEN_SESSION' => SessionMessageContentType.reopenSession,
      'CLOSE_SESSION_BY_SYSTEM' => SessionMessageContentType.closeSessionBySystem,
      'AUTHORIZED' => SessionMessageContentType.authorized,
      'UNAUTHORIZED' => SessionMessageContentType.unauthorized,
      'NEED_AUTH' => SessionMessageContentType.needAuth,
      'UNSUPPORTED_MEDIA' => SessionMessageContentType.unsupportedMedia,
      _ => SessionMessageContentType.text,
    };
  }
}
