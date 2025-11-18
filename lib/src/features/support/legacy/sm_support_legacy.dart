import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/sm_support_view_handler.dart';
import 'package:sm_ai_support/src/constant/locale.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';

/// Legacy full-screen mode for SM Support
/// This mode creates a new MaterialApp and pushes a full screen
/// Kept for backward compatibility
class SMSupportLegacy extends StatefulWidget {
  ///* Provide the context of the app
  final BuildContext parentContext;

  ///* SM Support Data to be used in the SM Support
  final SMSupportData smSupportData;

  const SMSupportLegacy({
    super.key,
    required this.parentContext,
    required this.smSupportData,
  });

  @override
  State<SMSupportLegacy> createState() => _SMSupportLegacyState();
}

class _SMSupportLegacyState extends State<SMSupportLegacy> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final parentContext = widget.parentContext;
    final supportData = widget.smSupportData;

    await initSL();
    await SMConfig.initSMSupportData(appContext: parentContext, data: supportData);

    // Initialize SharedPreferences and authentication
    await AuthManager.init();

    // Initialize default country first to prevent crashes
    initializeDefaultCountry();

    // Load full countries list asynchronously
    getCountries();
  }

  @override
  Widget build(BuildContext context) {
    final smSupportData = widget.smSupportData;
    SMText.isEnglish = smSupportData.locale.isEnglish;

    return BlocProvider.value(
      value: smCubit,
      child: BlocListener<SMSupportCubit, SMSupportState>(
        listener: (context, state) {
          // Update primary color when tenant data is loaded
          if (state.currentTenant != null) {
            ColorsPallets.primaryColor = state.currentTenant?.primaryColor ?? ColorsPallets.primaryColor;
          } else {
            // Use fallback color from SMSupportData
            ColorsPallets.primaryColor = ColorsPallets.primaryColor;
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: LocalizationsData.localizationsDelegate,
          supportedLocales: LocalizationsData.supportLocale,
          theme: SMSupportTheme.theme,
          locale: widget.smSupportData.locale.currentLocale,
          home: const SMSupportViewHandler(),
        ),
      ),
    );
  }
}
