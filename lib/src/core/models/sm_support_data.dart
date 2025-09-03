import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/src/core/utils/enums.dart';

///* `SMSupportData` contains the basic configuration needed to initialize the support package
class SMSupportData extends Equatable {
  ///* Name of your application
  final String appName;

  ///* Locale of gateway
  final SMSupportLocale locale;

  ///* Tenant ID to fetch tenant-specific configuration
  final String tenantId;

  ///* Data constructor for `SMSupportData` with required parameters only
  const SMSupportData({
    required this.appName,
    required this.locale,
    required this.tenantId,
  });

  @override
  List<Object?> get props => [appName, locale, tenantId];
}
