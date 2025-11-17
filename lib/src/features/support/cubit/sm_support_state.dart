import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class SMSupportState extends Equatable {
  // Legacy ticket management status
  // final BaseStatus getTicketsStatus;
  // final BaseStatus getChatStreamStatus;
  // final BaseStatus openTicketStatus;
  // final BaseStatus pushMessageStatus;
  // final BaseStatus markAsReadStatus;
  // final BaseStatus reOpenTicketStatus;
  // final BaseStatus uploadFileStatus;
  // final BaseStatus rateTicketStatus;

  // New support API status
  final BaseStatus getCategoriesStatus;
  final BaseStatus startSessionStatus;
  final BaseStatus assignSessionStatus;
  final BaseStatus getMySessionsStatus;
  final BaseStatus getMyUnreadSessionsStatus;
  final BaseStatus getMySessionMessagesStatus;
  final BaseStatus uploadFileStatus;
  final BaseStatus reopenSessionStatus;
  final String? reopenSessionId;

  // Tenant status
  final BaseStatus getTenantStatus;

  // Legacy data

  final File? pickedFile;
  final String? downloadedUrl;

  // New support data
  final List<CategoryModel> categories;
  final MySessionModel? currentSession;
  final List<MySessionModel> mySessions;
  final int myUnreadSessionsCount;
  final bool isGetSessionsBefore;

  // Tenant data
  final TenantModel? currentTenant;

  // current locale
  final String? currentLocale;

  // start session on category id
  final int? startSessionOnCategoryId;

  const SMSupportState({
    // Legacy ticket management status
    // this.getTicketsStatus = BaseStatus.initial,
    // this.getChatStreamStatus = BaseStatus.initial,
    // this.openTicketStatus = BaseStatus.initial,
    // this.pushMessageStatus = BaseStatus.initial,
    // this.markAsReadStatus = BaseStatus.initial,
    // this.reOpenTicketStatus = BaseStatus.initial,
    // this.uploadFileStatus = BaseStatus.initial,
    // this.rateTicketStatus = BaseStatus.initial,

    // New support API status
    this.getCategoriesStatus = BaseStatus.initial,
    this.startSessionStatus = BaseStatus.initial,
    this.assignSessionStatus = BaseStatus.initial,
    this.getMySessionsStatus = BaseStatus.initial,
    this.getMyUnreadSessionsStatus = BaseStatus.initial,
    this.getMySessionMessagesStatus = BaseStatus.initial,
    this.uploadFileStatus = BaseStatus.initial,
    this.reopenSessionStatus = BaseStatus.initial,

    this.reopenSessionId,
    this.isGetSessionsBefore = false,

    // Tenant status
    this.getTenantStatus = BaseStatus.initial,

    // Legacy data
    this.pickedFile,
    this.downloadedUrl,

    // New support data
    this.categories = const [],
    this.currentSession,
    this.mySessions = const [],
    this.myUnreadSessionsCount = 0,

    // Tenant data
    this.currentTenant,

    // current locale
    this.currentLocale,

    // start session on category id
    this.startSessionOnCategoryId,
  });

  SMSupportState copyWith({
    // Legacy ticket management status
    BaseStatus? getTicketsStatus,
    BaseStatus? getChatStreamStatus,
    BaseStatus? openTicketStatus,
    BaseStatus? pushMessageStatus,
    BaseStatus? markAsReadStatus,
    BaseStatus? reOpenTicketStatus,

    BaseStatus? rateTicketStatus,

    // New support API status
    BaseStatus? getCategoriesStatus,
    BaseStatus? startSessionStatus,
    BaseStatus? assignSessionStatus,
    BaseStatus? getMySessionsStatus,
    BaseStatus? getMyUnreadSessionsStatus,
    BaseStatus? getMySessionMessagesStatus,
    BaseStatus? uploadFileStatus,
    BaseStatus? reopenSessionStatus,

    String? reopenSessionId,
    bool? isResetReopenSessionId,

    bool? isGetSessionsBefore,

    // Tenant status
    BaseStatus? getTenantStatus,

    // Legacy data
    File? pickedFile,
    bool? isResetPickedFile,
    String? downloadedUrl,
    bool? isResetDownloadedUrl,

    // New support data
    List<CategoryModel>? categories,
    MySessionModel? currentSession,
    bool? isResetCurrentSession,
    List<MySessionModel>? mySessions,
    int? myUnreadSessionsCount,

    // Tenant data
    TenantModel? currentTenant,
    bool? isResetCurrentTenant,

    String? currentLocale,

    // start session on category id
    int? startSessionOnCategoryId,
    bool? isResetStartSessionOnCategoryId,
  }) {
    return SMSupportState(
      // Legacy ticket management status
      // getTicketsStatus: getTicketsStatus ?? this.getTicketsStatus,
      // getChatStreamStatus: getChatStreamStatus ?? this.getChatStreamStatus,
      // openTicketStatus: openTicketStatus ?? this.openTicketStatus,
      // pushMessageStatus: pushMessageStatus ?? this.pushMessageStatus,
      // markAsReadStatus: markAsReadStatus ?? this.markAsReadStatus,
      // reOpenTicketStatus: reOpenTicketStatus ?? this.reOpenTicketStatus,
      // uploadFileStatus: uploadFileStatus ?? this.uploadFileStatus,
      // rateTicketStatus: rateTicketStatus ?? this.rateTicketStatus,

      // New support API status
      getCategoriesStatus: getCategoriesStatus ?? this.getCategoriesStatus,
      startSessionStatus: startSessionStatus ?? this.startSessionStatus,
      assignSessionStatus: assignSessionStatus ?? this.assignSessionStatus,
      getMySessionsStatus: getMySessionsStatus ?? this.getMySessionsStatus,
      getMyUnreadSessionsStatus: getMyUnreadSessionsStatus ?? this.getMyUnreadSessionsStatus,
      getMySessionMessagesStatus: getMySessionMessagesStatus ?? this.getMySessionMessagesStatus,
      uploadFileStatus: uploadFileStatus ?? this.uploadFileStatus,
      reopenSessionStatus: reopenSessionStatus ?? this.reopenSessionStatus,
      reopenSessionId: reopenSessionId ?? (isResetReopenSessionId == true ? null : this.reopenSessionId),
      isGetSessionsBefore: isGetSessionsBefore ?? this.isGetSessionsBefore,
      // Tenant status
      getTenantStatus: getTenantStatus ?? this.getTenantStatus,

      // Legacy data
      pickedFile: pickedFile ?? (isResetPickedFile == true ? null : this.pickedFile),
      downloadedUrl: downloadedUrl ?? (isResetDownloadedUrl == true ? null : this.downloadedUrl),

      // New support data
      categories: categories ?? this.categories,
      currentSession: currentSession ?? (isResetCurrentSession == true ? null : this.currentSession),
      mySessions: mySessions ?? this.mySessions,
      myUnreadSessionsCount: myUnreadSessionsCount ?? this.myUnreadSessionsCount,

      // Tenant data
      currentTenant: currentTenant ?? (isResetCurrentTenant == true ? null : this.currentTenant),

      // current locale
      currentLocale: currentLocale ?? this.currentLocale,

      // start session on category id
      startSessionOnCategoryId:
          startSessionOnCategoryId ?? (isResetStartSessionOnCategoryId == true ? null : this.startSessionOnCategoryId),
    );
  }

  @override
  List<Object?> get props => [
    // Legacy ticket management status
    // getTicketsStatus,
    // getChatStreamStatus,
    // openTicketStatus,
    // pushMessageStatus,
    // markAsReadStatus,
    // reOpenTicketStatus,
    // uploadFileStatus,
    // rateTicketStatus,

    // New support API status
    getCategoriesStatus,
    startSessionStatus,
    assignSessionStatus,
    getMySessionsStatus,
    getMyUnreadSessionsStatus,
    getMySessionMessagesStatus,
    uploadFileStatus,
    reopenSessionStatus,
    reopenSessionId,

    isGetSessionsBefore,

    // Tenant status
    getTenantStatus,

    // Legacy data
    pickedFile,
    downloadedUrl,

    // New support data
    categories,
    currentSession,
    mySessions,
    myUnreadSessionsCount,

    // Tenant data
    currentTenant,

    // start session on category id
    startSessionOnCategoryId,
  ];

  // List<TicketModel> get activeTickets => userTickets.where((element) => element.status.isActive).toList();
  // bool get isPushMessageButtonLoading {
  //   smPrint('openTicketStatus isLoading: ${openTicketStatus.isLoading}');
  //   smPrint('pushMessageStatus isLoading: ${pushMessageStatus.isLoading}');
  //   smPrint('uploadFileStatus isLoading: ${uploadFileStatus.isLoading}');
  //   return openTicketStatus.isLoading || pushMessageStatus.isLoading || uploadFileStatus.isLoading;
  // }

  int get chatsHaveUnreadMessages {
    int count = 0;
    for (var session in mySessions) {
      if (session.metadata.unreadCount > 0) {
        count++;
      }
    }
    return count;
  }

  List<MySessionModel> get sortedSessions {
    // mySessions.sort((a, b) {
    //   return (b.metadata.lastMessageAt ?? DateTime(1900)).compareTo(a.metadata.lastMessageAt ?? DateTime(1900));
    // });
    return mySessions;
  }

  MediaType get pickedFileType => pickedFile != null ? Utils.getMediaType(pickedFile!) : MediaType.other;

  MySessionModel? getSessionById(String sessionId) {
    return mySessions.firstWhereOrNull((element) => element.id == sessionId);
  }

  // New convenience getters for the API
  bool get isAuthenticated => AuthManager.isAuthenticated;

  bool get hasActiveSession => currentSession != null;

  bool get isLoadingSession => startSessionStatus.isLoading || assignSessionStatus.isLoading;

  String? get currentSessionId => currentSession?.id;


  CategoryModel? getCategoryById(int categoryId) {
    return categories.firstWhereOrNull((category) => category.id == categoryId);
  }
}
