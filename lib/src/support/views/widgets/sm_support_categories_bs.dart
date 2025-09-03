// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/components/tenant_logo.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/need_auth_bs.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/support/views/chat_page.dart';
import 'package:sm_ai_support/src/support/views/my_all_sessions.dart';

class SMSupportCategoriesBs extends StatefulWidget {
  const SMSupportCategoriesBs({super.key});

  @override
  State<SMSupportCategoriesBs> createState() => _SMSupportCategoriesBsState();
}

class _SMSupportCategoriesBsState extends State<SMSupportCategoriesBs> {
  @override
  void initState() {
    super.initState();
    smCubit.getCategories();
    if (AuthManager.isAuthenticated) {
      smCubit.getMyUnreadSessions();
      // Start the unread sessions count stream for real-time updates
      smCubit.startUnreadSessionsCountStream();
    }
  }

  @override
  void dispose() {
    // Stop the unread sessions count stream when leaving the page
    if (AuthManager.isAuthenticated) {
      smCubit.stopUnreadSessionsCountStream();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SMSupportCubit, SMSupportState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.rw),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.rh),
                __appBar(),
                SizedBox(height: 18.rh),
                DesignSystem.chatGif(),
                SizedBox(height: 10.rh),
                Text(SMText.supportAndHelp, style: TextStyles.s_20_500),
                SizedBox(height: 8.rh),
                Text(
                  SMText.supportAndHelpDescription,
                  style: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400),
                ),
                SizedBox(height: 24.rh),

                __myChats(),
                SizedBox(height: 20.rh),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text(SMText.howCanWeHelpYou, style: TextStyles.s_16_400)],
                ),
                SizedBox(height: 14.rh),

                //! Categories - Fetched from API
                if (state.getCategoriesStatus.isLoading)
                  DesignSystem.loadingIndicator()
                else if (state.getCategoriesStatus.isFailure)
                  Text(
                    SMText.somethingWentWrong,
                    style: TextStyles.s_14_400.copyWith(color: ColorsPallets.secondaryRed100),
                  )
                else if (state.categories.isNotEmpty)
                  ...List.generate(state.categories.length, (index) {
                    final category = state.categories[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            // Use new session-based approach
                            try {
                              if (state.isAuthenticated) {
                                await smCubit.startSession(categoryId: category.id);
                              } else {
                                await smCubit.startAnonymousSession(categoryId: category.id);
                              }

                              // Wait for the state to update and check if session creation was successful
                              // We need to wait a bit for the state to update after the API call
                              await Future.delayed(const Duration(milliseconds: 100));

                              // Get the latest state after the API call
                              final updatedState = smCubit.state;

                              // Only navigate if session creation was successful
                              if (updatedState.startSessionStatus.isSuccess && updatedState.currentSession != null) {
                                if (context.mounted) {
                                  context.smPush(ChatPage(initTicket: true, session: updatedState.currentSession!));
                                }
                              }
                            } catch (e) {
                              smPrint('Error in category tap: $e');
                              // Additional error handling if needed
                              if (context.mounted) {
                                primarySnackBar(context, message: SMText.sessionStartError);
                              }
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.rh),
                            child: Row(
                              children: [
                                DesignSystem.categorySvg(category.icon),
                                SizedBox(width: 14.rw),
                                Expanded(child: Text(category.categoryName, style: TextStyles.s_13_400)),
                                // if loading and start session on this category show loading indicator
                                if (state.startSessionStatus.isLoading && state.startSessionOnCategoryId == category.id)
                                  DesignSystem.loadingIndicator()
                                else
                                  DesignSystem.arrowLeftOrRight(),
                              ],
                            ),
                          ),
                        ),
                        if (index != state.categories.length - 1)
                          Divider(color: ColorsPallets.disabled25, thickness: 1),
                      ],
                    );
                  })
                else
                  Center(
                    child: Text(
                      SMText.isEnglish ? "No categories available" : "لا توجد فئات متاحة",
                      style: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400),
                    ),
                  ),
                SizedBox(height: 30.rh),
              ],
            ),
          ),
        );
      },
    );
  }

  /// My Chats Widget ----------------------
  Widget __myChats() {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        return InkWell(
          onTap: () {
            if (state.isAuthenticated) {
              context.smPush(MySessions());
            } else {
              primaryBottomSheet(showLeadingContainer: true, child: NeedAuthBS());
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 16.rh),
            decoration: BoxDecoration(color: ColorsPallets.primaryColor.withValues(alpha: .05), borderRadius: 12.br),
            child: Row(
              children: [
                DesignSystem.svgIcon(
                  'chat4',
                  color: state.currentTenant?.primaryColor ?? ColorsPallets.primaryColor,
                  size: 22.rSp,
                ),
                SizedBox(width: 6.rw),
                Expanded(
                  child: Text(
                    SMText.myMessages,
                    style: TextStyles.s_14_400.copyWith(color: ColorsPallets.primaryColor),
                  ),
                ),
                if (state.getMyUnreadSessionsStatus.isLoading) ...[
                  DesignSystem.loadingIndicator(),
                ] else if (state.myUnreadSessionsCount != 0) ...[
                  CircleAvatar(
                    radius: 12.rw,
                    backgroundColor: state.currentTenant?.primaryColor ?? ColorsPallets.primaryColor,
                    child: Text(
                      state.myUnreadSessionsCount.toString(),
                      style: TextStyles.s_12_600.copyWith(color: ColorsPallets.white),
                    ),
                  ),
                ] else ...[
                  DesignSystem.arrowLeftOrRight(color: ColorsPallets.primaryColor),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// App Bar Widget ----------------------
  Widget __appBar() {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        final tenant = state.currentTenant;
        final tenantId = tenant?.tenantId ?? '';
        final logoFileName = tenant?.logo;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DesignSystem.closeButton(
              onTap: () {
                SMConfig.parentContext.smParentPop();
              },
            ),
            TenantLogoHelper.small(
              logoFileName: logoFileName,
              tenantId: tenantId,
            ),
          ],
        );
      },
    );
  }
}
