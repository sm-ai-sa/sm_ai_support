// import 'dart:ui';

// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sm_ai_support/sm_ai_support.dart';
// import 'package:sm_ai_support/src/core/global/components/dynamic_network_image.dart';
// import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
// import 'package:sm_ai_support/src/core/global/components/tenant_logo.dart';
// import 'package:sm_ai_support/src/core/global/design_system.dart';
// import 'package:sm_ai_support/src/core/theme/colors.dart';
// import 'package:sm_ai_support/src/core/theme/styles.dart';
// import 'package:sm_ai_support/src/core/utils/extension.dart';
// import 'package:sm_ai_support/src/core/utils/extension/days_extensions.dart';
// import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
// import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
// import 'package:sm_ai_support/src/core/utils/utils.dart';
// import 'package:sm_ai_support/src/features/auth/views/login_by_phone.dart';
// import 'package:sm_ai_support/src/features/support/cubit/single_session_state.dart';
// import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
// import 'package:sm_ai_support/src/features/support/views/image_preview.dart';
// import 'package:sm_ai_support/src/features/support/views/widgets/message_input.dart';
// import 'package:sm_ai_support/src/features/support/views/widgets/messages/file_message_widget.dart';
// import 'package:sm_ai_support/src/features/support/views/widgets/messages/system_action_message_widget.dart';
// import 'package:sm_ai_support/src/features/support/views/widgets/messages/text_message_widget.dart';
// import 'package:sm_ai_support/src/features/support/views/widgets/messages/unsupported_media_widget.dart';
// import 'package:sm_ai_support/src/features/support/views/widgets/messages/video_message_widget.dart';
// import 'package:sm_ai_support/src/features/support/views/widgets/rate_bs.dart';

// class ChatPage extends StatefulWidget {
//   final bool initTicket;
//   final SessionModel? session;
//   final MySessionModel? mySession;
//   final CategoryModel? category;

//   const ChatPage({super.key, this.session, this.mySession, this.category, this.initTicket = false})
//     : assert(
//         session != null || mySession != null || (category != null && initTicket),
//         'Either session or mySession must be provided, or category with initTicket for new sessions',
//       );

//   // Convenience getters
//   String get sessionId => session?.id ?? mySession?.id ?? '';
//   SessionModel? get currentSession => session ?? mySession?.toSessionModel();
//   CategoryModel? get sessionCategory => session?.category ?? mySession?.category ?? category;

//   // Check if this is a new session without existing session data
//   bool get isNewSession => initTicket && sessionId.isEmpty && category != null;

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ScrollController _scrollController = ScrollController();
//   final String ticketId = Utils.getUID;
//   late SingleSessionCubit _sessionCubit;
//   bool _streamStarted = false; // Track if stream has been started

//   /// Get the current session from SMSupportCubit state or fallback to widget's mySession
//   MySessionModel? _getCurrentSession(SMSupportState state) {
//     if (widget.sessionId.isNotEmpty) {
//       // Try to find the session in the current state first
//       final updatedSession = state.mySessions.firstWhereOrNull((s) => s.id == widget.sessionId);
//       if (updatedSession != null) {
//         return updatedSession;
//       }
//     }
//     // Fallback to the original session passed to the widget
//     return widget.mySession;
//   }

//   /// Check if rating should be shown based on current session state
//   bool _shouldShowRating() {
//     final sessionMessageRatingRequired = _sessionCubit.state.isRatingRequired;

//     // Return true if either the session or session messages indicate rating is required
//     return sessionMessageRatingRequired;
//   }

//   @override
//   void initState() {
//     super.initState();

//     // Initialize SingleSessionCubit with session ID (empty for new sessions)
//     _sessionCubit = SingleSessionCubit(sessionId: widget.sessionId);

//     // If this is a new session, pass the category information
//     if (widget.isNewSession && widget.category != null) {
//       _sessionCubit.setCategoryForNewSession(widget.category!);
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _scrollToBottom(plus: 100);
//       if (!widget.initTicket && widget.sessionId.isNotEmpty) {
//         // Load session messages for existing sessions
//         await _sessionCubit.getSessionMessages();
//         // Mark messages as read
//         _sessionCubit.markMessagesAsRead();
//         // Send typing indicator
//         // _sessionCubit.sendTypingIndicatorViaWebSocket(true);

//         // Start WebSocket stream for real-time messages
//         _startMessageStream();
//         _streamStarted = true;
//       }

//       // Check if rating should be shown based on current state

//       final shouldShowRating = _shouldShowRating();
//       if (shouldShowRating) {
//         primaryBottomSheet(
//           showLeadingContainer: true,
//           child: RateBS(sessionId: widget.sessionId, sessionCubit: _sessionCubit),
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     if (!widget.initTicket && widget.sessionId.isNotEmpty) {
//       // Send typing indicator off
//       // _sessionCubit.sendTypingIndicatorViaWebSocket(false);
//       // Stop message stream
//       _sessionCubit.stopMessageStream();
//     }
//     _sessionCubit.close();
//     super.dispose();
//   }

//   void _scrollToBottom({double plus = 0}) {
//     if (_scrollController.hasClients) {
//       // Check if content is scrollable (messages exceed screen height)
//       final maxScrollExtent = _scrollController.position.maxScrollExtent;

//       // Only scroll if there's actually content to scroll to
//       if (maxScrollExtent > 0) {
//         _scrollController.animateTo(
//           maxScrollExtent + plus,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     }
//   }

//   /// Start WebSocket message stream for real-time messaging
//   void _startMessageStream() {
//     try {
//       // Get tenant ID from SMSupportCubit

//       final tenantId = smCubit.state.currentTenant?.tenantId;

//       if (tenantId == null) {
//         smPrint('Cannot start message stream: tenantId is null');
//         return;
//       }

//       // Get current session ID from the cubit state (in case it was updated after session creation)
//       final currentSessionId = _sessionCubit.state.sessionId;

//       if (currentSessionId.isEmpty) {
//         smPrint('Cannot start message stream: sessionId is empty');
//         return;
//       }

//       // Get customer ID if authenticated
//       final customerId = AuthManager.isAuthenticated ? AuthManager.currentCustomer?.id : null;

//       smPrint('Starting message stream - TenantId: $tenantId, SessionId: $currentSessionId, CustomerId: $customerId');

//       // Start the WebSocket stream
//       _sessionCubit.startMessageStream(tenantId: tenantId, customerId: customerId);
//     } catch (e) {
//       smPrint('Error starting message stream: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [BlocProvider.value(value: _sessionCubit)],
//       child: BlocListener<SingleSessionCubit, SingleSessionState>(
//         listenWhen: (previous, current) => previous.isRatingRequiredFromSocket != current.isRatingRequiredFromSocket,
//         listener: (context, state) {
//           // Show rating bottom sheet when rating is required from WebSocket
//           if (state.isRatingRequiredFromSocket) {
//             smPrint('🌟 Rating request received via WebSocket - showing rating bottom sheet');
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               primaryBottomSheet(
//                 showLeadingContainer: true,
//                 child: RateBS(sessionId: widget.sessionId, sessionCubit: _sessionCubit),
//               );
//             });
//           }
//         },
//         child: Scaffold(
//           backgroundColor: ColorsPallets.white,
//           extendBody: true,
//           appBar: __appBar(),
//           body: Column(
//             children: [
//               DesignSystem.primaryDivider(),
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 22.rw),
//                 child: BlocBuilder<SMSupportCubit, SMSupportState>(
//                   builder: (context, state) {
//                     return Row(
//                       children: [
//                         DesignSystem.categorySvg(
//                           widget.sessionCategory?.categoryIcon ?? '',
//                           width: 24.rSp,
//                           height: 24.rSp,
//                         ),
//                         SizedBox(width: 14.rw),
//                         Expanded(
//                           child: Text(
//                             widget.sessionCategory?.categoryName ?? '--',
//                             style: TextStyles.s_13_400.copyWith(color: ColorsPallets.normal500),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               DesignSystem.primaryDivider(),
//               __messagesList(),
//               DesignSystem.primaryDivider(),
//               BlocBuilder<SMSupportCubit, SMSupportState>(
//                 builder: (context, state) {
//                   return BlocBuilder<SingleSessionCubit, SingleSessionState>(
//                     builder: (context, sessionState) {
//                       final currentSession = _getCurrentSession(state);
//                       final sessionStatus = currentSession?.toSessionModel().status ?? widget.currentSession?.status;

//                       final lastMessage = sessionState.sessionMessages.isNotEmpty
//                           ? sessionState.sessionMessages.last
//                           : null;

//                       final shouldShowRating = _shouldShowRating();

//                       return Column(
//                         children: [
//                           Visibility(
//                             visible:
//                                 (widget.initTicket || sessionStatus?.isActive == true) &&
//                                 !shouldShowRating &&
//                                 !(lastMessage?.contentType.isCloseSession ?? false),
//                             child: MessageInput(
//                               sessionId: widget.sessionId,
//                               ticketId: ticketId,
//                               initTicket: widget.initTicket,
//                               category: widget.category, // Pass category for new sessions
//                               onSend: (isSuccess) {
//                                 if (isSuccess) {
//                                   _scrollToBottom();
//                                   // Start stream after first message is sent (for new sessions)
//                                   // Only start once to prevent multiple connections
//                                   if (widget.initTicket && !_streamStarted) {
//                                     _startMessageStream();
//                                     _streamStarted = true;
//                                   }
//                                 }
//                               },
//                               onSessionCreated: (sessionId) {
//                                 // Session ID is already updated in createSessionWithCategory
//                                 // Just start WebSocket stream for the new session
//                                 if (!_streamStarted) {
//                                   _startMessageStream();
//                                   _streamStarted = true;
//                                 }
//                               },
//                             ),
//                           ),
//                           Visibility(
//                             visible: shouldShowRating,
//                             child: InkWell(
//                               onTap: () {
//                                 primaryBottomSheet(
//                                   showLeadingContainer: true,
//                                   child: RateBS(sessionId: widget.sessionId, sessionCubit: _sessionCubit),
//                                 );
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.only(bottom: 30, top: 20),
//                                 child: Text(SMText.rateTheConversation, style: TextStyles.s_20_400),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget __messagesList() {
//     return BlocConsumer<SingleSessionCubit, SingleSessionState>(
//       listener: (context, sessionState) {
//         // Auto-scroll when new messages arrive
//         if (sessionState.sessionMessages.isNotEmpty) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _scrollToBottom();
//           });
//         }
//       },
//       builder: (context, sessionState) {
//         smPrint('🖥️ UI REBUILD - Messages count: ${sessionState.sessionMessages.length}');
//         smPrint('🖥️ Session ID: ${sessionState.sessionId}');
//         smPrint('🖥️ Send status: ${sessionState.sendMessageStatus}');
//         smPrint('🖥️ Create status: ${sessionState.createSessionStatus}');

//         // Show loading for session messages or session creation
//         if (sessionState.getSessionMessagesStatus.isLoading
//         //  ||
//         //     (sessionState.isNewSession && sessionState.createSessionStatus.isLoading)
//         ) {
//           return Expanded(child: Center(child: DesignSystem.loadingIndicator()));
//         }

//         final messagesList = sessionState.sessionMessages;
//         smPrint('🖥️ About to render ${messagesList.length} messages');
//         return Expanded(
//           child: ListView(
//             controller: _scrollController,
//             addAutomaticKeepAlives: false,
//             padding: EdgeInsets.symmetric(horizontal: 22.rw).copyWith(bottom: 20.rh),
//             children: [
//               if (messagesList.isEmpty) ...[__emptyMessages()],
//               SizedBox(height: 16.rh),
//               ...messagesList.map((message) {
//                 return message.senderType.isCustomer ? _myMessage(message) : _adminMessage(message);
//               }),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // My Message item on the right
//   Widget _myMessage(SessionMessage message) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16.rh),
//       child: Column(
//         children: [
//           Visibility(
//             visible:
//                 message.reply != null && !(message.contentType.isReopenSession || message.contentType.isCloseSession),
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Row(
//                 children: [
//                   DesignSystem.svgIcon('replay', size: 14.rh, color: ColorsPallets.disabled300),
//                   SizedBox(width: 5),
//                   Text(
//                     message.reply?.message ?? '',
//                     style: TextStyles.s_13_400.copyWith(color: ColorsPallets.disabled300),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Row(
//             // crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               if (message.contentType.isReopenSession || message.contentType.isCloseSession)
//                 Flexible(flex: 2, child: Container(color: ColorsPallets.primaryColor, height: 1))
//               else if (message.reply != null) ...[
//                 DesignSystem.svgIcon(
//                   'curve',
//                   width: 19.rw,
//                   height: 21.rh,
//                   // color: ColorsPallets.disabled300,
//                 ),
//                 SizedBox(width: 8.rw),
//               ],

//               Flexible(
//                 flex: 3,
//                 child: Align(
//                   alignment: (message.contentType.isReopenSession || message.contentType.isCloseSession)
//                       ? AlignmentDirectional.center
//                       : AlignmentDirectional.centerStart,
//                   child: _messageBasedOnType(message, true),
//                 ),
//               ),
//               if (message.contentType.isReopenSession || message.contentType.isCloseSession)
//                 Flexible(flex: 2, child: Container(color: ColorsPallets.primaryColor, height: 1))
//               else
//                 SizedBox(width: 50.rw),
//             ],
//           ),
//           if (!(message.contentType.isReopenSession || message.contentType.isCloseSession)) ...[
//             SizedBox(height: 4.rh),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 // if (message.isHolderMessage) ...[
//                 //   Icon(Icons.watch_later_outlined, size: 12.rSp, color: ColorsPallets.subdued400),
//                 // ] else ...[

//                 // ],
//                 DesignSystem.svgIcon(
//                   // Message marked as read (read) else (read1)
//                   message.isRead ? 'read' : 'read1',
//                   size: 18.rSp,
//                 ),
//                 SizedBox(width: 4.rw),
//                 Text(
//                   '${message.createdAt.monthNameDay}, ${message.createdAt.timeFormat}',
//                   style: TextStyles.s_10_500.copyWith(color: ColorsPallets.subdued400),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   //  admin response item on left
//   Widget _adminMessage(SessionMessage message) {
//     return BlocBuilder<SingleSessionCubit, SingleSessionState>(
//       builder: (context, sessionState) {
//         return Padding(
//           padding: EdgeInsetsDirectional.only(bottom: 16.rh),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Flexible(
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         if (message.contentType.isReopenSession || message.contentType.isCloseSession)
//                           Flexible(flex: 2, child: Container(color: ColorsPallets.primaryColor, height: 1))
//                         else
//                           SizedBox(width: 50.rw),
//                         Flexible(
//                           flex: 3,
//                           child: InkWell(
//                             onLongPress: () {
//                               // Set reply on this message
//                               _sessionCubit.setRepliedOn(message.id);
//                             },
//                             child: Align(
//                               alignment: (message.contentType.isReopenSession || message.contentType.isCloseSession)
//                                   ? AlignmentDirectional.center
//                                   : AlignmentDirectional.centerEnd,
//                               child: _messageBasedOnType(message, false),
//                             ),
//                           ),
//                         ),
//                         if (message.contentType.isReopenSession || message.contentType.isCloseSession)
//                           Flexible(flex: 2, child: Container(color: ColorsPallets.primaryColor, height: 1)),
//                       ],
//                     ),
//                     if (!(message.contentType.isReopenSession || message.contentType.isCloseSession)) ...[
//                       SizedBox(height: 4.rh),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Text(
//                             '${message.createdAt.monthNameDay}, ${message.createdAt.timeFormat}',
//                             style: TextStyles.s_10_500.copyWith(color: ColorsPallets.subdued400),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               AnimatedCrossFade(
//                 duration: Duration(milliseconds: 300),
//                 firstChild: Padding(
//                   padding: EdgeInsetsDirectional.only(bottom: 16, start: 8, end: 12),
//                   child: DesignSystem.svgIcon('replay', size: 17, color: ColorsPallets.primaryColor),
//                 ),
//                 secondChild: SizedBox.shrink(),
//                 crossFadeState: sessionState.repliedOn == message.id
//                     ? CrossFadeState.showFirst
//                     : CrossFadeState.showSecond,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget __emptyMessages() {
//     return BlocBuilder<SingleSessionCubit, SingleSessionState>(
//       builder: (context, sessionState) {
//         return BlocBuilder<SMSupportCubit, SMSupportState>(
//           builder: (context, state) {
//             final tenant = state.currentTenant;
//             final tenantId = tenant?.tenantId ?? '';
//             final logoFileName = tenant?.logo;

//             // Show different message for new sessions
//             final startChatText = SMText.startChat;

//             return Column(
//               children: [
//                 SizedBox(height: 140.rh),
//                 TenantLogoHelper.standard(logoFileName: logoFileName, tenantId: tenantId, size: 80),
//                 SizedBox(height: 20.rh),
//                 Text(startChatText, style: TextStyles.s_20_400, textAlign: TextAlign.center),
//                 SizedBox(height: 8.rh),
//                 // Text(SMText.startChatDescription, style: TextStyles.s_20_400.copyWith(color: ColorsPallets.black)),
//                 // Container(
//                 //   padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 7),
//                 //   margin: EdgeInsets.symmetric(horizontal: 22.rw),
//                 //   decoration: BoxDecoration(color: ColorsPallets.disabled0, borderRadius: 12.br),
//                 //   child: Row(
//                 //     mainAxisAlignment: MainAxisAlignment.center,
//                 //     children: [
//                 //       Text(SMText.workingHoursFrom, style: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400)),
//                 //       SizedBox(width: 8.rw),
//                 //       Text(
//                 //         '09:00 - 17:00',
//                 //         textDirection: TextDirection.ltr,
//                 //         style: TextStyles.s_14_500.copyWith(
//                 //           color: ColorsPallets.subdued400,
//                 //           fontFamily: SMSupportTheme.sansFamily,
//                 //         ),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   PreferredSizeWidget __appBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       elevation: 0,
//       leading: Row(
//         children: [
//           SizedBox(width: 22.rw),
//           DesignSystem.backButton(color: ColorsPallets.loud900),
//         ],
//       ),
//       leadingWidth: 50.rw,
//       centerTitle: false,
//       flexibleSpace: ClipRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 100, tileMode: TileMode.mirror),
//           child: Container(color: Colors.transparent),
//         ),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(SMText.supportAndHelp, style: TextStyles.s_16_400),

//           Text(SMText.online, style: TextStyles.s_12_400.copyWith(color: ColorsPallets.secondaryGreen100)),
//         ],
//       ),
//     );
//   }

//   Widget _messageBasedOnType(SessionMessage message, bool isMyMessage) {
//     // Handle authentication-related messages
//     if (message.contentType.isNeedAuth) {
//       return _buildNeedAuthMessage(message, isMyMessage);
//     } else if (message.contentType.isAuthorized || message.contentType.isUnauthorized) {
//       return _buildAuthResultMessage(message, isMyMessage);
//     }

//     // Handle system action messages
//     if (message.contentType.isReopenSession ||
//         message.contentType.isCloseSession ||
//         message.contentType.isCloseSessionBySystem) {
//       return SystemActionMessageWidget(message: message);
//     }

//     // Handle media messages with new widgets
//     if (message.contentType.isText) {
//       return TextMessageWidget(message: message, isMyMessage: isMyMessage);
//     } else if (message.contentType.isImage) {
//       return _buildImageMessage(message, isMyMessage);
//     } else if (message.contentType.isVideo) {
//       return VideoMessageWidget(message: message, isMyMessage: isMyMessage, sessionId: widget.sessionId);
//     } else if (message.contentType.isAudio) {
//       // Audio files are now treated as unsupported media
//       return UnsupportedMediaWidget(message: message, isMyMessage: isMyMessage);
//     } else if (message.contentType.isFile) {
//       return FileMessageWidget(message: message, isMyMessage: isMyMessage, sessionId: widget.sessionId);
//     } else if (message.contentType.isUnsupportedMedia) {
//       return UnsupportedMediaWidget(message: message, isMyMessage: isMyMessage);
//     }

//     // Fallback to text message for unknown types
//     return TextMessageWidget(message: message, isMyMessage: isMyMessage);
//   }

//   //! Build Message based on type
//   //! Image Message (keeping original implementation with DynamicNetworkImage)

//   Widget _buildImageMessage(SessionMessage message, bool isMyMessage) {
//     return InkWell(
//       onTap: () async {
//         // Resolve the image URL before opening preview
//         String? imageUrl = message.content;

//         // If it's not a direct URL, resolve it first
//         if (!ImageUrlResolver.isDirectDownloadUrl(message.content)) {
//           final fileName = ImageUrlResolver.extractFileName(message.content);
//           imageUrl = await ImageUrlResolver.resolveImageUrl(
//             fileName: fileName,
//             sessionId: widget.sessionId,
//             category: FileUploadCategory.sessionMedia,
//           );
//         }

//         if (imageUrl != null && context.mounted) {
//           context.smPush(ImagePreview(imageUrl: imageUrl));
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.all(8.rSp),
//         decoration: BoxDecoration(
//           color: isMyMessage ? ColorsPallets.normal25 : ColorsPallets.primary0,
//           border: Border.all(color: isMyMessage ? ColorsPallets.borderColor : ColorsPallets.primary25),
//           borderRadius: 12.br,
//         ),
//         child: DynamicNetworkImage(
//           imageSource: message.content,
//           sessionId: widget.sessionId,
//           width: 200.rw,
//           height: 150.rh,
//           fit: BoxFit.cover,
//           borderRadius: 8.br,
//           category: FileUploadCategory.sessionMedia,
//         ),
//       ),
//     );
//   }

//   //! Need Auth Message
//   Widget _buildNeedAuthMessage(SessionMessage message, bool isMyMessage) {
//     return InkWell(
//       onTap: () {
//         primaryCupertinoBottomSheet(child: LoginByPhone(sessionId: widget.sessionId));
//       },
//       child: Container(
//         padding: EdgeInsets.all(10.rSp),
//         decoration: BoxDecoration(
//           color: ColorsPallets.yellow0,
//           border: Border.all(color: ColorsPallets.yellow25),
//           borderRadius: 12.br,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               SMText.confirmIdentityToCompleteTheProcess,
//               style: TextStyles.s_13_400.copyWith(color: ColorsPallets.yellow300),
//             ),
//             SizedBox(width: 8.rw),
//             DesignSystem.svgIcon('arrow-left', size: 17, color: ColorsPallets.yellow300),
//           ],
//         ),
//       ),
//     );
//   }

//   //! Auth Result Message
//   Widget _buildAuthResultMessage(SessionMessage message, bool isMyMessage) {
//     bool isAuthSuccess = message.contentType.isAuthorized;
//     return Container(
//       padding: EdgeInsets.all(10.rSp),
//       decoration: BoxDecoration(
//         color: isAuthSuccess ? ColorsPallets.green0 : ColorsPallets.red0,
//         border: Border.all(color: isAuthSuccess ? ColorsPallets.green25 : ColorsPallets.red25),
//         borderRadius: 12.br,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           DesignSystem.svgIcon(
//             isAuthSuccess ? 'check' : 'close',
//             size: 17,
//             color: isAuthSuccess ? ColorsPallets.green300 : ColorsPallets.red300,
//           ),
//           SizedBox(width: 8.rw),
//           Text(
//             isAuthSuccess ? SMText.identityConfirmed : SMText.identityNotConfirmed,
//             style: TextStyles.s_13_400.copyWith(color: isAuthSuccess ? ColorsPallets.green300 : ColorsPallets.red300),
//           ),
//         ],
//       ),
//     );
//   }
// }
