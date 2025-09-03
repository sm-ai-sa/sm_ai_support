import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_support_view_handler.dart';
import 'package:sm_ai_support/src/constant/locale.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';
import 'package:sm_ai_support/src/core/models/sm_support_data.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_cubit.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_state.dart';

final smNavigatorKey = GlobalKey<NavigatorState>();

class SMSupport extends StatefulWidget {
  ///* Provide the context of the app
  final BuildContext parentContext;

  ///* SM Support Data to be used in the SM Support
  final SMSupportData smSupportData;

  const SMSupport({super.key, required this.parentContext, required this.smSupportData});

  @override
  State<SMSupport> createState() => _SMSupportState();
}

class _SMSupportState extends State<SMSupport> {
  @override
  void initState() {
    super.initState();
    initSL();
    SMConfig.initSMSupportData(appContext: widget.parentContext, data: widget.smSupportData);
    
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
          navigatorKey: smNavigatorKey,
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
