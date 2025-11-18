import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/global/shimmer_items.dart';
import 'package:sm_ai_support/src/core/models/anonymous_session_data.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/session_helpers.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/cubit/single_session_cubit.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/features/support/data/support_repo.dart';
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
        else if (state.categories.isNotEmpty) ...[
          ...List.generate(state.categories.length, (index) {
            final category = state.categories[index];
            return _CategoryItem(category: category, isLast: false);
          }),
          // Add logout option if user is authenticated
          if (AuthManager.isAuthenticated) const _LogoutItem(),
        ] else
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

/// Handle category click with complete edge case handling
Future<void> _handleCategoryClick(BuildContext context, CategoryModel category) async {
  try {
    if (!context.mounted) return;

    final isAuthenticated = AuthManager.isAuthenticated;

    // For authenticated users, always create new session (existing behavior)
    if (isAuthenticated) {
      context.smPushFullScreen(ChatPage(category: category, initTicket: true));
      return;
    }

    // For anonymous users, check if there's an existing session
    final sessionData = SharedPrefHelper.getMostRecentActiveSession(category.id);

    if (sessionData == null) {
      // No existing session, create new one
      smPrint('No existing session for category ${category.id}, creating new');
      context.smPushFullScreen(ChatPage(category: category, initTicket: true));
      return;
    }

    // Found existing session - try to load messages silently in background
    smPrint('Found existing session: ${sessionData.sessionId} for category ${category.id}');

    await _loadAndResumeSession(context, category, sessionData);
  } catch (e) {
    smPrint('Error in category click: $e');
    // Silent fallback - always let user continue
    if (context.mounted) {
      context.smPushFullScreen(ChatPage(category: category, initTicket: true));
    }
  }
}

/// Load session messages and handle closed sessions silently
Future<void> _loadAndResumeSession(
  BuildContext context,
  CategoryModel category,
  AnonymousSessionData sessionData,
) async {
  try {
    // Try to load messages for this session (silent background operation)
    final result = await sl<SupportRepo>().getAnonymousMessages(
      sessionId: sessionData.sessionId,
    );

    await result.when(
      success: (messagesResponse) async {
        final messages = messagesResponse.result.messages;

        // Check if session is closed
        if (SessionHelpers.isSessionClosed(messages)) {
          smPrint('Session ${sessionData.sessionId} is closed, attempting to reopen');

          // Try to reopen session silently
          final cubit = SingleSessionCubit(sessionId: sessionData.sessionId);
          final reopened = await cubit.attemptReopenSession(sessionData.sessionId, category.id);
          cubit.close(); // Clean up cubit

          if (reopened) {
            // Reopen successful - continue with this session
            smPrint('Session reopened successfully');
            if (context.mounted) {
              _openChatWithSession(context, category, sessionData.sessionId);
            }
          } else {
            // Reopen failed - open in "create new on send" mode
            smPrint('Session reopen failed, will create new on send');
            if (context.mounted) {
              context.smPushFullScreen(ChatPage(category: category, initTicket: true));
            }
          }
        } else {
          // Session is active and working - resume it
          smPrint('Session is active, resuming');
          if (context.mounted) {
            _openChatWithSession(context, category, sessionData.sessionId);
          }
        }
      },
      error: (error) {
        // API failed (network error, 404, etc.) - silent fallback
        smPrint('Failed to load messages: ${error.failure.error}, falling back to new session');

        // Mark session as failed in storage
        SharedPrefHelper.updateSessionStatus(category.id, sessionData.sessionId, 'failed');

        // Open in "create new session" mode
        if (context.mounted) {
          context.smPushFullScreen(ChatPage(category: category, initTicket: true));
        }
      },
    );
  } catch (e) {
    // Any exception - silent fallback
    smPrint('Exception loading session: $e');
    if (context.mounted) {
      context.smPushFullScreen(ChatPage(category: category, initTicket: true));
    }
  }
}

/// Open chat page with existing session
void _openChatWithSession(BuildContext context, CategoryModel category, String sessionId) {
  context.smPushFullScreen(ChatPage(
    category: category,
    initTicket: false,
    mySession: MySessionModel(
      id: sessionId,
      status: SessionStatus.active,
      createdAt: DateTime.now().toIso8601String(),
      isRatingRequired: false,
      category: category,
      metadata: const MySessionMetadata(
        id: '',
        lastMessageContent: '',
        lastMessageAt: null,
        unreadCount: 0,
      ),
    ),
  ));
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
          onTap: () => _handleCategoryClick(context, category),
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

/// Logout item in the categories list
class _LogoutItem extends StatelessWidget {
  const _LogoutItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: ColorsPallets.disabled25, thickness: 1),
        InkWell(
          onTap: () async {
            try {
              // Call logout to clear token and set isAuthenticated to false
              await AuthManager.logout();

              if (context.mounted) {
                // Close the bottom sheet
                Navigator.of(context).pop();

                // Show success message
                primarySnackBar(
                  context,
                  message: SMText.isEnglish ? "Logged out successfully" : "تم تسجيل الخروج بنجاح",
                );
              }
            } catch (e) {
              smPrint('Error during logout: $e');
              if (context.mounted) {
                primarySnackBar(context, message: SMText.somethingWentWrong);
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.rh),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 24,
                  color: ColorsPallets.secondaryRed100,
                ),
                SizedBox(width: 14.rw),
                Expanded(
                  child: Text(
                    SMText.isEnglish ? "Logout" : "تسجيل الخروج",
                    style: TextStyles.s_13_400.copyWith(color: ColorsPallets.secondaryRed100),
                  ),
                ),
                DesignSystem.arrowLeftOrRight(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
