import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/support/cubit/single_session_state.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/support/views/widgets/chat_app_bar.dart';
import 'package:sm_ai_support/src/support/views/widgets/chat_empty_state.dart';
import 'package:sm_ai_support/src/support/views/widgets/chat_message_item.dart';
import 'package:sm_ai_support/src/support/views/widgets/message_input.dart';
import 'package:sm_ai_support/src/support/views/widgets/rate_bs.dart';

/// Main chat page for displaying and managing chat conversations
/// Refactored for better code organization and maintainability
class ChatPage extends StatefulWidget {
  final bool initTicket;
  final SessionModel? session;
  final MySessionModel? mySession;
  final CategoryModel? category;

  const ChatPage({super.key, this.session, this.mySession, this.category, this.initTicket = false})
    : assert(
        session != null || mySession != null || (category != null && initTicket),
        'Either session or mySession must be provided, or category with initTicket for new sessions',
      );

  // Convenience getters
  String get sessionId => session?.id ?? mySession?.id ?? '';
  SessionModel? get currentSession => session ?? mySession?.toSessionModel();
  CategoryModel? get sessionCategory => session?.category ?? mySession?.category ?? category;

  // Check if this is a new session without existing session data
  bool get isNewSession => initTicket && sessionId.isEmpty && category != null;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final String ticketId = Utils.getUID;
  late SingleSessionCubit _sessionCubit;
  bool _streamStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _setupPostFrameCallback();
  }

  @override
  void dispose() {
    _cleanupSession();
    super.dispose();
  }

  /// Initialize session cubit and category
  void _initializeSession() {
    _sessionCubit = SingleSessionCubit(sessionId: widget.sessionId);

    if (widget.isNewSession && widget.category != null) {
      _sessionCubit.setCategoryForNewSession(widget.category!);
    }
  }

  /// Setup post-frame callback for initial loading
  void _setupPostFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _scrollToBottom(plus: 100);

      if (!widget.initTicket && widget.sessionId.isNotEmpty) {
        await _loadExistingSession();
      }

      _showRatingIfRequired();
    });
  }

  /// Load existing session data
  Future<void> _loadExistingSession() async {
    await _sessionCubit.getSessionMessages();
    _sessionCubit.markMessagesAsRead();
    _startMessageStream();
    _streamStarted = true;
  }

  /// Cleanup session on dispose
  void _cleanupSession() {
    if (!widget.initTicket && widget.sessionId.isNotEmpty) {
      _sessionCubit.stopMessageStream();
    }
    _sessionCubit.close();
  }

  /// Show rating bottom sheet if required
  void _showRatingIfRequired() {
    if (_shouldShowRating()) {
      primaryBottomSheet(
        showLeadingContainer: true,
        child: RateBS(sessionId: widget.sessionId, sessionCubit: _sessionCubit),
      );
    }
  }

  /// Get current session from state
  MySessionModel? _getCurrentSession(SMSupportState state) {
    if (widget.sessionId.isNotEmpty) {
      final updatedSession = state.mySessions.firstWhereOrNull((s) => s.id == widget.sessionId);
      if (updatedSession != null) return updatedSession;
    }
    return widget.mySession;
  }

  /// Check if rating should be shown
  bool _shouldShowRating() {
    return _sessionCubit.state.isRatingRequired;
  }

  /// Scroll to bottom of messages list
  void _scrollToBottom({double plus = 0}) {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
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
      final tenantId = smCubit.state.currentTenant?.tenantId;
      if (tenantId == null) {
        smPrint('Cannot start message stream: tenantId is null');
        return;
      }

      final currentSessionId = _sessionCubit.state.sessionId;
      if (currentSessionId.isEmpty) {
        smPrint('Cannot start message stream: sessionId is empty');
        return;
      }

      final customerId = AuthManager.isAuthenticated ? AuthManager.currentCustomer?.id : null;
      smPrint('Starting message stream - TenantId: $tenantId, SessionId: $currentSessionId, CustomerId: $customerId');

      _sessionCubit.startMessageStream(tenantId: tenantId, customerId: customerId);
    } catch (e) {
      smPrint('Error starting message stream: $e');
    }
  }

  /// Handle message send callback
  void _onMessageSent(bool isSuccess) {
    if (isSuccess) {
      _scrollToBottom();
      // Start stream after first message is sent (for new sessions)
      if (widget.initTicket && !_streamStarted) {
        _startMessageStream();
        _streamStarted = true;
      }
    }
  }

  /// Handle session creation callback
  void _onSessionCreated(String sessionId) {
    if (!_streamStarted) {
      _startMessageStream();
      _streamStarted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _sessionCubit)],
      child: BlocListener<SingleSessionCubit, SingleSessionState>(
        listenWhen: (previous, current) => previous.isRatingRequiredFromSocket != current.isRatingRequiredFromSocket,
        listener: _handleRatingRequest,
        child: Scaffold(
          backgroundColor: ColorsPallets.white,
          extendBody: true,
          appBar: ChatAppBar(),
          body: Column(
            children: [
              _buildCategoryHeader(),
              DesignSystem.primaryDivider(),
              _buildMessagesList(),
              DesignSystem.primaryDivider(),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle rating request from WebSocket
  void _handleRatingRequest(BuildContext context, SingleSessionState state) {
    if (state.isRatingRequiredFromSocket) {
      smPrint('🌟 Rating request received via WebSocket - showing rating bottom sheet');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        primaryBottomSheet(
          showLeadingContainer: true,
          child: RateBS(sessionId: widget.sessionId, sessionCubit: _sessionCubit),
        );
      });
    }
  }

  /// Build category header
  Widget _buildCategoryHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 22.rw),
      child: BlocBuilder<SMSupportCubit, SMSupportState>(
        builder: (context, state) {
          return Row(
            children: [
              DesignSystem.categorySvg(widget.sessionCategory?.categoryIcon ?? '', width: 24.rSp, height: 24.rSp),
              SizedBox(width: 14.rw),
              Expanded(
                child: Text(
                  widget.sessionCategory?.categoryName ?? '--',
                  style: TextStyles.s_13_400.copyWith(color: ColorsPallets.normal500),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build messages list
  Widget _buildMessagesList() {
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
        smPrint('🖥️ UI REBUILD - Messages count: ${sessionState.sessionMessages.length}');

        // Show loading
        if (sessionState.getSessionMessagesStatus.isLoading) {
          return Expanded(child: Center(child: DesignSystem.loadingIndicator()));
        }

        // Combine dummy messages with real messages for testing
        // final dummyMessages = DummyMessages.getAllDummyMessages();
        final dummyMessages = [];
        final realMessages = sessionState.sessionMessages;
        final messagesList = [...dummyMessages, ...realMessages];

        smPrint(
          '📋 Total messages (${messagesList.length}): ${dummyMessages.length} dummy + ${realMessages.length} real',
        );

        return Expanded(
          child: ListView(
            controller: _scrollController,
            addAutomaticKeepAlives: false,
            padding: EdgeInsets.symmetric(horizontal: 22.rw).copyWith(bottom: 20.rh),
            children: [
              // Show dummy messages info banner
              if (dummyMessages.isNotEmpty) _buildDummyMessagesBanner(dummyMessages.length),

              if (messagesList.isEmpty) _buildEmptyState(),
              SizedBox(height: 16.rh),
              ...messagesList.map((message) {
                return ChatMessageItem(message: message, sessionId: widget.sessionId);
              }),
            ],
          ),
        );
      },
    );
  }

  /// Build dummy messages info banner
  Widget _buildDummyMessagesBanner(int count) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.rh),
      padding: EdgeInsets.all(12.rSp),
      decoration: BoxDecoration(
        color: ColorsPallets.yellow0,
        border: Border.all(color: ColorsPallets.yellow25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: ColorsPallets.yellow300, size: 20.rSp),
          SizedBox(width: 8.rw),
          Expanded(
            child: Text(
              '🎨 Demo Mode: Showing $count test messages for all media types',
              style: TextStyles.s_12_400.copyWith(color: ColorsPallets.yellow300),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        final tenant = state.currentTenant;
        return ChatEmptyState(logoFileName: tenant?.logo, tenantId: tenant?.tenantId ?? '');
      },
    );
  }

  /// Build message input area
  Widget _buildMessageInput() {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        return BlocBuilder<SingleSessionCubit, SingleSessionState>(
          builder: (context, sessionState) {
            final currentSession = _getCurrentSession(state);
            final sessionStatus = currentSession?.toSessionModel().status ?? widget.currentSession?.status;

            final lastMessage = sessionState.sessionMessages.isNotEmpty ? sessionState.sessionMessages.last : null;

            final shouldShowRating = _shouldShowRating();

            return Column(
              children: [
                // Message input
                Visibility(
                  visible:
                      (widget.initTicket || sessionStatus?.isActive == true) &&
                      !shouldShowRating &&
                      !(lastMessage?.contentType.isCloseSession ?? false),
                  child: MessageInput(
                    sessionId: widget.sessionId,
                    ticketId: ticketId,
                    initTicket: widget.initTicket,
                    category: widget.category,
                    onSend: _onMessageSent,
                    onSessionCreated: _onSessionCreated,
                  ),
                ),

                // Rating button
                Visibility(
                  visible: shouldShowRating,
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
        );
      },
    );
  }
}
