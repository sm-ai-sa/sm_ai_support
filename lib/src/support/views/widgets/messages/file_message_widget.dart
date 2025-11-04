import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/models/upload_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/file_utils.dart';
import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// File message widget with icon, name, size, and download button
class FileMessageWidget extends StatefulWidget {
  final SessionMessage message;
  final bool isMyMessage;
  final String sessionId;
  final Color? tenantColor;

  const FileMessageWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.sessionId,
    this.tenantColor,
  });

  @override
  State<FileMessageWidget> createState() => _FileMessageWidgetState();
}

class _FileMessageWidgetState extends State<FileMessageWidget> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final fileName = FileUtils.getFileDisplayName(widget.message.content);
    final fileSize = widget.message.fileSize;
    final fileIcon = FileUtils.getFileIcon(widget.message.content);
    final adminBgColor = (widget.tenantColor ?? ColorsPallets.primaryColor).withValues(alpha: .2);
    final adminBorderColor = (widget.isMyMessage ? ColorsPallets.muted600 : widget.tenantColor ?? ColorsPallets.primaryColor)
        .withValues(alpha: .25);

    return Container(
      padding: EdgeInsets.all(10.rSp),
      decoration: BoxDecoration(
        color: widget.isMyMessage ? ColorsPallets.normal25 : adminBgColor,
        border: Border.all(color: widget.isMyMessage ? ColorsPallets.borderColor : adminBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon
          DesignSystem.svgIcon(fileIcon, size: 30.rSp, path: 'assets/icons/files/', fit: BoxFit.contain),
          SizedBox(width: 10.rw),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyles.s_13_500.copyWith(color: ColorsPallets.muted600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null) ...[
                  SizedBox(height: 2.rh),
                  Text(
                    FileUtils.formatFileSize(fileSize),
                    style: TextStyles.s_11_400.copyWith(color: ColorsPallets.subdued400),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.rw),
          // Download/Open button
          InkWell(
            onTap: (widget.message.isOptimistic || _isDownloading) ? null : () => _downloadFile(),
            child: Container(
              padding: EdgeInsets.all(6.rSp),
              decoration: BoxDecoration(
                // color: (widget.message.isOptimistic || _isDownloading)
                //     ? ColorsPallets.disabled0
                //     : ColorsPallets.primary25,
                borderRadius: BorderRadius.circular(6),
              ),
              child: (widget.message.isOptimistic || _isDownloading)
                  ? SizedBox(
                      width: 16.rSp,
                      height: 16.rSp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorsPallets.subdued400),
                      ),
                    )
                  : Icon(Icons.download, color: ColorsPallets.muted600, size: 16.rSp),
            ),
          ),
        ],
      ),
    );
  }

  /// Download or open file using url_launcher
  Future<void> _downloadFile() async {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
    });

    try {
      String? fileUrl = widget.message.content;

      // Resolve URL if needed
      if (!ImageUrlResolver.isDirectDownloadUrl(widget.message.content)) {
        final fileName = ImageUrlResolver.extractFileName(widget.message.content);
        fileUrl = await ImageUrlResolver.resolveMediaUrl(
          fileName: fileName,
          sessionId: widget.sessionId,
          category: FileUploadCategory.sessionMedia,
        );
      }

      if (fileUrl != null) {
        smPrint('📥 Downloading/Opening file: $fileUrl');

        final uri = Uri.parse(fileUrl);

        // Check if the URL can be launched
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Opens in external app/browser
          );

          if (launched) {
            smPrint('✅ File opened successfully');
          } else {
            smPrint('❌ Failed to open file');
          }
        } else {
          smPrint('❌ Cannot open file URL: $fileUrl');
        }
      } else {
        smPrint('❌ File URL is null');
      }
    } catch (e) {
      smPrint('❌ Error downloading/opening file: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }
}
