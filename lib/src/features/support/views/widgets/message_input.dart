import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/support/cubit/single_session_state.dart';

class MessageInput extends StatefulWidget {
  final bool initTicket;
  final String sessionId;

  /// if it not opened yey
  final String ticketId;
  final Function(bool) onSend;
  final CategoryModel? category; // Category for new sessions
  final Function(String)? onSessionCreated; // Callback when session is created

  const MessageInput({
    super.key,
    required this.sessionId,
    required this.ticketId,
    this.initTicket = false,
    required this.onSend,
    this.category,
    this.onSessionCreated,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SingleSessionCubit, SingleSessionState>(
      listener: (context, state) {
        // Handle session creation
        if (state.createSessionStatus.isSuccess && state.sessionId.isNotEmpty) {
          widget.onSessionCreated?.call(state.sessionId);
        }

        if (state.sendMessageStatus.isSuccess) {
          widget.onSend(true);
          _messageController.clear();
          setState(() {});
        }

        // Handle upload status changes
        if (state.uploadFileStatus.isSuccess) {
          // File uploaded and message sent successfully
          widget.onSend(true);
        } else if (state.uploadFileStatus.isFailure) {
          // Show error message for failed upload
          // The error is already handled in the cubit with primarySnackBar
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsetsDirectional.only(start: 22.rw, end: 22.rw, bottom: 20.rh, top: 10.rh),
          child: Column(
            children: [
              //! Replied On --------------------
              __repliedOn(state),
              Row(
                children: [
                  if (AuthManager.isAuthenticated)
                    InkWell(
                      onTap: state.uploadFileStatus.isLoading
                          ? null
                          : () {
                              __pickerBottomSheet(context);
                            },
                      child: state.uploadFileStatus.isLoading
                          ? DesignSystem.loadingIndicator()
                          : DesignSystem.svgIcon('attach', size: 22.rSp),
                    ),
                  // TODO: Implement file picker functionality
                  // if (state.pickedFile != null) ...[
                  //   SizedBox(width: 8.rw),
                  //   if (Utils.getMediaType(state.pickedFile!).isImage)
                  //     ClipRRect(
                  //       borderRadius: 10.br,
                  //       child: Image.file(state.pickedFile!, width: 40.rw, height: 40.rw, fit: BoxFit.cover),
                  //     ),
                  // ],
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.rw),
                      child: TextFormField(
                        controller: _messageController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: SMText.writeYourMessageHere,
                          hintStyle: TextStyles.s_13_400.copyWith(color: ColorsPallets.disabled300),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.rw),
                  InkWell(
                    onTap: () {
                      if (_messageController.text.isNotEmpty &&
                          !state.sendMessageStatus.isLoading &&
                          !state.uploadFileStatus.isLoading &&
                          !state.createSessionStatus.isLoading) {
                        context.read<SingleSessionCubit>().sendMessage(
                          message: _messageController.text,
                          contentType: 'TEXT',
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 16.rw,
                      backgroundColor: _messageController.text.isEmpty || state.sendMessageStatus.isLoading
                          ? ColorsPallets.primaryColor.withValues(alpha: .3)
                          : ColorsPallets.primaryColor.withValues(alpha: .9),
                      child: (state.uploadFileStatus.isLoading || state.createSessionStatus.isLoading)
                          ? DesignSystem.loadingIndicator(color: Colors.white)
                          : DesignSystem.svgIcon('arrow-up', size: 18.rSp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> __pickerBottomSheet(BuildContext context) {
    return primaryBottomSheet(
      showLeadingContainer: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.rh),

            // Gallery Option - Pick photos/videos
            _buildAttachmentOption(
              context: context,
              icon: 'gallery',
              label: SMText.attachFromLibrary,
              onTap: () async {
                context.smPop();
                await context.read<SingleSessionCubit>().pickAndUploadMedia(context, isFile: true);
              },
            ),
            SizedBox(height: 16.rh),
            // Gallery Option - Pick photos/videos
            _buildAttachmentOption(
              context: context,
              icon: 'gallery',
              label: SMText.attachFromGallery,
              onTap: () async {
                context.smPop();
                await context.read<SingleSessionCubit>().pickAndUploadMedia(context, isFile: false);
              },
            ),

            SizedBox(height: 16.rh),

            // Camera Option - Take photo
            _buildAttachmentOption(
              context: context,
              icon: 'camera',
              label: SMText.attachFromCamera,
              onTap: () async {
                context.smPop();
                await context.read<SingleSessionCubit>().pickAndUploadCameraImage(context);
              },
            ),

            SizedBox(height: 32.rh),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.rh),
        child: Row(
          children: [
            // Container(
            //   padding: EdgeInsets.all(10.rSp),
            //   decoration: BoxDecoration(
            //     color: ColorsPallets.primary0,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: DesignSystem.svgIcon(icon, size: 24.rSp, color: ColorsPallets.primaryColor),
            // ),
            // SizedBox(width: 16.rw),
            // Text(label, style: TextStyles.s_14_500),
            DesignSystem.svgIcon(icon, size: 24.rSp),
            SizedBox(width: 14.rw),
            Text(label, style: TextStyles.s_13_400),
          ],
        ),
      ),
    );
  }

  AnimatedCrossFade __repliedOn(SingleSessionState state) {
    String message = state.sessionMessages.firstWhereOrNull((element) => element.id == state.repliedOn)?.content ?? '';
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 300),
      crossFadeState: state.repliedOn != null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: SMText.repliedOn,
                        style: TextStyles.s_12_400.copyWith(color: ColorsPallets.muted600),
                        children: [
                          TextSpan(
                            text: ' ${SMText.supportTeam}',
                            style: TextStyles.s_12_600.copyWith(color: ColorsPallets.muted600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.rh),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.s_12_400.copyWith(color: ColorsPallets.disabled300),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  context.read<SingleSessionCubit>().clearRepliedOn();
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: ColorsPallets.hover50,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(Icons.close, size: 10.rSp, color: ColorsPallets.muted600),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.rh),
          DesignSystem.primaryDivider(),
        ],
      ),
      secondChild: SizedBox.shrink(),
    );
  }
}
