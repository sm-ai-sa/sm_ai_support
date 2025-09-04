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
import 'package:sm_ai_support/src/support/cubit/single_session_state.dart';

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
                      backgroundColor: _messageController.text.isNotEmpty
                          ? ColorsPallets.primaryColor.withValues(alpha: .9)
                          : ColorsPallets.primaryColor.withValues(alpha: .3),
                      child: (state.sendMessageStatus.isLoading || 
                              state.uploadFileStatus.isLoading || 
                              state.createSessionStatus.isLoading)
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
          children: [
            SizedBox(height: 34.rh),
            // InkWell(
            //   onTap: () async {
            //     //* Pick File
            //     context.smPop();
            //     await context.read<SingleSessionCubit>().pickAndUploadMedia(
            //       context,
            //       isFile: true,
            //     );
            //   },
            //   child: Row(
            //     children: [
            //       DesignSystem.svgIcon('gallery', size: 24.rSp),
            //       SizedBox(width: 14.rw),
            //       Text(SMText.attachFile, style: TextStyles.s_13_400),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 30.rh),
            InkWell(
              onTap: () async {
                //* Pick From Gallery
                context.smPop();
                await context.read<SingleSessionCubit>().pickAndUploadMedia(context, isFile: false);
              },
              child: Row(
                children: [
                  DesignSystem.svgIcon('gallery', size: 24.rSp),
                  SizedBox(width: 14.rw),
                  Text(SMText.attachFromLibrary, style: TextStyles.s_13_400),
                ],
              ),
            ),
            SizedBox(height: 30.rh),
            InkWell(
              onTap: () async {
                //* Pick From Camera
                context.smPop();
                await context.read<SingleSessionCubit>().pickAndUploadCameraImage(context);
              },
              child: Row(
                children: [
                  DesignSystem.svgIcon('camera', size: 24.rSp),
                  SizedBox(width: 14.rw),
                  Text(SMText.attachFromCamera, style: TextStyles.s_13_400),
                ],
              ),
            ),
            SizedBox(height: 52.rh),
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
