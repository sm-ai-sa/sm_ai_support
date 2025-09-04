import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/network/dio_factory.dart';
import 'package:sm_ai_support/src/core/network/network_services.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/support/cubit/sm_support_state.dart';

SMSupportCubit get smCubit => sl<SMSupportCubit>();

class SMSupportCubit extends Cubit<SMSupportState> {
  SMSupportCubit() : super(SMSupportState());

  /// Initialize data
  Future<void> initializeData(String local) async {
    smPrint('initializeData ---------------: $local');
    emit(state.copyWith(currentLocale: local));

    // Force refresh Dio instance and NetworkServices when locale changes
    try {
      DioFactory.resetDio(newLocale: local);

      // Also reset NetworkServices to get fresh Dio instance
      if (sl.isRegistered<NetworkServices>()) {
        sl.unregister<NetworkServices>();
        sl.registerLazySingleton<NetworkServices>(() => NetworkServices());
      }
    } catch (e) {
      // Handle reset errors silently
    }
  }

  // Stream subscriptions for WebSocket streams
  StreamSubscription<int>? _unreadSessionsCountSubscription;
  StreamSubscription<Map<String, dynamic>>? _sessionStatsSubscription;

  //! New Support API Methods -----------------------------------

  /// Get tenant information
  Future<void> getTenant({required String tenantId}) async {
    smPrint('Get Tenant: $tenantId');
    emit(state.copyWith(getTenantStatus: BaseStatus.loading));
    try {
      final result = await sl<SupportRepo>().getTenant(tenantId: tenantId);
      result.when(
        success: (data) {
          smPrint('Get Tenant Success: ${data.tenant.name}');
          emit(state.copyWith(getTenantStatus: BaseStatus.success, currentTenant: data.tenant));
        },
        error: (error) {
          // Even in error case, we get dummy tenant from repo
          smPrint('Get Tenant Error handled with dummy data');
          emit(state.copyWith(getTenantStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      smPrint('Get Tenant Exception: $e');
      emit(state.copyWith(getTenantStatus: BaseStatus.failure));
    }
  }

  /// Get support categories
  Future<void> getCategories() async {
    smPrint('Get Categories');
    emit(state.copyWith(getCategoriesStatus: BaseStatus.loading));
    try {
      final result = await sl<SupportRepo>().getCategories(tenantId: state.currentTenant?.tenantId ?? '');
      result.when(
        success: (data) {
          smPrint('Get Categories Success: ${data.result.length} categories');
          emit(state.copyWith(getCategoriesStatus: BaseStatus.success, categories: data.result));
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(getCategoriesStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(getCategoriesStatus: BaseStatus.failure));
    }
  }

  /// Start anonymous session
  Future<void> startAnonymousSession({required int categoryId}) async {
    smPrint('Start Anonymous Session for category: $categoryId');
    emit(state.copyWith(startSessionStatus: BaseStatus.loading, startSessionOnCategoryId: categoryId));
    try {
      final result = await sl<SupportRepo>().startAnonymousSession(categoryId: categoryId);
      result.when(
        success: (data) async {
          smPrint('Start Anonymous Session Success: ${data.result.viewId}');

          // Save anonymous session ID to SharedPreferences
          await SharedPrefHelper.addAnonymousSessionId(data.result.id);
          smPrint('Saved anonymous session ID: ${data.result.id}');

          emit(state.copyWith(startSessionStatus: BaseStatus.success, currentSession: data.result));
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: SMText.sessionStartError);
          emit(state.copyWith(startSessionStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      smPrint('Start Anonymous Session Exception: $e');
      primarySnackBar(smNavigatorKey.currentContext!, message: SMText.sessionStartError);
      emit(state.copyWith(startSessionStatus: BaseStatus.failure));
    }
  }

  /// Start authenticated session
  /// Note: Auth token is automatically added by DioFactory interceptor if user is authenticated
  Future<void> startSession({required int categoryId}) async {
    smPrint('Start Session for category: $categoryId (authenticated: ${AuthManager.isAuthenticated})');
    emit(state.copyWith(startSessionStatus: BaseStatus.loading, startSessionOnCategoryId: categoryId));
    try {
      final result = await sl<SupportRepo>().startSession(
        categoryId: categoryId,
        authToken: null, // Auth token automatically added by interceptor
      );
      result.when(
        success: (data) {
          smPrint('Start Session Success: ${data.result.viewId}');
          emit(state.copyWith(startSessionStatus: BaseStatus.success, currentSession: data.result));
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: SMText.sessionStartError);
          emit(state.copyWith(startSessionStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      smPrint('Start Session Exception: $e');

      primarySnackBar(smNavigatorKey.currentContext!, message: SMText.sessionStartError);
      emit(state.copyWith(startSessionStatus: BaseStatus.failure));
    }
  }

  /// Assign anonymous sessions to current user
  Future<void> assignAnonymousSession({required List<String> sessionIds}) async {
    smPrint('Assign Anonymous Sessions: ${sessionIds.length} sessions');
    emit(state.copyWith(assignSessionStatus: BaseStatus.loading));
    try {
      final result = await sl<SupportRepo>().assignAnonymousSession(sessionIds: sessionIds);
      result.when(
        success: (data) {
          smPrint('Assign Anonymous Session Success');
          emit(state.copyWith(assignSessionStatus: BaseStatus.success));
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(assignSessionStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(assignSessionStatus: BaseStatus.failure));
    }
  }

  /// Get user's sessions
  Future<void> getMySessions() async {
    smPrint('Get My Sessions');
    emit(state.copyWith(getMySessionsStatus: BaseStatus.loading));
    try {
      final result = await sl<SupportRepo>().getMySessions();
      result.when(
        success: (data) {
          smPrint('Get My Sessions Success: ${data.result.length} sessions');
          emit(
            state.copyWith(getMySessionsStatus: BaseStatus.success, mySessions: data.result, isGetSessionsBefore: true),
          );
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(getMySessionsStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(getMySessionsStatus: BaseStatus.failure));
    }
  }

  /// Get user's unread sessions count
  Future<void> getMyUnreadSessions() async {
    smPrint('Get My Unread Sessions');
    emit(state.copyWith(getMyUnreadSessionsStatus: BaseStatus.loading));
    try {
      final result = await sl<SupportRepo>().getMyUnreadSessions();
      result.when(
        success: (data) {
          smPrint('Get My Unread Sessions Success: ${data.result} unread sessions');
          emit(state.copyWith(getMyUnreadSessionsStatus: BaseStatus.success, myUnreadSessionsCount: data.result));
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(getMyUnreadSessionsStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(getMyUnreadSessionsStatus: BaseStatus.failure));
    }
  }

  // /// Rate Ticket
  // Future<void> rateTicket({
  //   required String ticketId,
  //   required num rate,
  // }) async {
  //   emit(state.copyWith(rateTicketStatus: BaseStatus.loading));
  //   try {
  //     final result = await sl<SupportRepo>().rateTicket(ticketId: ticketId, rate: rate);
  //     result.when(
  //       success: (data) {
  //         emit(state.copyWith(rateTicketStatus: BaseStatus.success));
  //       },
  //       error: (error) {
  //         primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
  //         emit(state.copyWith(rateTicketStatus: BaseStatus.failure));
  //       },
  //     );
  //   } catch (e) {
  //     primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
  //     emit(state.copyWith(rateTicketStatus: BaseStatus.failure));
  //   }
  // }

  // /// Change Typing Status
  // Future<void> changeTypingStatus({
  //   required String ticketId,
  //   required bool isTyping,
  // }) async {
  //   try {
  //     final result = await sl<SupportRepo>().changeTypingStatus(ticketId: ticketId, isTyping: isTyping);
  //     result.when(
  //       success: (data) {
  //         smPrint('Change Typing Status Done $isTyping');
  //       },
  //       error: (error) {
  //         smPrint('Change Typing Status Error: ${error.failure.error}');
  //       },
  //     );
  //   } catch (e) {
  //     smPrint('Change Typing Status Error: $e');
  //   }
  // }

  void setDownloadedUrl(String url) {
    emit(state.copyWith(downloadedUrl: url));
  }

  void clearDownloadedUrl() {
    emit(state.copyWith(downloadedUrl: null, isResetDownloadedUrl: true));
  }

  /// Update unread count for a specific session
  /// This method is called after successfully marking messages as read
  /// [sessionId] - The ID of the session to update
  void updateSessionUnreadCount(String sessionId) {
    smPrint('Updating unread count for session: $sessionId');

    // Find the session in mySessions list and update its unread count
    final updatedSessions = state.mySessions.map((session) {
      if (session.id == sessionId) {
        // Create updated metadata with unreadCount = 0
        final updatedMetadata = session.metadata.copyWith(unreadCount: 0);
        // Return updated session with new metadata

        return session.copyWith(metadata: updatedMetadata);
      }
      return session;
    }).toList();

    // loop on sessions to update myUnreadSessionsCount
    final updatedUnreadSessionsCount = updatedSessions.where((session) => session.metadata.unreadCount > 0).length;
    emit(state.copyWith(myUnreadSessionsCount: updatedUnreadSessionsCount));

    // Update the state with the modified sessions list
    emit(state.copyWith(mySessions: updatedSessions));
    smPrint('Updated unread count to 0 for session: $sessionId');
  }

  /// Reopen a closed session
  /// This method reopens a session and updates the local session list
  /// [sessionId] - The ID of the session to reopen
  Future<void> reopenSession(String sessionId) async {
    smPrint('Reopen Session: $sessionId');
    emit(state.copyWith(reopenSessionStatus: BaseStatus.loading, reopenSessionId: sessionId));
    try {
      final result = await sl<SupportRepo>().reopenSession(sessionId: sessionId);

      result.when(
        success: (data) {
          smPrint('Reopen Session Success: $data');

          // Update the session in the local list with the new status
          _updateSessionStatus(sessionId);

          emit(
            state.copyWith(
              reopenSessionStatus: BaseStatus.success,
              reopenSessionId: null,
              isResetReopenSessionId: true,
            ),
          );
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(
            state.copyWith(
              reopenSessionStatus: BaseStatus.failure,
              reopenSessionId: null,
              isResetReopenSessionId: true,
            ),
          );
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(
        state.copyWith(reopenSessionStatus: BaseStatus.failure, reopenSessionId: null, isResetReopenSessionId: true),
      );
    }
  }

  /// Check if currently reopening session
  bool get isReopeningSession => state.reopenSessionStatus.isLoading;

  /// Check if reopen was successful
  bool get reopenSessionSuccess => state.reopenSessionStatus.isSuccess;

  /// Check if reopen failed
  bool get reopenSessionFailed => state.reopenSessionStatus.isFailure;

  /// Update session status after reopening (internal method)
  /// This method is called after successfully reopening a session
  /// [sessionId] - The ID of the session to update
  /// [updatedSession] - The updated session data from the API
  void _updateSessionStatus(String sessionId) {
    smPrint('Updating session status for session: $sessionId');

    // Find the session in mySessions list and update it with the new data
    final updatedSessions = state.mySessions.map((session) {
      if (session.id == sessionId) {
        // Update the session with new status and other properties
        return session.copyWith(status: SessionStatus.active);
      }
      return session;
    }).toList();

    // Update the state with the modified sessions list
    emit(state.copyWith(mySessions: updatedSessions));
    smPrint('Updated session status to ${SessionStatus.active} for session: $sessionId');
  }

  //! WebSocket Stream Methods -----------------------------------

  /// Start unread sessions count stream for real-time updates
  /// This should be called in SMSupportCategoriesBs
  Future<void> startUnreadSessionsCountStream() async {
    try {
      if (!AuthManager.isAuthenticated) {
        smPrint('Cannot start unread sessions count stream: User not authenticated');
        return;
      }

      final tenantId = state.currentTenant?.tenantId;
      final customerId = AuthManager.currentCustomer?.id;

      if (tenantId == null || customerId == null) {
        smPrint('Cannot start unread sessions count stream: Missing tenantId or customerId');
        return;
      }

      // Stop existing subscription if any
      if (_unreadSessionsCountSubscription != null) {
        smPrint('Stopping existing unread sessions count subscription');
        _unreadSessionsCountSubscription?.cancel();
        _unreadSessionsCountSubscription = null;
      }

      smPrint('Starting unread sessions count stream - TenantId: $tenantId, CustomerId: $customerId');

      final webSocketService = sl<WebSocketService>();

      // Debug connection status before connecting
      webSocketService.debugConnectionStatus();

      // Connect to the unread sessions count stream
      await webSocketService.connectToUnreadSessionsCountStream(tenantId: tenantId, customerId: customerId);

      // Debug connection status after connecting
      webSocketService.debugConnectionStatus();

      // Listen to the stream
      _unreadSessionsCountSubscription = webSocketService.unreadSessionsCountStream?.listen(
        _onUnreadSessionsCountUpdate,
        onError: (error) {
          smPrint('Unread sessions count stream error: $error');
        },
        onDone: () {
          smPrint('Unread sessions count stream done');
        },
      );

      smPrint('Unread sessions count stream started successfully');
      smPrint('Subscription active: ${_unreadSessionsCountSubscription != null}');
    } catch (e) {
      smPrint('Error starting unread sessions count stream: $e');
    }
  }

  /// Stop unread sessions count stream
  void stopUnreadSessionsCountStream() {
    smPrint('Stopping unread sessions count stream');

    _unreadSessionsCountSubscription?.cancel();
    _unreadSessionsCountSubscription = null;

    final webSocketService = sl<WebSocketService>();
    webSocketService.disconnectFromUnreadSessionsCountStream();

    smPrint('Unread sessions count stream stopped');
  }

  /// Start session stats stream for real-time updates
  /// This should be called in MySessions page
  Future<void> startSessionStatsStream() async {
    try {
      if (!AuthManager.isAuthenticated) {
        smPrint('Cannot start session stats stream: User not authenticated');
        return;
      }

      final tenantId = state.currentTenant?.tenantId;
      final customerId = AuthManager.currentCustomer?.id;

      if (tenantId == null || customerId == null) {
        smPrint('Cannot start session stats stream: Missing tenantId or customerId');
        return;
      }

      // Stop existing subscription if any
      if (_sessionStatsSubscription != null) {
        smPrint('Stopping existing session stats subscription');
        _sessionStatsSubscription?.cancel();
        _sessionStatsSubscription = null;
      }

      smPrint('Starting session stats stream - TenantId: $tenantId, CustomerId: $customerId');

      final webSocketService = sl<WebSocketService>();

      // Connect to the session stats stream
      await webSocketService.connectToSessionStatsStream(tenantId: tenantId, customerId: customerId);

      // Listen to the stream
      _sessionStatsSubscription = webSocketService.sessionStatsStream?.listen(
        _onSessionStatsUpdate,
        onError: (error) {
          smPrint('Session stats stream error: $error');
        },
        onDone: () {
          smPrint('Session stats stream done');
        },
      );

      smPrint('Session stats stream started successfully');
    } catch (e) {
      smPrint('Error starting session stats stream: $e');
    }
  }

  /// Stop session stats stream
  void stopSessionStatsStream() {
    smPrint('Stopping session stats stream');

    _sessionStatsSubscription?.cancel();
    _sessionStatsSubscription = null;

    final webSocketService = sl<WebSocketService>();
    webSocketService.disconnectFromSessionStatsStream();

    smPrint('Session stats stream stopped');
  }

  /// Handle unread sessions count updates from WebSocket stream
  void _onUnreadSessionsCountUpdate(int newCount) {
    smPrint('Received unread sessions count update: $newCount');
    emit(state.copyWith(myUnreadSessionsCount: newCount));
  }

  /// Handle session stats updates from WebSocket stream
  void _onSessionStatsUpdate(Map<String, dynamic> sessionStatsData) {
    try {
      smPrint('Received session stats update: $sessionStatsData');

      final type = sessionStatsData['type'] as String?;
      final data = sessionStatsData['data'];

      if ((type == 'new_message' || type == 'session_reopened') && data != null) {
        if (data is List) {
          // Handle multiple session updates
          for (final sessionData in data) {
            if (sessionData is Map<String, dynamic>) {
              _updateSessionFromStats(sessionData);
            }
          }
        } else if (data is Map<String, dynamic>) {
          // Handle single session update
          _updateSessionFromStats(data);
        }
      }
    } catch (e) {
      smPrint('Error handling session stats update: $e');
    }
  }

  /// Update a session in the local list based on stats data
  void _updateSessionFromStats(Map<String, dynamic> sessionData) {
    try {
      final sessionId = sessionData['id'] as String?;
      final sessionStatus = sessionData['status'] as String?;
      final metadata = sessionData['metadata'] as Map<String, dynamic>?;

      if (sessionId == null || metadata == null) {
        smPrint('Invalid session stats data: missing id or metadata');
        return;
      }

      final updatedSessions = state.mySessions.map((session) {
        if (session.id == sessionId) {
          // Create updated metadata
          final newMetadata = session.metadata.copyWith(
            unreadCount: metadata['customerUnreadCount'] as int?,
            lastMessageAt: metadata['lastMessageAt'] != null
                ? DateTime.parse(metadata['lastMessageAt'] as String)
                : null,
            lastMessageContent: metadata['lastMessageContent'] as String?,
          );

          smPrint('Updated session ${session.id} with new metadata');
          return session.copyWith(
            status: sessionStatus != null ? SessionStatus.fromString(sessionStatus) : session.status,
            metadata: newMetadata,
          );
        }
        return session;
      }).toList();

      // Update the state with the modified sessions list
      emit(state.copyWith(mySessions: updatedSessions));
    } catch (e) {
      smPrint('Error updating session from stats: $e');
    }
  }

  /// Update session rating status after successful rating
  /// This method is called after a session has been successfully rated
  /// [sessionId] - The ID of the session that was rated
  void updateSessionRatingStatus(String sessionId) {
    smPrint('Updating rating status for session: $sessionId');

    // Find the session in mySessions list and update isRatingRequired to false
    final updatedSessions = state.mySessions.map((session) {
      if (session.id == sessionId) {
        // Update the session to mark rating as no longer required
        return session.copyWith(isRatingRequired: false);
      }
      return session;
    }).toList();

    // Update the state with the modified sessions list
    emit(state.copyWith(mySessions: List.from(updatedSessions)));
    smPrint('Updated isRatingRequired to false for session: $sessionId');
  }

  @override
  Future<void> close() {
    // Clean up stream subscriptions
    _unreadSessionsCountSubscription?.cancel();
    _sessionStatsSubscription?.cancel();

    return super.close();
  }
}
