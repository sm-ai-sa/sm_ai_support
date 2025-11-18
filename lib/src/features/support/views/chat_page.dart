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
import 'package:sm_ai_support/src/features/support/cubit/single_session_state.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/chat_app_bar.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/chat_empty_state.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/chat_message_item.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/message_input.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/rate_bs.dart';

/// Main chat page for displaying and managing chat conversations
/// Refactored for better code organization and maintainability
class ChatPage extends StatefulWidget {
  final bool initTicket;

  final MySessionModel? mySession;
  final CategoryModel? category;

  const ChatPage({super.key, this.mySession, this.category, this.initTicket = false})
      : assert(
          mySession != null || (category != null && initTicket),
          'Either mySession must be provided, or category with initTicket for new sessions',
        );

  // Convenience getters
  String get sessionId => mySession?.id ?? '';
  // SessionModel? get currentSession => mySession?.toSessionModel();
  CategoryModel? get sessionCategory => mySession?.category ?? category;

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
  bool _isFirstLoad = true;
  DateTime? _lastPaginationTrigger;

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _setupScrollListener();
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

  /// Setup scroll listener for pagination
  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    // Don't trigger if already loading or no more messages
    if (_sessionCubit.state.loadMoreMessagesStatus.isLoading || !_sessionCubit.state.hasMoreMessages) {
      return;
    }

    // Prevent rapid consecutive pagination calls - wait at least 1 second between triggers
    final now = DateTime.now();
    if (_lastPaginationTrigger != null) {
      final timeSinceLastTrigger = now.difference(_lastPaginationTrigger!);
      if (timeSinceLastTrigger.inMilliseconds < 1000) {
        return;
      }
    }

    // With reverse: true, scrolling up (to older messages) means moving toward maxScrollExtent
    // Check if user scrolled near the end (top of visible content)
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = 100.0;

    if (maxScroll - currentScroll <= threshold) {
      smPrint('📜 User scrolled to top, triggering pagination (current: $currentScroll, max: $maxScroll)');
      _lastPaginationTrigger = now;
      // Load more messages when near the top
      _sessionCubit.loadMoreMessages();
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
    try {
      // Dispose scroll controller first to prevent errors
      if (_scrollController.hasClients) {
        _scrollController.removeListener(_onScroll);
      }
      _scrollController.dispose();

      // Then cleanup session streams
      if (!widget.initTicket && widget.sessionId.isNotEmpty) {
        _sessionCubit.stopMessageStream();
      }
      _sessionCubit.close();
    } catch (e) {
      // Silently handle disposal errors
      smPrint('Error during ChatPage disposal: $e');
    }
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
      // With reverse: true, bottom is at position 0
      _scrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
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
      listenWhen: (previous, current) {
        // Only scroll to bottom when:
        // 1. Initial load completes (first time loading messages)
        // 2. New message added to the end (last message ID changed)
        // DO NOT scroll during pagination (loading older messages)

        final isInitialLoadComplete =
            previous.getSessionMessagesStatus.isLoading && current.getSessionMessagesStatus.isSuccess;

        // Check if pagination just completed
        final paginationJustCompleted =
            previous.loadMoreMessagesStatus.isLoading && current.loadMoreMessagesStatus.isSuccess;

        // New message added: last message changed (but not during pagination)
        final newMessageAdded = !paginationJustCompleted &&
            previous.sessionMessages.isNotEmpty &&
            current.sessionMessages.isNotEmpty &&
            previous.sessionMessages.last.id != current.sessionMessages.last.id;

        final shouldScrollToBottom = (isInitialLoadComplete && _isFirstLoad) || newMessageAdded;

        if (shouldScrollToBottom) {
          smPrint(
            '📜 WILL SCROLL TO BOTTOM - InitialLoad: ${isInitialLoadComplete && _isFirstLoad}, NewMessage: $newMessageAdded',
          );
        } else if (paginationJustCompleted) {
          smPrint('📜 PAGINATION COMPLETED - Scroll position automatically preserved by reverse ListView');
        }

        // Only trigger listener for scroll-to-bottom events
        return shouldScrollToBottom;
      },
      listener: (context, sessionState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // With reverse: true ListView, scroll position is automatically preserved during pagination
          // We only need to scroll to bottom for initial load and new messages
          smPrint('📜 SCROLLING TO BOTTOM');
          _scrollToBottom();

          // Mark that first load is complete
          if (_isFirstLoad) {
            _isFirstLoad = false;
          }
        });
      },
      builder: (context, sessionState) {
        smPrint('🖥️ UI REBUILD - Messages count: ${sessionState.sessionMessages.length}');

        // Show loading
        if (sessionState.getSessionMessagesStatus.isLoading) {
          return Expanded(child: Center(child: DesignSystem.loadingIndicator()));
        }

        // Combine dummy messages with real messages for testing

        final realMessages = sessionState.sessionMessages;
        final messagesList = [...realMessages];

        smPrint('📋 Total messages (${messagesList.length}): ${realMessages.length} real');

        return Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: messagesList.isNotEmpty, // This makes newest messages at bottom and preserves scroll on pagination
            addAutomaticKeepAlives: false,
            padding: EdgeInsets.symmetric(horizontal: 22.rw).copyWith(top: 20.rh),
            itemCount: messagesList.length +
                (sessionState.loadMoreMessagesStatus.isLoading ? 1 : 0) +
                (!sessionState.hasMoreMessages && messagesList.isNotEmpty ? 1 : 0) +
                (messagesList.isEmpty ? 1 : 0) +
                1, // +1 for spacing
            itemBuilder: (context, index) {
              // Since reverse: true, indices are flipped
              // First item (bottom) = last message, last item (top) = first message

              // Bottom spacing
              if (index == 0) {
                return SizedBox(height: 16.rh);
              }

              int adjustedIndex = index - 1;

              // Messages (reversed order)
              if (adjustedIndex < messagesList.length) {
                final messageIndex = messagesList.length - 1 - adjustedIndex;
                return ChatMessageItem(message: messagesList[messageIndex], sessionId: widget.sessionId);
              }

              adjustedIndex -= messagesList.length;

              // Empty state
              if (messagesList.isEmpty && adjustedIndex == 0) {
                return _buildEmptyState();
              }

              // // "No more messages" indicator (at the top)
              // if (!sessionState.hasMoreMessages && messagesList.isNotEmpty && adjustedIndex == 0) {
              //   return _buildNoMoreMessagesIndicator();
              // }

              if (!sessionState.hasMoreMessages && messagesList.isNotEmpty) adjustedIndex--;

              // Loading indicator (at the top)
              if (sessionState.loadMoreMessagesStatus.isLoading && adjustedIndex == 0) {
                return Center(child: DesignSystem.loadingIndicator());
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
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
            final sessionStatus = currentSession?.status ?? widget.mySession?.status;

            final lastMessage = sessionState.sessionMessages.isNotEmpty ? sessionState.sessionMessages.last : null;

            final shouldShowRating = _shouldShowRating();

            return Column(
              children: [
                // Message input
                Visibility(
                  visible: (widget.initTicket || sessionStatus?.isActive == true) &&
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
