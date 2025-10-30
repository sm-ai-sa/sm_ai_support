import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/days_extensions.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/support/cubit/single_session_cubit.dart';
import 'package:sm_ai_support/src/support/cubit/single_session_state.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_cubit.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/support/views/widgets/messages/message_factory.dart';

/// Individual message item widget with reply functionality and metadata
class ChatMessageItem extends StatelessWidget {
  final SessionMessage message;
  final String sessionId;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.sessionId,
  });

  bool get isMyMessage => message.senderType.isCustomer;
  bool get isSystemMessage => message.contentType.isReopenSession || message.contentType.isCloseSession || message.contentType.isCloseSessionBySystem;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, supportState) {
        final tenantColor = supportState.currentTenant?.primaryColor;
        
        return Padding(
          padding: EdgeInsets.only(bottom: 16.rh),
          child: isMyMessage 
              ? _buildMyMessage(context, tenantColor) 
              : _buildAdminMessage(context, tenantColor),
        );
      },
    );
  }

  /// My message (customer) - aligned to left with reply indicator
  Widget _buildMyMessage(BuildContext context, Color? tenantColor) {
    return Column(
      children: [
        // Reply indicator
        if (message.reply != null && !isSystemMessage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                DesignSystem.svgIcon('replay', size: 14.rh, color: ColorsPallets.disabled300),
                SizedBox(width: 5),
                Text(
                  message.reply?.message ?? '',
                  style: TextStyles.s_13_400.copyWith(color: ColorsPallets.disabled300),
                ),
              ],
            ),
          ),
        
        // Message content
        Row(
          children: [
            if (isSystemMessage)
              Flexible(flex: 2, child: Container(color: tenantColor ?? ColorsPallets.primaryColor, height: 1))
            else if (message.reply != null) ...[
              DesignSystem.svgIcon('curve', width: 19.rw, height: 21.rh),
              SizedBox(width: 8.rw),
            ],
            Flexible(
              flex: 3,
              child: Align(
                alignment: isSystemMessage ? AlignmentDirectional.center : AlignmentDirectional.centerStart,
                child: MessageFactory.createMessageWidget(
                  message: message,
                  isMyMessage: true,
                  sessionId: sessionId,
                  tenantColor: tenantColor,
                ),
              ),
            ),
            if (isSystemMessage)
              Flexible(flex: 2, child: Container(color: tenantColor ?? ColorsPallets.primaryColor, height: 1))
            else
              SizedBox(width: 50.rw),
          ],
        ),
        
        // Timestamp and read status
        if (!isSystemMessage) ...[
          SizedBox(height: 4.rh),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DesignSystem.svgIcon(message.isRead ? 'read' : 'read1', size: 18.rSp),
              SizedBox(width: 4.rw),
              Text(
                '${message.createdAt.monthNameDay}, ${message.createdAt.timeFormat}',
                style: TextStyles.s_10_500.copyWith(color: ColorsPallets.subdued400),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Admin message - aligned to right with reply button
  Widget _buildAdminMessage(BuildContext context, Color? tenantColor) {
    return BlocBuilder<SingleSessionCubit, SingleSessionState>(
      builder: (context, sessionState) {
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: 16.rh),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (isSystemMessage)
                          Flexible(flex: 2, child: Container(color: tenantColor ?? ColorsPallets.primaryColor, height: 1))
                        else
                          SizedBox(width: 50.rw),
                        Flexible(
                          flex: 3,
                          child: InkWell(
                            onLongPress: () {
                              // Set reply on this message
                              context.read<SingleSessionCubit>().setRepliedOn(message.id);
                            },
                            child: Align(
                              alignment: isSystemMessage
                                  ? AlignmentDirectional.center
                                  : AlignmentDirectional.centerEnd,
                              child: MessageFactory.createMessageWidget(
                                message: message,
                                isMyMessage: false,
                                sessionId: sessionId,
                                tenantColor: tenantColor,
                              ),
                            ),
                          ),
                        ),
                        if (isSystemMessage)
                          Flexible(flex: 2, child: Container(color: tenantColor ?? ColorsPallets.primaryColor, height: 1)),
                      ],
                    ),
                    
                    // Timestamp
                    if (!isSystemMessage) ...[
                      SizedBox(height: 4.rh),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${message.createdAt.monthNameDay}, ${message.createdAt.timeFormat}',
                            style: TextStyles.s_10_500.copyWith(color: ColorsPallets.subdued400),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Reply indicator
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                firstChild: Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 16, start: 8, end: 12),
                  child: DesignSystem.svgIcon('replay', size: 17, color: tenantColor ?? ColorsPallets.primaryColor),
                ),
                secondChild: SizedBox.shrink(),
                crossFadeState: sessionState.repliedOn == message.id
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ],
          ),
        );
      },
    );
  }
}

