import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/days_extensions.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/support/views/chat_page.dart';

class SessionItem extends StatelessWidget {
  const SessionItem({super.key, required this.session, this.isLast = false});

  final MySessionModel session;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Get the current session from SMSupportCubit state to ensure we have the latest data
      
        final currentSession = smCubit.state.mySessions.firstWhereOrNull((s) => s.id == session.id) ?? session;

        context.smPush(ChatPage(mySession: currentSession, category: currentSession.category));
      },
      child: BlocBuilder<SMSupportCubit, SMSupportState>(
        builder: (context, state) {
          // final lastMessage = state.getChatMessages(ticket.ticketId).last;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.rh),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignSystem.categorySvg(
                      session.category.categoryIcon,
                      color: session.status.isGeneralClosed ? ColorsPallets.disabled300 : null,
                    ),
                    SizedBox(width: 14.rw),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.category.categoryName,
                            style: TextStyles.s_13_500.copyWith(
                              color: session.status.isGeneralClosed ? ColorsPallets.disabled300 : null,
                            ),
                          ),
                          SizedBox(height: 4.rh),
                          // Show last message content or attachment indicator
                          _buildLastMessageContent(),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.rw),
                    Visibility(
                      //* is Active & there is unread messages
                      visible: (session.status.isActive && session.metadata.unreadCount > 0),
                      child: CircleAvatar(
                        radius: 12.rw,
                        backgroundColor: ColorsPallets.primaryColor,
                        child: Text(
                          session.metadata.unreadCount.toString(),
                          style: TextStyles.s_12_600.copyWith(color: ColorsPallets.white),
                        ),
                      ),
                    ),
                    Visibility(
                      //* is Active & there is no-unread messages
                      visible: (session.status.isActive && session.metadata.unreadCount == 0),
                      child: Text(
                        session.metadata.lastMessageAt?.timeAgo() ?? '',
                        textDirection: smCubit.state.currentLocale == 'en' ? TextDirection.ltr : TextDirection.rtl,
                        style: TextStyles.s_14_400.copyWith(
                          color: ColorsPallets.subdued400,
                          fontFamily: SMSupportTheme.sansFamily,
                        ),
                      ),
                    ),
                    Visibility(
                      //* closed chat
                      visible: session.status.isGeneralClosed,
                      child: BlocBuilder<SMSupportCubit, SMSupportState>(
                        builder: (context, state) {
                         

                          return (state.reopenSessionStatus.isLoading && state.reopenSessionId == session.id)
                              ? DesignSystem.loadingIndicator()
                              : InkWell(
                                  onTap: () async {
                                    await smCubit.reopenSession(session.id);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        SMText.reopen,
                                        style: TextStyles.s_14_400.copyWith(color: ColorsPallets.primaryColor),
                                      ),
                                      SizedBox(width: 6.rw),
                                      DesignSystem.svgIcon('reload', size: 16.rSp, color: ColorsPallets.primaryColor),
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: ColorsPallets.disabled25, thickness: 1),
            ],
          );
        },
      ),
    );
  }

  /// Build last message content with attachment indicator for non-text messages
  Widget _buildLastMessageContent() {
    final content = session.metadata.lastMessageContent;

    // Check if content is empty
    if (content.isEmpty) {
      return Text('No messages yet', style: TextStyles.s_12_400.copyWith(color: ColorsPallets.disabled300));
    }

    // Check if the content is a URL (indicates media message)
    final isImageUrl = Utils.isImageUrl(content);
    final isAudioUrl = content.toLowerCase().endsWith('.mp3') || content.toLowerCase().endsWith('.wav');
    final isMediaUrl = isImageUrl || isAudioUrl;

    if (isMediaUrl) {
      // Show attachment indicator for media messages
      return Row(
        children: [
          DesignSystem.svgIcon('attach', size: 16.rSp),
          SizedBox(width: 6.rw),
          Text(SMText.attached, style: TextStyles.s_11_400.copyWith(color: ColorsPallets.disabled300)),
        ],
      );
    } else {
      // Show regular text content
      return Text(
        content,
        style: TextStyles.s_12_400.copyWith(
          color: (session.status.isActive && session.metadata.unreadCount > 0)
              ? ColorsPallets.primaryColor
              : ColorsPallets.disabled300,
        ),
      );
    }
  }
}
