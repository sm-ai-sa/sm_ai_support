// import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
// import 'package:sm_ai_support/src/core/utils/enums.dart';

// /// Dummy messages for testing all message types
// /// This is useful for UI testing and development
// class DummyMessages {
//   DummyMessages._();

//   /// Flag to enable/disable dummy messages (set to false in production)
//   static const bool enableDummyMessages = true;

//   /// Get all dummy messages for testing
//   static List<SessionMessage> getAllDummyMessages() {
//     if (!enableDummyMessages) return [];

//     return [
//       // 1. TEXT - Customer
//       SessionMessage(
//         id: 'dummy_text_1',
//         content: 'Hello! I need help with my account.',
//         contentType: SessionMessageContentType.text,
//         senderType: SessionMessageSenderType.customer,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 10)),
//       ),

//       // 2. TEXT with URL - Admin
//       SessionMessage(
//         id: 'dummy_text_2',
//         content: 'Hi! I can help you. Please visit https://support.example.com for more information.',
//         contentType: SessionMessageContentType.text,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 9)),
//         admin: {'firstName': 'Sarah', 'lastName': 'Support'},
//       ),

//       // 3. IMAGE - Customer (Landscape Photo)
//       SessionMessage(
//         id: 'dummy_image_1',
//         content: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800&q=80',
//         contentType: SessionMessageContentType.image,
//         senderType: SessionMessageSenderType.customer,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 8)),
//       ),

//       // 4. IMAGE - Admin (Nature Photo)
//       SessionMessage(
//         id: 'dummy_image_2',
//         content: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800&q=80',
//         contentType: SessionMessageContentType.image,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 7)),
//         admin: {'firstName': 'Sarah', 'lastName': 'Support'},
//       ),

//       // 5. VIDEO - Customer (Short Sample Video ~30 seconds)
//       SessionMessage(
//         id: 'dummy_video_1',
//         content: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//         contentType: SessionMessageContentType.video,
//         senderType: SessionMessageSenderType.customer,
//         isRead: false,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 6)),
//       ),

//       // 6. VIDEO - Admin (Short Demo Video ~15 seconds)
//       SessionMessage(
//         id: 'dummy_video_2',
//         content: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//         contentType: SessionMessageContentType.video,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 5)),
//         admin: {'firstName': 'John', 'lastName': 'Tech Support'},
//       ),

//       // 7. AUDIO - Customer (Sample Audio)
//       SessionMessage(
//         id: 'dummy_audio_1',
//         content: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
//         contentType: SessionMessageContentType.audio,
//         senderType: SessionMessageSenderType.customer,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 4)),
//       ),

//       // 8. AUDIO - Admin (Support Response)
//       SessionMessage(
//         id: 'dummy_audio_2',
//         content: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
//         contentType: SessionMessageContentType.audio,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 3)),
//         admin: {'firstName': 'Sarah', 'lastName': 'Support'},
//       ),

//       // 9. FILE - Customer (PDF Sample)
//       SessionMessage(
//         id: 'dummy_file_1',
//         content: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
//         contentType: SessionMessageContentType.file,
//         senderType: SessionMessageSenderType.customer,
//         isRead: false,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 2)),
//         metadata: {'fileSize': 2457600}, // 2.4 MB
//       ),

//       // 10. FILE - Admin (Sample Document)
//       SessionMessage(
//         id: 'dummy_file_2',
//         content: 'https://file-examples.com/storage/fe783a6e5a66e95016ca91d/2017/02/file-sample_100kB.doc',
//         contentType: SessionMessageContentType.file,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(minutes: 1)),
//         admin: {'firstName': 'John', 'lastName': 'Tech Support'},
//         metadata: {'fileSize': 1048576}, // 1 MB
//       ),

//       // 11. FILE - Customer (Excel Sample)
//       SessionMessage(
//         id: 'dummy_file_3',
//         content: 'https://file-examples.com/storage/fe783a6e5a66e95016ca91d/2017/02/file_example_XLS_10.xls',
//         contentType: SessionMessageContentType.file,
//         senderType: SessionMessageSenderType.customer,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 50)),
//         metadata: {'fileSize': 524288}, // 512 KB
//       ),

//       // 12. UNSUPPORTED_MEDIA - Admin
//       SessionMessage(
//         id: 'dummy_unsupported_1',
//         content: 'unknown_file.xyz',
//         contentType: SessionMessageContentType.unsupportedMedia,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 40)),
//         admin: {'firstName': 'Sarah', 'lastName': 'Support'},
//       ),

//       // 13. NEED_AUTH - Admin
//       SessionMessage(
//         id: 'dummy_need_auth_1',
//         content: 'Please confirm your identity to proceed',
//         contentType: SessionMessageContentType.needAuth,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 30)),
//         admin: {'firstName': 'System', 'lastName': 'Bot'},
//       ),

//       // 14. AUTHORIZED - System
//       SessionMessage(
//         id: 'dummy_authorized_1',
//         content: 'Identity verified successfully',
//         contentType: SessionMessageContentType.authorized,
//         senderType: SessionMessageSenderType.system,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 20)),
//       ),

//       // 15. TEXT with Reply - Customer
//       SessionMessage(
//         id: 'dummy_text_with_reply_1',
//         content: 'Yes, that would be great!',
//         contentType: SessionMessageContentType.text,
//         senderType: SessionMessageSenderType.customer,
//         isRead: false,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 15)),
//         reply: SessionMessageReply(
//           message: 'Would you like me to send you the user guide?',
//           messageId: 'dummy_file_2',
//           contentType: 'TEXT',
//         ),
//       ),

//       // 16. CLOSE_SESSION - System
//       SessionMessage(
//         id: 'dummy_close_session_1',
//         content: 'Session closed',
//         contentType: SessionMessageContentType.closeSession,
//         senderType: SessionMessageSenderType.system,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 10)),
//       ),

//       // 17. REOPEN_SESSION - System
//       SessionMessage(
//         id: 'dummy_reopen_session_1',
//         content: 'Session reopened',
//         contentType: SessionMessageContentType.reopenSession,
//         senderType: SessionMessageSenderType.system,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 8)),
//       ),

//       // 18. CLOSE_SESSION_BY_SYSTEM - System
//       SessionMessage(
//         id: 'dummy_close_by_system_1',
//         content: 'Session closed due to inactivity',
//         contentType: SessionMessageContentType.closeSessionBySystem,
//         senderType: SessionMessageSenderType.system,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 5)),
//       ),

//       // 19. Optimistic Message - Customer (uploading)
//       SessionMessage(
//         id: 'dummy_optimistic_1',
//         content: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
//         contentType: SessionMessageContentType.image,
//         senderType: SessionMessageSenderType.customer,
//         isRead: false,
//         isDelivered: false,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 2)),
//         isOptimistic: true,
//       ),

//       // 20. Long Text - Admin
//       SessionMessage(
//         id: 'dummy_long_text_1',
//         content: '''Thank you for contacting support! I understand you're having issues with your account. 

// Here are some steps you can try:
// 1. Clear your browser cache
// 2. Try logging in with a different browser
// 3. Reset your password if needed

// Let me know if any of these help! I'm here to assist you further.''',
//         contentType: SessionMessageContentType.text,
//         senderType: SessionMessageSenderType.admin,
//         isRead: true,
//         isDelivered: true,
//         isFailed: false,
//         createdAt: DateTime.now().subtract(Duration(seconds: 1)),
//         admin: {'firstName': 'Sarah', 'lastName': 'Support'},
//       ),
//     ];
//   }

//   /// Get only specific message types for targeted testing
//   static List<SessionMessage> getMessagesByType(SessionMessageContentType type) {
//     return getAllDummyMessages().where((msg) => msg.contentType == type).toList();
//   }

//   /// Get messages by sender type
//   static List<SessionMessage> getMessagesBySender(SessionMessageSenderType sender) {
//     return getAllDummyMessages().where((msg) => msg.senderType == sender).toList();
//   }

//   /// Get customer messages only
//   static List<SessionMessage> getCustomerMessages() {
//     return getMessagesBySender(SessionMessageSenderType.customer);
//   }

//   /// Get admin messages only
//   static List<SessionMessage> getAdminMessages() {
//     return getMessagesBySender(SessionMessageSenderType.admin);
//   }

//   /// Get system messages only
//   static List<SessionMessage> getSystemMessages() {
//     return getMessagesBySender(SessionMessageSenderType.system);
//   }
// }

