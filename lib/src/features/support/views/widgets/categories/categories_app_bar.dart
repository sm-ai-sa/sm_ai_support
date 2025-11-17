import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/global/components/tenant_logo.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/shimmer_items.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';

/// App bar with close button and tenant logo
class CategoriesAppBar extends StatelessWidget {
  final bool isDisposed;

  const CategoriesAppBar({super.key, required this.isDisposed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      buildWhen: (previous, current) => !isDisposed,
      builder: (context, state) {
        final tenant = state.currentTenant;
        final tenantId = tenant?.tenantId ?? '';
        final logoFileName = tenant?.logo;
        final isLoadingTenant = state.getTenantStatus.isLoading;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DesignSystem.closeButton(
              onTap: () {
                SMConfig.parentContext.smParentPop();
              },
            ),
            // Show shimmer while loading tenant data
            isLoadingTenant
                ? ShimmerItems.logoShimmer()
                : TenantLogoHelper.small(logoFileName: logoFileName, tenantId: tenantId),
          ],
        );
      },
    );
  }
}
