// import 'package:collection/collection.dart';
// import 'package:equatable/equatable.dart';
// import 'package:sm_ai_support/sm_ai_support.dart';
// import 'package:sm_ai_support/src/core/models/message_model.dart';
// import 'package:sm_ai_support/src/core/models/refund_model.dart';
// import 'package:sm_ai_support/src/core/models/status_log.dart';

// class TicketModel extends Equatable {
//   final String ticketId;
//   final String userId;
//   final String categoryId;
//   final TicketStatus status;
//   final DateTime createdAt;
//   final List<StatusLog> statusLogs;
//   final bool isAdminTyping;
//   final bool isUserTyping;
//   final RefundModel? refund;
//   final num? rate;

//   // local
//   final MessageModel? lastMessage;
//   TicketModel({
//     required this.ticketId,
//     required this.userId,
//     required this.categoryId,
//     this.status = TicketStatus.active,
//     this.lastMessage,
//     this.statusLogs = const [],
//     DateTime? createdAt,
//     this.isAdminTyping = false,
//     this.isUserTyping = false,
//     this.refund,
//     this.rate,
//   }) : createdAt = createdAt ?? DateTime.now();

//   factory TicketModel.fromJson(Map<String, dynamic> json) {
//     return TicketModel(
//       ticketId: json['ticketId'],
//       userId: json['userId'],
//       categoryId: json['categoryId'] ?? "",
//       status: TicketStatus.fromString(json['status']),
//       createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
//       statusLogs:
//           json['statusLogs'] != null ? List<StatusLog>.from(json['statusLogs'].map((x) => StatusLog.fromJson(x))) : [],
//       isAdminTyping: json['inAdminTyping'] ?? false,
//       isUserTyping: json['isUserTyping'] ?? false,
//       refund: json['refund'] != null ? RefundModel.fromJson(json['refund']) : null,
//       rate: json['rate'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     Map<String, dynamic> data = {
//       'ticketId': ticketId,
//       'userId': userId,
//       'categoryId': categoryId,
//       'status': status.name,
//       'createdAt': createdAt.toIso8601String(),
//       'statusLogs': statusLogs.map((x) => x.toJson()).toList(),
//       'isAdminTyping': isAdminTyping,
//       'isUserTyping': isUserTyping,
//       'refund': refund?.toJson(),
//       'rate': rate,
//     };

//     data.removeWhere((key, value) => value == null);
//     return data;
//   }

//   // copyWith
//   TicketModel copyWith({
//     String? ticketId,
//     String? userId,
//     String? categoryId,
//     TicketStatus? status,
//     String? summary,
//     num? rate,
//     DateTime? createdAt,
//     MessageModel? lastMessage,
//     List<StatusLog>? statusLogs,
//     bool? isAdminTyping,
//     bool? isUserTyping,
//     RefundModel? refund,
//   }) {
//     return TicketModel(
//       ticketId: ticketId ?? this.ticketId,
//       userId: userId ?? this.userId,
//       categoryId: categoryId ?? this.categoryId,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       lastMessage: lastMessage ?? this.lastMessage,
//       statusLogs: statusLogs ?? this.statusLogs,
//       isAdminTyping: isAdminTyping ?? this.isAdminTyping,
//       isUserTyping: isUserTyping ?? this.isUserTyping,
//       refund: refund ?? this.refund,
//       rate: rate ?? this.rate,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         ticketId,
//         userId,
//         categoryId,
//         lastMessage,
//         status,
//         createdAt,
//         statusLogs,
//         isAdminTyping,
//         isUserTyping,
//         refund,
//         rate,
//       ];

//   int get unUnreadMessagesCount =>
//       smCubit.state.getChatMessages(ticketId).where((msg) => !msg.isRead && !msg.isSentByMe).length;

//   bool get hasUnreadMessages => unUnreadMessagesCount > 0;

//   DateTime? get closedDate {
//     final closedStatus = statusLogs.lastWhereOrNull((log) => log.changedToStatus.isClosed);
//     return closedStatus?.date;
//   }

//   bool get canReopen =>
//       status.isClosed &&
//       (closedDate != null &&
//           closedDate!.isAfter(
//             DateTime.now().subtract(
//               Duration(
//                 days: 7,
//               ),
//             ),
//           ));

//   CategoryModel? get category {
//     // Try to find category from cubit state first
//     final categories = smCubit.state.categories;
//     if (categories.isNotEmpty) {
//       try {
//         final foundCategory = categories.firstWhere((cat) => cat.id.toString() == categoryId);
//         return foundCategory;
//       } catch (e) {
//         // Fallback if category not found
//         return CategoryModel(
//           id: int.tryParse(categoryId) ?? 0,
//           description: 'General Support',
//           icon: 'help',
//         );
//       }
//     }
    
//     // Return null if no categories loaded - UI should handle this gracefully
//     return null;
//   }
// }
