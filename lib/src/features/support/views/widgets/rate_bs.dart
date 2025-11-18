import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/support/cubit/single_session_state.dart';

class RateBS extends StatefulWidget {
  final String sessionId;
  final SingleSessionCubit sessionCubit;
  const RateBS({super.key, required this.sessionId, required this.sessionCubit});

  @override
  State<RateBS> createState() => _RateBSState();
}

class _RateBSState extends State<RateBS> {
  double rate = 0;
  final TextEditingController _commentController = TextEditingController();
  static const int maxCommentLength = 150;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.sessionCubit,
      child: BlocConsumer<SingleSessionCubit, SingleSessionState>(
        listenWhen: (previous, current) => previous.rateSessionStatus != current.rateSessionStatus,
        listener: (context, state) {
          if (state.rateSessionStatus.isSuccess) {
            context.smPop();
            primarySnackBar(context, message: SMText.reviewSentSuccessfully, pngIcon: 'great');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                SizedBox(height: 34.rh),
                Text(SMText.rateTheConversation, style: TextStyles.s_20_400),
                SizedBox(height: 5.rh),
                Text(
                  SMText.rateTheConversationDescription,
                  textAlign: TextAlign.center,
                  style: TextStyles.s_13_400.copyWith(color: ColorsPallets.subdued400),
                ),
                SizedBox(height: 20.rh),
                DesignSystem.starsRating(
                  starSize: 32.rSp,
                  value: rate,
                  starOffColor: ColorsPallets.solid200,
                  isOnlyShow: state.rateSessionStatus.isLoading,
                  onRateChanged: (v) {
                    rate = v;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20.rh),
                // Comment field
                if (rate > 0) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: ColorsPallets.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _commentController.text.length > maxCommentLength
                            ? ColorsPallets.secondaryRed100
                            : ColorsPallets.solid200,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: SMText.tellUsMoreAboutYourExperience,
                              hintStyle: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 20), // Add bottom padding for counter
                            ),
                            style: TextStyles.s_14_400,
                            maxLines: 4,
                            minLines: 1,
                            maxLength: null, // We'll handle the limit manually
                            onChanged: (value) {
                              setState(() {});
                              // Prevent typing beyond maxCommentLength
                              if (value.length > maxCommentLength) {
                                _commentController.text = value.substring(0, maxCommentLength);
                                _commentController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: maxCommentLength),
                                );
                              }
                            },
                          ),
                        ),
                        // Character counter positioned at bottom-right inside the container
                        PositionedDirectional(
                          bottom: 8,
                          end: 12,
                          child: Text(
                            '${_commentController.text.length}/$maxCommentLength',
                            style: TextStyles.s_12_400.copyWith(
                              color: _commentController.text.length > maxCommentLength
                                  ? ColorsPallets.secondaryRed100
                                  : ColorsPallets.subdued400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.rh),
                ],
                // Submit button
                if (rate > 0) ...[
                  if (state.rateSessionStatus.isLoading) ...[
                    DesignSystem.loadingIndicator(color: ColorsPallets.primaryColor),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.sessionCubit.rateSession(
                            rating: rate.toInt(),
                            comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsPallets.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(SMText.submitRating, style: TextStyles.s_16_600.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ],
                SizedBox(height: 20.rh),
                // // Skip rating option
                // if (rate == 0 && !state.rateSessionStatus.isLoading) ...[
                //   InkWell(
                //     onTap: () {
                //       context.smPop();
                //     },
                //     child: Text('Skip Rating', style: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400)),
                //   ),
                // ],
                SizedBox(height: 52.rh),
              ],
            ),
          );
        },
      ),
    );
  }
}
