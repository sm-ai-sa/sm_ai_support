import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/constant/locale.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/sm_support_categories_bs.dart';

/// Internal bottom sheet widget that displays support interface within parent app context
class SMSupportBottomSheet extends StatefulWidget {
  final SMSupportData smSupportData;

  const SMSupportBottomSheet({super.key, required this.smSupportData});

  @override
  State<SMSupportBottomSheet> createState() => _SMSupportBottomSheetState();
}

class _SMSupportBottomSheetState extends State<SMSupportBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Initialize asynchronously in the background
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    // Critical initialization is already done in SMSupport.show()
    // Only fetch tenant data here (this will trigger shimmer to disappear)
    if (!mounted) return;
    await smCubit.getTenant(tenantId: widget.smSupportData.tenantId);
  }

  @override
  void dispose() {
    // Clean up when bottom sheet is dismissed
    // This is crucial to prevent ScrollController errors
    try {
      // Stop any active streams
      if (AuthManager.isAuthenticated) {
        smCubit.stopUnreadSessionsCountStream();
      }
    } catch (e) {
      // Silently handle disposal errors
      smPrint('Error during bottom sheet disposal: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSizes.init(context);

    // Get text direction based on locale
    final textDirection = widget.smSupportData.locale.isEnglish ? TextDirection.ltr : TextDirection.rtl;
    final locale = widget.smSupportData.locale.currentLocale;

    return SizedBox(
      // height: MediaQuery.of(context).size.height * 0.94, // 94% of screen height
      child: BlocProvider.value(
        value: smCubit,
        child: BlocListener<SMSupportCubit, SMSupportState>(
          listener: (context, state) {
            // Update primary color when tenant data is loaded
            if (state.currentTenant != null) {
              ColorsPallets.primaryColor = state.currentTenant?.primaryColor ?? ColorsPallets.primaryColor;
            }
          },
          child: Directionality(
            textDirection: textDirection,
            child: Localizations(
              locale: locale,
              delegates: LocalizationsData.localizationsDelegate,
              child: Navigator(
                key: smNavigatorKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: Scaffold(
                        backgroundColor: ColorsPallets.white,
                        body: const SMSupportCategoriesBs(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
