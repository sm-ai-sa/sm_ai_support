import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class SimpleLoadingAnimation extends StatefulWidget {
  const SimpleLoadingAnimation({super.key});

  @override
  State<SimpleLoadingAnimation> createState() => _SimpleLoadingAnimationState();
}

class _SimpleLoadingAnimationState extends State<SimpleLoadingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorsPallets.white,
            ColorsPallets.black.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: EdgeInsets.all(24.rSp),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsPallets.subdued400.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: ColorsPallets.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.support_agent_outlined,
                size: 64.rSp,
                color: ColorsPallets.black,
              ),
            ),

            SizedBox(height: 40.rh),

            // Loading dots
            SizedBox(
              height: 20.rh,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double delay = index * 0.2;
                      final double value = (_controller.value + delay) % 1.0;
                      final double opacity = 0.3 + (0.7 * (0.5 - (value - 0.5).abs()) * 2);

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.rw),
                        width: 8.rw,
                        height: 8.rh,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsPallets.black.withValues(alpha: opacity),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),

            SizedBox(height: 24.rh),

            // Title
            Text(
              "SM AI",
              textDirection: TextDirection.ltr,
              style: TextStyles.s_24_700.copyWith(color: ColorsPallets.black ),
            ),

            SizedBox(height: 8.rh),

            // Subtitle
            Text(
              SMText.welcomeOnSm,
              style: TextStyles.s_16_400.copyWith(color: ColorsPallets.subdued400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
