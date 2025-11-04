import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

class DownloadHelper {
  static Future<void> downloadAttachment({required String url, required String name}) async {
    try {
      smPrint('📥 Starting download: $name');
      smPrint('📍 URL: $url');

      // Set longer timeout for file downloads (2 minutes)
      Duration timeOut = const Duration(seconds: 120);

      BaseOptions options = BaseOptions(
        connectTimeout: timeOut,
        receiveTimeout: timeOut,
      );

      Dio dio = Dio(options);

      // Get the app's documents directory
      String savePath = await getPhoneDownloadsDirectoryPath(name);
      smPrint('💾 Save path: $savePath');

      // Start downloading the file
      await dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          smPrint("📊 Download progress: $progress%");
        }
      });

      smPrint('✅ Download completed, attempting to open file...');

      final result = await OpenFilex.open(savePath);

      if (result.type == ResultType.done) {
        smPrint('✅ File opened successfully');
      } else {
        smPrint('❌ Failed to open file - Type: ${result.type}, Message: ${result.message}');
        primarySnackBar(smNavigatorKey.currentContext!, message: 'File downloaded but could not be opened');
      }
    } catch (e, stackTrace) {
      smPrint('❌ Download error: $e');
      smPrint('📚 Stack trace: $stackTrace');

      String errorMessage = SMText.somethingWentWrong;
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet connection.';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Download timeout. File may be too large.';
        } else {
          errorMessage = 'Download failed: ${e.message}';
        }
      }

      if (smNavigatorKey.currentContext != null) {
        primarySnackBar(smNavigatorKey.currentContext!, message: errorMessage);
      }
    }
  }

  static Future<String> getPhoneDownloadsDirectoryPath(String fileName) async {
    String? downloadsPath = (await getApplicationDocumentsDirectory()).path;

    return path.join(downloadsPath, fileName);
  }

  static Future<int?> getFileSize(String fileUrl) async {
    try {
      final response = await Dio().head(fileUrl);

      if (response.statusCode == 200) {
        final contentLength = response.headers.value('content-length');
        if (contentLength != null) {
          return int.parse(contentLength);
        }
      }
    } catch (e) {
      smPrint("❌ Error getting file size: $e");
    }
    return null;
  }

  // Map<String, String> mimeTypeToExtension = {
  //   'application/pdf': 'pdf',
  //   'application/zip': 'zip',
  //   'application/msword': 'doc',
  //   'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
  //   'application/vnd.ms-excel': 'xls',
  //   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
  //   'application/vnd.ms-powerpoint': 'ppt',
  //   'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'pptx',
  //   'application/json': 'json',
  //   'application/xml': 'xml',
  //   'image/jpeg': 'jpg',
  //   'image/png': 'png',
  //   'image/gif': 'gif',
  //   'video/mp4': 'mp4',
  //   'audio/mpeg': 'mp3',
  //   'audio/wav': 'wav',
  // };
}
