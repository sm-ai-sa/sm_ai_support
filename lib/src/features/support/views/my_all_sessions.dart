import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/shimmer_items.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/session_item.dart';

class MySessions extends StatefulWidget {
  const MySessions({super.key});

  @override
  State<MySessions> createState() => _MySessionsState();
}

class _MySessionsState extends State<MySessions> {
  @override
  void initState() {
    super.initState();
    smCubit.getMySessions();
    // Start the session stats stream for real-time updates
    smCubit.startSessionStatsStream();
  }

  @override
  void dispose() {
    // Stop the session stats stream when leaving the page
    // Add safety check to prevent errors during rapid dismissal
    try {
      smCubit.stopSessionStatsStream();
    } catch (e) {
      // Silently handle disposal errors
      smPrint('Error during MySessions disposal: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.rw),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  __appBar(),
                  Divider(color: ColorsPallets.disabled25, thickness: 1),
                  if (state.getMySessionsStatus.isLoading && !state.isGetSessionsBefore) ...[
                    ...List.generate(3, (index) {
                      return ShimmerItems.ticketShimmer();
                    }),
                  ] else ...[
                    if (state.sortedSessions.isEmpty) ...[
                      __emptySessions(),
                    ] else ...[
                      ...List.generate(state.sortedSessions.length, (index) {
                        return SessionItem(
                          session: state.sortedSessions[index],
                          isLast: index == state.sortedSessions.length - 1,
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget __emptySessions() {
    return Column(
      children: [
        SizedBox(height: 200.rh),
        DesignSystem.chatGif(),
        SizedBox(height: 20.rh),
        Text(SMText.noChats, style: TextStyles.s_16_400),
      ],
    );
  }

  Padding __appBar() {
    return Padding(
      padding: EdgeInsets.only(top: 58.rh, bottom: 14.rh),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            flex: 3,
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: DesignSystem.backButton(color: ColorsPallets.loud900),
            ),
          ),
          Flexible(
            flex: 7,
            child: InkWell(
              onTap: () {
                // smCubit.pushMessage(
                //   ticketId: '328f6e6f-21c4-4f05-a9b4-1722bc9b48ea',
                //   message: DummyDate.adminMessage,
                // );
              },
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Text(SMText.myMessages, style: TextStyles.s_16_400),
              ),
            ),
          ),
          const Flexible(flex: 3, child: SizedBox()),
        ],
      ),
    );
  }
}
