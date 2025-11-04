import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/global/components/countries_bs/countries_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';
import 'package:sm_ai_support/src/core/global/components/custom_text_field/primary_text_form_field.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';
import 'dart:ui' as ui;

class PhoneTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? topTitleText;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final String? initCountryCode;
  final Function(String)? onChanged;
  final Function(Country)? onCountryChanged;

  const PhoneTextField({
    super.key,
    this.controller,
    this.topTitleText,
    this.hintText,
    this.contentPadding,
    this.initCountryCode,
    this.onChanged,
    this.onCountryChanged,
  });

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  late Country selectedCountry;

  @override
  void initState() {
    super.initState();
    if (widget.initCountryCode != null) {
      selectedCountry = countriesList.firstWhere(
        (element) => element.dialCode == widget.initCountryCode,
        orElse: () => getSaudiArabiaCountry(),
      );
    } else {
      selectedCountry = getSaudiArabiaCountry();
    }
    widget.onCountryChanged?.call(selectedCountry);
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryTextFormField(
      controller: widget.controller,
      height: null,
      isOneSideBorder: true,
      topTitleText: widget.topTitleText ?? SMText.phoneNumber,
      hintText: widget.hintText ?? '${SMText.example}: "050 658 6162"',
      // hintText: widget.hintText ?? '${LocaleKeys.example.tr()} : "6162 658 05"',
      validator: (value) => Utils.phoneValidator(value, selectedCountry.isoCode),
      keyboardType: TextInputType.phone,
      contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(vertical: 14.rh),
      onChanged: widget.onChanged,
      suffixIcon: InkWell(
        onTap: () {
          primaryCupertinoBottomSheet(
            isShowCloseIcon: false,
            child: CountrySelectionBottomSheet(
              initialCounryIsoCode: selectedCountry.isoCode,
              seletedCountry: (country) {
                if (country != null) {
                  setState(() => selectedCountry = country);
                  widget.onCountryChanged?.call(selectedCountry);
                }
              },
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.dialCode,
              textDirection: ui.TextDirection.ltr,
              style: TextStyles.s_12_500.copyWith(color: ColorsPallets.normal500),
            ),
            SizedBox(width: 4.rw),
            Text(selectedCountry.flag, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
