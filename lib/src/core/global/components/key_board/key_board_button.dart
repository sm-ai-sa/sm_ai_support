import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class KeyBoardButton extends StatefulWidget {
  final String? text;
  final String? svgIcon;
  final Function()? onTap;
  const KeyBoardButton({super.key, this.onTap, this.svgIcon, this.text});

  @override
  State<KeyBoardButton> createState() => _KeyBoardButtonState();
}

class _KeyBoardButtonState extends State<KeyBoardButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.onTap != null) {
          widget.onTap!();
        }
        setState(() {
          _isPressed = true;
        });
        Future.delayed(200.milliseconds, () {
          setState(() {
            _isPressed = false;
          });
        });
      },
      child: AnimatedContainer(
        duration: 300.milliseconds,
        height: 55.rh,
        width: 90.rw,
        decoration: BoxDecoration(
          borderRadius: 14.rSp.br,
          color: _isPressed ? Colors.grey.withOpacity(.4) : ColorsPallets.transparent,
        ),
        child: Center(
          child: (widget.text != null)
              ? Text(widget.text!, style: TextStyles.s_18_500)
              : (widget.svgIcon != null)
              ? DesignSystem.svgIcon(widget.svgIcon!, size: 26.rSp)
              : const SizedBox(),
        ),
      ),
    );
  }
}
