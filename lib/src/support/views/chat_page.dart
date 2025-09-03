import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/dynamic_network_image.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/components/tenant_logo.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/days_extensions.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/auth/views/login_by_phone.dart';
import 'package:sm_ai_support/src/support/cubit/single_session_state.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/support/views/image_preview.dart';
import 'package:sm_ai_support/src/support/views/widgets/message_input.dart';
import 'package:sm_ai_support/src/support/views/widgets/rate_bs.dart';

class ChatPage extends StatefulWidget {
  final bool initTicket;
  final SessionModel? session;
  final MySessionModel? mySession;

  const ChatPage({super.key, this.session, this.mySession, this.initTicket = false})
    : assert(session != null || mySession != null, 'Either session or mySession must be provided');

  // Convenience getters
  String get sessionId => session?.id ?? mySession?.id ?? '';
  SessionModel get currentSession => session ?? mySession!.toSessionModel();
  CategoryModel? get category => session?.category ?? mySession?.category;
  // bool get isShowRate => true;
  bool get isShowRate => (mySession?.isRatingRequired ?? false) && (mySession?.status.isClosed ?? false);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final String ticketId = Utils.getUID;
  late SingleSessionCubit _sessionCubit;
  bool _streamStarted = false; // Track if stream has been started

  @override
  void initState() {
    super.initState();

    // Initialize SingleSessionCubit
    _sessionCubit = SingleSessionCubit(sessionId: widget.sessionId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(plus: 100);
      if (!widget.initTicket && widget.sessionId.isNotEmpty) {
        // Load session messages
        _sessionCubit.getSessionMessages();
        // Mark messages as read
        _sessionCubit.markMessagesAsRead();
        // Send typing indicator
        // _sessionCubit.sendTypingIndicatorViaWebSocket(true);

        // Start WebSocket stream for real-time messages
        _startMessageStream();
        _streamStarted = true;
      }

      if (widget.isShowRate) {
        primaryBottomSheet(
          showLeadingContainer: true,
          child: RateBS(sessionId: widget.sessionId, sessionCubit: _sessionCubit),
        );
      }
    });
  }

  @override
  void dispose() {
    if (!widget.initTicket && widget.sessionId.isNotEmpty) {
      // Send typing indicator off
      // _sessionCubit.sendTypingIndicatorViaWebSocket(false);
      // Stop message stream
      _sessionCubit.stopMessageStream();
    }
    _sessionCubit.close();
    super.dispose();
  }

  void _scrollToBottom({double plus = 0}) {
    if (_scrollController.hasClients) {
      // Check if content is scrollable (messages exceed screen height)
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      // Only scroll if there's actually content to scroll to
      if (maxScrollExtent > 0) {
        _scrollController.animateTo(
          maxScrollExtent + plus,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// Start WebSocket message stream for real-time messaging
  void _startMessageStream() {
    try {
      // Get tenant ID from SMSupportCubit
      final smSupportCubit = context.read<SMSupportCubit>();
      final tenantId = smSupportCubit.state.currentTenant?.tenantId;

      if (tenantId == null) {
        smPrint('Cannot start message stream: tenantId is null');
        return;
      }

      // Get customer ID if authenticated
      final customerId = AuthManager.isAuthenticated ? AuthManager.currentCustomer?.id : null;

      smPrint('Starting message stream - TenantId: $tenantId, SessionId: ${widget.sessionId}, CustomerId: $customerId');

      // Start the WebSocket stream
      _sessionCubit.startMessageStream(tenantId: tenantId, customerId: customerId);
    } catch (e) {
      smPrint('Error starting message stream: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _sessionCubit)],
      child: Scaffold(
        backgroundColor: ColorsPallets.white,
        extendBody: true,
        appBar: __appBar(),
        body: Column(
          children: [
            DesignSystem.primaryDivider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 22.rw),
              child: BlocBuilder<SMSupportCubit, SMSupportState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      DesignSystem.categorySvg(widget.category?.icon ?? '', width: 24.rSp, height: 24.rSp),
                      SizedBox(width: 14.rw),
                      Expanded(
                        child: Text(
                          widget.category?.description ?? 'General Support',
                          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.normal500),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            DesignSystem.primaryDivider(),
            __messagesList(),
            DesignSystem.primaryDivider(),
            BlocBuilder<SMSupportCubit, SMSupportState>(
              builder: (context, state) {
                final sessionStatus = widget.currentSession.status;
                return Column(
                  children: [
                    Visibility(
                      visible: (widget.initTicket || sessionStatus.isActive) && !widget.isShowRate,
                      child: MessageInput(
                        sessionId: widget.sessionId,
                        ticketId: ticketId,
                        initTicket: widget.initTicket,
                        onSend: (isSuccess) {
                          if (isSuccess) {
                            _scrollToBottom();
                            // Start stream after first message is sent (for new sessions)
                            // Only start once to prevent multiple connections
                            if (widget.initTicket && !_streamStarted) {
                              _startMessageStream();
                              _streamStarted = true;
                            }
                          }
                        },
                      ),
                    ),
                    Visibility(
                      visible: !widget.initTicket && widget.isShowRate,
                      child: InkWell(
                        onTap: () {
                          primaryBottomSheet(
                            showLeadingContainer: true,
                            child: RateBS(sessionId: widget.sessionId, sessionCubit: _sessionCubit),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30, top: 20),
                          child: Text(SMText.rateTheConversation, style: TextStyles.s_20_400),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget __messagesList() {
    return BlocConsumer<SingleSessionCubit, SingleSessionState>(
      listener: (context, sessionState) {
        // Auto-scroll when new messages arrive
        if (sessionState.sessionMessages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      },
      builder: (context, sessionState) {
        if (sessionState.getSessionMessagesStatus.isLoading) {
          return Expanded(child: Center(child: DesignSystem.loadingIndicator()));
        }

        final messagesList = sessionState.sessionMessages;
        return Expanded(
          child: ListView(
            controller: _scrollController,
            addAutomaticKeepAlives: false,
            padding: EdgeInsets.symmetric(horizontal: 22.rw).copyWith(bottom: 20.rh),
            children: [
              if (messagesList.isEmpty) ...[__emptyMessages()],
              SizedBox(height: 16.rh),
              ...messagesList.map((message) {
                return message.senderType.isCustomer ? _myMessage(message) : _adminMessage(message);
              }),
            ],
          ),
        );
      },
    );
  }

  // My Message item on the right
  Widget _myMessage(SessionMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.rh),
      child: Column(
        children: [
          Visibility(
            visible: message.reply != null,
            child: Padding(
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
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.reply != null) ...[
                DesignSystem.svgIcon(
                  'curve',
                  width: 19.rw,
                  height: 21.rh,
                  // color: ColorsPallets.disabled300,
                ),
                SizedBox(width: 8.rw),
              ],
              Flexible(
                child: Align(alignment: AlignmentDirectional.centerStart, child: _messageBasedOnType(message, true)),
              ),
              SizedBox(width: 50.rw),
            ],
          ),
          SizedBox(height: 4.rh),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // if (message.isHolderMessage) ...[
              //   Icon(Icons.watch_later_outlined, size: 12.rSp, color: ColorsPallets.subdued400),
              // ] else ...[

              // ],
              DesignSystem.svgIcon(
                // Message marked as read (read) else (read1)
                message.isRead ? 'read' : 'read1',
                size: 18.rSp,
              ),
              SizedBox(width: 4.rw),
              Text(
                '${message.createdAt.monthNameDay}, ${message.createdAt.timeFormat}',
                style: TextStyles.s_10_500.copyWith(color: ColorsPallets.subdued400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  admin response item on left
  Widget _adminMessage(SessionMessage message) {
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
                        if (message.contentType.isReopenSession || message.contentType.isCloseSession)
                          Flexible(child: Container(color: ColorsPallets.primaryColor, height: 1))
                        else
                          SizedBox(width: 50.rw),
                        Flexible(
                          child: InkWell(
                            onLongPress: () {
                              // Set reply on this message
                              _sessionCubit.setRepliedOn(message.id);
                            },
                            child: Align(
                              alignment: (message.contentType.isReopenSession || message.contentType.isCloseSession)
                                  ? AlignmentDirectional.center
                                  : AlignmentDirectional.centerEnd,
                              child: _messageBasedOnType(message, false),
                            ),
                          ),
                        ),
                        if (message.contentType.isReopenSession || message.contentType.isCloseSession)
                          Flexible(child: Container(color: ColorsPallets.primaryColor, height: 1)),
                      ],
                    ),
                    if (!(message.contentType.isReopenSession || message.contentType.isCloseSession)) ...[
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
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                firstChild: Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 16, start: 8, end: 12),
                  child: DesignSystem.svgIcon('replay', size: 17, color: ColorsPallets.primaryColor),
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

  Widget __emptyMessages() {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        final tenant = state.currentTenant;
        final tenantId = tenant?.tenantId ?? '';
        final logoFileName = tenant?.logo;

        return Column(
          children: [
            SizedBox(height: 140.rh),
            TenantLogoHelper.standard(logoFileName: logoFileName, tenantId: tenantId, size: 80),
            SizedBox(height: 20.rh),
            Text(SMText.startChat, style: TextStyles.s_20_400),
            SizedBox(height: 8.rh),
            // Text(SMText.startChatDescription, style: TextStyles.s_20_400.copyWith(color: ColorsPallets.black)),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 7),
            //   margin: EdgeInsets.symmetric(horizontal: 22.rw),
            //   decoration: BoxDecoration(color: ColorsPallets.disabled0, borderRadius: 12.br),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Text(SMText.workingHoursFrom, style: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400)),
            //       SizedBox(width: 8.rw),
            //       Text(
            //         '09:00 - 17:00',
            //         textDirection: TextDirection.ltr,
            //         style: TextStyles.s_14_500.copyWith(
            //           color: ColorsPallets.subdued400,
            //           fontFamily: SMSupportTheme.sansFamily,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget __appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      leading: Row(
        children: [
          SizedBox(width: 22.rw),
          DesignSystem.backButton(color: ColorsPallets.loud900),
        ],
      ),
      leadingWidth: 50.rw,
      centerTitle: false,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 100, tileMode: TileMode.mirror),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(SMText.supportAndHelp, style: TextStyles.s_16_400),

          Text(SMText.online, style: TextStyles.s_12_400.copyWith(color: ColorsPallets.secondaryGreen100)),
        ],
      ),
    );
  }

  Widget _messageBasedOnType(SessionMessage message, bool isMyMessage) {
    if (message.contentType.isNeedAuth) {
      return _buildNeedAuthMessage(message, isMyMessage);
    } else if (message.contentType.isAuthorized || message.contentType.isUnauthorized) {
      return _buildAuthResultMessage(message, isMyMessage);
    } else if (message.contentType.isImage) {
      return _buildImageMessage(message, isMyMessage);
    } else if (message.contentType.isAudio) {
      return _buildAudioMessage(message, isMyMessage);
    } else if (message.contentType.isReopenSession || message.contentType.isCloseSession) {
      return _buildReopenCloseMessage(message, isMyMessage);
    }
    // return _buildNeedAuthMessage(message, isMyMessage);
    return _buildTextMessage(message, isMyMessage);
  }

  //! Build Message based on type
  //! Text Message
  Widget _buildTextMessage(SessionMessage message, bool isMyMessage) {
    return Container(
      padding: EdgeInsets.all(10.rSp),
      decoration: BoxDecoration(
        color: isMyMessage ? ColorsPallets.normal25 : ColorsPallets.primaryColor.withValues(alpha: .9),
        border: Border.all(color: isMyMessage ? ColorsPallets.borderColor : ColorsPallets.primaryColor),
        borderRadius: 12.br,
      ),
      child: Text(message.content, style: TextStyles.s_13_400.copyWith(color: ColorsPallets.muted600)),
    );
  }

  //! Image Message
  Widget _buildImageMessage(SessionMessage message, bool isMyMessage) {
    return InkWell(
      onTap: () async {
        // Resolve the image URL before opening preview
        String? imageUrl = message.content;

        // If it's not a direct URL, resolve it first
        if (!ImageUrlResolver.isDirectDownloadUrl(message.content)) {
          final fileName = ImageUrlResolver.extractFileName(message.content);
          imageUrl = await ImageUrlResolver.resolveImageUrl(
            fileName: fileName,
            sessionId: widget.sessionId,
            category: FileUploadCategory.messageImage,
          );
        }

        if (imageUrl != null && context.mounted) {
          context.smPush(ImagePreview(imageUrl: imageUrl));
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.rSp),
        decoration: BoxDecoration(
          color: isMyMessage ? ColorsPallets.normal25 : ColorsPallets.primary0,
          border: Border.all(color: isMyMessage ? ColorsPallets.borderColor : ColorsPallets.primary25),
          borderRadius: 12.br,
        ),
        child: DynamicNetworkImage(
          imageSource: message.content,
          sessionId: widget.sessionId,
          width: 200.rw,
          height: 150.rh,
          fit: BoxFit.cover,
          borderRadius: 8.br,
          category: FileUploadCategory.messageImage,
        ),
      ),
    );
  }

  //! Audio Message
  Widget _buildAudioMessage(SessionMessage message, bool isMyMessage) {
    return Container(
      padding: EdgeInsets.all(10.rSp),
      decoration: BoxDecoration(
        color: isMyMessage ? ColorsPallets.normal25 : ColorsPallets.primary0,
        border: Border.all(color: isMyMessage ? ColorsPallets.borderColor : ColorsPallets.primary25),
        borderRadius: 12.br,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Audio icon
          Container(
            padding: EdgeInsets.all(8.rSp),
            decoration: BoxDecoration(color: ColorsPallets.primary25, borderRadius: 8.br),
            child: Icon(Icons.play_arrow, color: ColorsPallets.primary300, size: 20.rSp),
          ),
          SizedBox(width: 12.rw),
          // Audio info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Audio Message', style: TextStyles.s_13_500.copyWith(color: ColorsPallets.muted600)),
                SizedBox(height: 2.rh),
                Text('Tap to play', style: TextStyles.s_11_400.copyWith(color: ColorsPallets.subdued400)),
              ],
            ),
          ),
          // Download/Play button
          InkWell(
            onTap: () async {
              // Resolve the audio URL and handle playback
              await _handleAudioPlayback(message.content);
            },
            child: Container(
              padding: EdgeInsets.all(6.rSp),
              decoration: BoxDecoration(color: ColorsPallets.primary25, borderRadius: 6.br),
              child: Icon(Icons.download, color: ColorsPallets.primary300, size: 16.rSp),
            ),
          ),
        ],
      ),
    );
  }

  //! Reopen Close Message
  Widget _buildReopenCloseMessage(SessionMessage message, bool isMyMessage) {
    return Text(
      message.contentType.isCloseSession ? SMText.closedSessions : SMText.reopenSession,
      style: TextStyles.s_13_400.copyWith(color: ColorsPallets.primaryColor),
      textAlign: TextAlign.center,
    );
  }

  /// Handle audio playback - resolves URL if needed and opens audio player
  Future<void> _handleAudioPlayback(String audioSource) async {
    try {
      String? audioUrl = audioSource;

      // If it's not a direct URL, resolve it first
      if (!ImageUrlResolver.isDirectDownloadUrl(audioSource)) {
        final fileName = ImageUrlResolver.extractFileName(audioSource);
        audioUrl = await ImageUrlResolver.resolveMediaUrl(
          fileName: fileName,
          sessionId: widget.sessionId,
          category: FileUploadCategory.sessionAudio,
        );
      }

      if (audioUrl != null) {
        smPrint('Audio URL resolved: $audioUrl');
        // TODO: Implement audio player or external app opening
        // For now, we'll just print the URL
        // You could use url_launcher to open with external app:
        // await launchUrl(Uri.parse(audioUrl));
      } else {
        smPrint('Failed to resolve audio URL');
      }
    } catch (e) {
      smPrint('Error handling audio playback: $e');
    }
  }

  //! Need Auth Message
  Widget _buildNeedAuthMessage(SessionMessage message, bool isMyMessage) {
    return InkWell(
      onTap: () {
        primaryCupertinoBottomSheet(child: LoginByPhone(isCreateAccount: false, sessionId: widget.sessionId));
      },
      child: Container(
        padding: EdgeInsets.all(10.rSp),
        decoration: BoxDecoration(
          color: ColorsPallets.yellow0,
          border: Border.all(color: ColorsPallets.yellow25),
          borderRadius: 12.br,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              SMText.confirmIdentityToCompleteTheProcess,
              style: TextStyles.s_13_400.copyWith(color: ColorsPallets.yellow300),
            ),
            SizedBox(width: 8.rw),
            DesignSystem.svgIcon('arrow-left', size: 17, color: ColorsPallets.yellow300),
          ],
        ),
      ),
    );
  }

  //! Auth Result Message
  Widget _buildAuthResultMessage(SessionMessage message, bool isMyMessage) {
    bool isAuthSuccess = message.contentType.isAuthorized;
    return Container(
      padding: EdgeInsets.all(10.rSp),
      decoration: BoxDecoration(
        color: isAuthSuccess ? ColorsPallets.green0 : ColorsPallets.red0,
        border: Border.all(color: isAuthSuccess ? ColorsPallets.green25 : ColorsPallets.red25),
        borderRadius: 12.br,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DesignSystem.svgIcon(
            isAuthSuccess ? 'check' : 'close',
            size: 17,
            color: isAuthSuccess ? ColorsPallets.green300 : ColorsPallets.red300,
          ),
          SizedBox(width: 8.rw),
          Text(
            isAuthSuccess ? SMText.identityConfirmed : SMText.identityNotConfirmed,
            style: TextStyles.s_13_400.copyWith(color: isAuthSuccess ? ColorsPallets.green300 : ColorsPallets.red300),
          ),
        ],
      ),
    );
  }
}
