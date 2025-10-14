import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/support/views/widgets/sm_support_categories_bs.dart';

import 'src/core/utils/extension/size_extension.dart';

class SMSupportViewHandler extends StatefulWidget {
  const SMSupportViewHandler({super.key});

  @override
  State<SMSupportViewHandler> createState() => _SMSupportViewHandlerState();
}

class _SMSupportViewHandlerState extends State<SMSupportViewHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewHandler());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: DesignSystem.loadingIndicator(color: ColorsPallets.white),
    );
  }

  Future _viewHandler() async {
    ScreenSizes.init(context);

    // Initialize authentication and fetch tenant data
    // await sl<AuthCubit>().initializeAuth();
     await AuthManager.init();
    await smCubit.getTenant(tenantId: SMConfig.smData.tenantId);

    primaryCupertinoBottomSheet(
      enableDragDismiss: false,
      isDismissible: false,
      height: 95.h,
      child: const SMSupportCategoriesBs(),
    );
  }
}
