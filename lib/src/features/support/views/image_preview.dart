import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';

class ImagePreview extends StatelessWidget {
  final String imageUrl;
  const ImagePreview({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 22, right: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DesignSystem.closeButton(
                  iconColor: Colors.white,
                  onTap: () {
                   context.smPop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: DesignSystem.internetImage(
              imageUrl: imageUrl,
              // width: double.infinity,
              // height: 80.h,
              fit: BoxFit.contain,
              borderRadius: 12.br,
            ),
          ),
        ],
      ),
    );
  }
}
