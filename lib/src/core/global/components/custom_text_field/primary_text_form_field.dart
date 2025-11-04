import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class PrimaryTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String value)? onChanged;
  final Function()? onTap;
  final Function(String value)? onSubmitted;
  final bool isPassword;
  final FormFieldValidator? validator;
  final String? validationText;
  final bool isDisableValidation;

  final Color? fillColor;
  final bool isShowBorderLine;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final TextInputType? keyboardType;
  final String? labelText;
  final TextStyle? labelStyle;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? inputStyle;
  final TextAlign? textAlign;
  final bool isDense;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final String? topTitleText;
  final Widget? topTitleWidget;
  final TextStyle? topTitleStyle;
  final bool isEnable;
  final bool isReadOnly;
  final int? maxLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final double? height;
  final Color? cursorColor;
  final bool isOneSideBorder;
  final List<TextInputFormatter>? inputFormatters;

  const PrimaryTextFormField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.isPassword = false,
    this.validator,
    this.validationText,
    this.isDisableValidation = false,
    this.fillColor,
    this.isShowBorderLine = true,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.keyboardType = TextInputType.text,
    this.labelText,
    this.labelStyle,
    this.hintText,
    this.hintStyle,
    this.inputStyle,
    this.textAlign,
    this.isDense = true,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.topTitleText,
    this.topTitleWidget,
    this.topTitleStyle,
    this.isEnable = true,
    this.isReadOnly = false,
    this.maxLines,
    this.autofocus = false,
    this.focusNode,
    this.height = 48,
    this.cursorColor,
    this.isOneSideBorder = false,
    this.inputFormatters,
  });

  @override
  State<PrimaryTextFormField> createState() => _PrimaryTextFormFieldState();
}

class _PrimaryTextFormFieldState extends State<PrimaryTextFormField> {
  final _validationFailed = ValueNotifier<bool>(false);

  bool _isPassVisible = false;

  @override
  Widget build(BuildContext context) {
    InputBorder ordinaryBorder = OutlineInputBorder(
      borderRadius: (widget.borderRadius ?? 8.rSp).br,
      gapPadding: 0,
      borderSide: widget.isShowBorderLine
          ? BorderSide(color: widget.borderColor ?? ColorsPallets.normal25, width: 1.rSp)
          : BorderSide.none,
    );

    InputBorder oneSideBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: ColorsPallets.hover50, width: 1.rSp), // Replace with your color
    );

    InputBorder errorBorder = OutlineInputBorder(
      borderRadius: (widget.borderRadius ?? 8.rSp).br,
      gapPadding: 0,
      borderSide: widget.isShowBorderLine
          ? BorderSide(color: ColorsPallets.secondaryRed100, width: 1.rSp)
          : BorderSide.none,
    );

    InputBorder oneSideErrorBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: ColorsPallets.secondaryRed100, width: 1.rSp), // Replace with your color
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.topTitleWidget != null) widget.topTitleWidget!,
        if (widget.topTitleText != null) ...[
          Text(widget.topTitleText!, style: widget.topTitleStyle ?? TextStyles.s_14_400),
        ],
        ValueListenableBuilder(
          valueListenable: _validationFailed,
          builder: (_, isError, __) {
            return SizedBox(
              height: widget.keyboardType == TextInputType.multiline ? null : (widget.height?.rh),
              child: TextFormField(
                // autofillHints: const [AutofillHints.email, AutofillHints.password],
                focusNode: widget.focusNode,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                controller: widget.controller,
                onChanged: widget.onChanged,
                autofocus: widget.autofocus,
                onTap: widget.onTap,
                readOnly: widget.isReadOnly,

                onFieldSubmitted: widget.onSubmitted,
                obscureText: widget.isPassword ? !_isPassVisible : widget.isPassword,
                cursorColor: widget.cursorColor,

                maxLines: (widget.isPassword) ? 1 : widget.maxLines,
                //* Validation
                validator:
                    widget.validator ??
                    (value) {
                      if (widget.isDisableValidation) {
                        _validationFailed.value = false;
                        return null;
                      } else if (value == null || value.trim().isEmpty) {
                        _validationFailed.value = true;
                        return widget.validationText ?? SMText.requiredField;
                      }
                      _validationFailed.value = false;
                      return null;
                    },

                style: widget.inputStyle ?? TextStyles.s_15_400,
                textAlign: widget.textAlign ?? TextAlign.start,
                keyboardType: widget.keyboardType,
                inputFormatters:
                    widget.inputFormatters ??
                    (widget.keyboardType == TextInputType.phone
                        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
                        : widget.keyboardType == TextInputType.number
                        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                        : null),
                enabled: widget.isEnable,

                decoration: InputDecoration(
                  isDense: widget.isDense,

                  errorStyle: TextStyles.s_12_400.copyWith(
                    // height: 1.rh,
                    color: ColorsPallets.secondaryRed100,
                    fontWeight: FontWeight.w300,
                  ),
                  errorMaxLines: 3,
                  //* Filled Color
                  filled: true,
                  fillColor: widget.fillColor ?? ColorsPallets.transparent,

                  //*  Hint & Lable
                  hintText: widget.hintText,
                  hintStyle: widget.hintStyle ?? TextStyles.s_13_400.copyWith(color: ColorsPallets.disabled300),
                  labelText: widget.labelText,
                  labelStyle: widget.labelStyle ?? TextStyles.s_16_400.copyWith(color: ColorsPallets.normal25),

                  floatingLabelStyle: TextStyles.s_16_400.copyWith(
                    color: isError ? ColorsPallets.secondaryRed100 : ColorsPallets.primary0,
                  ),
                  //*  Content Padding , suffix and prefix icons
                  contentPadding:
                      widget.contentPadding ??
                      EdgeInsets.symmetric(
                        // vertical: 11.rh, horizontal: 14.rw),
                        vertical: 6.rh,
                        horizontal: 14.rw,
                      ),
                  prefixIcon: widget.prefixIcon == null
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 14.rw),
                            widget.prefixIcon!,
                            SizedBox(width: 8.rw),
                          ],
                        ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                  suffixIcon: widget.isPassword
                      ? DesignSystem.animatedCrossFadeWidget(
                          onPressed: () => setState(() => _isPassVisible = !_isPassVisible),
                          animationStatus: _isPassVisible,
                          shownIfFalse: DesignSystem.svgIcon("password-hide"),
                          shownIfTrue: DesignSystem.svgIcon("password-show"),
                        )
                      : widget.suffixIcon == null
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // horizontalSpace(12.rw),
                            widget.suffixIcon!,
                            // horizontalSpace(16.rw)
                          ],
                        ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0),

                  //* Border
                  border: InputBorder.none,
                  enabledBorder: (widget.isOneSideBorder ? oneSideBorder : ordinaryBorder),
                  disabledBorder: (widget.isOneSideBorder ? oneSideBorder : ordinaryBorder),
                  focusedBorder: widget.focusedBorderColor == null
                      ? (widget.isOneSideBorder ? oneSideBorder : ordinaryBorder)
                      : (widget.isOneSideBorder ? oneSideBorder : ordinaryBorder).copyWith(
                          borderSide: BorderSide(color: widget.focusedBorderColor!, width: 1.rSp),
                        ),
                  errorBorder: widget.isOneSideBorder ? oneSideErrorBorder : errorBorder,
                  focusedErrorBorder: widget.isOneSideBorder ? oneSideErrorBorder : errorBorder,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
