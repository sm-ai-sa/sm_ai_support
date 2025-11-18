// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/categories/categories_app_bar.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/categories/categories_header.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/categories/categories_list.dart';
import 'package:sm_ai_support/src/features/support/views/widgets/categories/my_chats_button.dart';

/// Main categories bottom sheet view
/// Refactored into smaller, reusable components
class SMSupportCategoriesBs extends StatefulWidget {
  const SMSupportCategoriesBs({super.key});

  @override
  State<SMSupportCategoriesBs> createState() => _SMSupportCategoriesBsState();
}

class _SMSupportCategoriesBsState extends State<SMSupportCategoriesBs> {
  bool _isDisposed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    smCubit.getCategories();
    if (AuthManager.isAuthenticated) {
      smCubit.getMyUnreadSessions();
      // Start the unread sessions count stream for real-time updates
      smCubit.startUnreadSessionsCountStream();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Dispose scroll controller first to prevent errors
    try {
      _scrollController.dispose();
    } catch (e) {
      smPrint('Error disposing scroll controller: $e');
    }

    // Stop the unread sessions count stream when leaving the page
    // Add safety check to prevent errors during rapid dismissal
    try {
      if (AuthManager.isAuthenticated) {
        smCubit.stopUnreadSessionsCountStream();
      }
    } catch (e) {
      // Silently handle disposal errors (widget already disposed)
      smPrint('Error during SMSupportCategoriesBs disposal: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SMSupportCubit, SMSupportState>(
      listenWhen: (previous, current) => !_isDisposed,
      buildWhen: (previous, current) => !_isDisposed,
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.rw),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: 20.rh),
                CategoriesAppBar(isDisposed: _isDisposed),
                const CategoriesHeader(),
                MyChatsButton(isDisposed: _isDisposed),
                SizedBox(height: 20.rh),
                CategoriesList(state: state),
                SizedBox(height: 30.rh),
              ],
            ),
          ),
        );
      },
    );
  }
}
