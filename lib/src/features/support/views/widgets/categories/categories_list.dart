import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/global/shimmer_items.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/features/support/views/chat_page.dart';

/// List of support categories with shimmer loading
class CategoriesList extends StatelessWidget {
  final SMSupportState state;

  const CategoriesList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(SMText.howCanWeHelpYou, style: TextStyles.s_16_400),
        SizedBox(height: 14.rh),

        // Categories with shimmer loading
        if (state.getCategoriesStatus.isLoading)
          ...List.generate(
            6,
            (index) => ShimmerItems.categoryShimmer(
              showDivider: index != 5, // Hide divider on last item
            ),
          )
        else if (state.getCategoriesStatus.isFailure)
          Text(
            SMText.somethingWentWrong,
            style: TextStyles.s_14_400.copyWith(color: ColorsPallets.secondaryRed100),
          )
        else if (state.categories.isNotEmpty)
          ...List.generate(state.categories.length, (index) {
            final category = state.categories[index];
            return _CategoryItem(category: category, isLast: index == state.categories.length - 1);
          })
        else
          Center(
            child: Text(
              SMText.isEnglish ? "No categories available" : "لا توجد فئات متاحة",
              style: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400),
            ),
          ),
      ],
    );
  }
}

/// Individual category item
class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isLast;

  const _CategoryItem({required this.category, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            // Navigate to chat page in full screen
            try {
              if (context.mounted) {
                context.smPushFullScreen(ChatPage(category: category, initTicket: true));
              }
            } catch (e) {
              smPrint('Error in category navigation: $e');
              if (context.mounted) {
                primarySnackBar(context, message: SMText.somethingWentWrong);
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.rh),
            child: Row(
              children: [
                DesignSystem.categorySvg(category.categoryIcon),
                SizedBox(width: 14.rw),
                Expanded(child: Text(category.categoryName, style: TextStyles.s_13_400)),
                DesignSystem.arrowLeftOrRight(),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(color: ColorsPallets.disabled25, thickness: 1),
      ],
    );
  }
}
