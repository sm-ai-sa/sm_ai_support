import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sm_ai_support/src/core/global/components/custom_text_field/primary_text_form_field.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? topTitleText;
  final Widget? topTitleWidget;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final TextInputType? keyboardType;
  final FormFieldValidator? validator;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool? isReadOnly;
  final bool isDisableValidation;
  final Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;

  final bool? isPassword;

  const CustomTextField({
    super.key,
    this.controller,
    this.topTitleText,
    this.topTitleWidget,
    this.hintText,
    this.contentPadding,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.isReadOnly,
    this.onTap,
    this.inputFormatters,
    this.isDisableValidation = false,
    this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryTextFormField(
      controller: controller,
      height: null,
      isOneSideBorder: true,
      topTitleText: topTitleText,
      topTitleWidget: topTitleWidget,
      isDisableValidation: isDisableValidation,
      hintText: hintText,
      keyboardType: keyboardType,
      maxLines: keyboardType == TextInputType.multiline ? 3 : 1,
      contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 14.rh),
      validator: validator,
      onChanged: onChanged,
      suffixIcon: suffixIcon,
      isReadOnly: isReadOnly ?? false,
      onTap: onTap,
      isPassword: isPassword ?? false,
      inputFormatters: inputFormatters,
    );
  }
}
