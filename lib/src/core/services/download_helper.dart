import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/main.dart';

class DownloadHelper {
  static Future<void> downloadAttachment({required String url, required String name}) async {
    try {
      Duration timeOut = const Duration(seconds: 10);

      BaseOptions options = BaseOptions(
        connectTimeout: timeOut,
        receiveTimeout: timeOut,
      );

      Dio dio = Dio(options);

      // Get the app's documents directory
      String savePath = await getPhoneDownloadsDirectoryPath(name);

      // Start downloading the file
      await dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print("${(received / total * 100).toStringAsFixed(0)}%");
        }
      });

      final result = await OpenFilex.open(savePath);

      if (result.type != ResultType.done) {
        smPrint('Error: ${result.message}');
        primarySnackBar(smNavigatorKey.currentContext!, message: SMText.somethingWentWrong);
      }
    } catch (e) {
      smPrint('Error: $e');
      primarySnackBar(smNavigatorKey.currentContext!, message: SMText.somethingWentWrong);
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
      print("Error getting file size: $e");
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
