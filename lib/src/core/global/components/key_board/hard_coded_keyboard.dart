import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/components/countries_bs/countries_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';
import 'package:sm_ai_support/src/core/global/components/key_board/key_board_button.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class HardCodedKeyboard extends StatefulWidget {
  final ValueNotifier<String> textNotifier;
  final bool isWithSpaces;
  final int maxNumbers;
  final bool isWithCountryButton;
  final bool enabled;
  final String? initCountryCode;
  final Function(Country)? onCountryChanged;

  const HardCodedKeyboard({
    super.key,
    required this.textNotifier,
    this.isWithSpaces = true,
    this.maxNumbers = 12,
    this.isWithCountryButton = true,
    this.enabled = true,
    this.initCountryCode,
    this.onCountryChanged,
  });

  @override
  State<HardCodedKeyboard> createState() => _HardCodedKeyboardState();
}

class _HardCodedKeyboardState extends State<HardCodedKeyboard> {
  Country? selectedCountry;

  void typeNumber(String number) {
    // after third number and sixth add a space
    if (widget.isWithSpaces) {
      if (widget.textNotifier.value.length == 3 || widget.textNotifier.value.length == 7) {
        widget.textNotifier.value = '${widget.textNotifier.value} $number';
        return;
      }
    }

    // if letters are 11 don't add more
    if (widget.textNotifier.value.length == widget.maxNumbers) {
      return;
    }

    widget.textNotifier.value = '${widget.textNotifier.value}$number';
  }

  @override
  void initState() {
    super.initState();
    
    // Ensure countries are initialized
    initializeDefaultCountry();
    
    if (widget.initCountryCode != null) {
      selectedCountry = countriesList.firstWhereOrNull((element) => element.dialCode == widget.initCountryCode);
    } 
    
    // Fallback to Saudi Arabia if no country found or no init code provided
    selectedCountry ??= getSaudiArabiaCountry();
    
    if (widget.onCountryChanged != null && selectedCountry != null) widget.onCountryChanged!(selectedCountry!);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.rw),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KeyBoardButton(text: '1', onTap: !widget.enabled ? null : () => typeNumber('1')),
                KeyBoardButton(text: '2', onTap: !widget.enabled ? null : () => typeNumber('2')),
                KeyBoardButton(text: '3', onTap: !widget.enabled ? null : () => typeNumber('3')),
              ],
            ),
            SizedBox(height: 12.rh),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KeyBoardButton(text: '4', onTap: !widget.enabled ? null : () => typeNumber('4')),
                KeyBoardButton(text: '5', onTap: !widget.enabled ? null : () => typeNumber('5')),
                KeyBoardButton(text: '6', onTap: !widget.enabled ? null : () => typeNumber('6')),
              ],
            ),
            SizedBox(height: 12.rh),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KeyBoardButton(text: '7', onTap: !widget.enabled ? null : () => typeNumber('7')),
                KeyBoardButton(text: '8', onTap: !widget.enabled ? null : () => typeNumber('8')),
                KeyBoardButton(text: '9', onTap: !widget.enabled ? null : () => typeNumber('9')),
              ],
            ),
            SizedBox(height: 12.rh),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatefulBuilder(
                  builder: (context, setState) => SizedBox(
                    height: 55.rh,
                    width: 90.rw,
                    child: Visibility(
                      visible: widget.isWithCountryButton,
                      child: InkWell(
                        onTap: () {
                          primaryBottomSheet(
                            // isShowCloseIcon: false,
                            isAbleToScroll: false,
                            showLeadingContainer: false,
                            bottomSheetHeight: 90.h,
                            child: CountrySelectionBottomSheet(
                              showSheetHeader: true,
                              shrinkwrap: true,
                              initialCounryIsoCode: selectedCountry?.isoCode,
                              seletedCountry: (country) {
                                smPrint(country);
                                setState(() => selectedCountry = country);
                                if (widget.onCountryChanged != null && selectedCountry != null) {
                                  widget.onCountryChanged!(selectedCountry!);
                                }
                              },
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            height: 29.rh,
                            width: 41.rw,
                            decoration: BoxDecoration(borderRadius: 7.rSp.br, color: ColorsPallets.normal25),
                            child: Center(
                              child: Text(selectedCountry?.flag ?? '', style: TextStyle(fontSize: 18.rSp)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                KeyBoardButton(text: '0', onTap: !widget.enabled ? null : () => typeNumber('0')),
                KeyBoardButton(
                  svgIcon: 'delete-letter',
                  onTap: !widget.enabled
                      ? null
                      : () {
                          // when delete button is pressed and the next letter to be deleted is a space
                          // delete the space and the number before it
                          if (widget.textNotifier.value.isNotEmpty &&
                              widget.textNotifier.value[widget.textNotifier.value.length - 1] == ' ') {
                            widget.textNotifier.value = widget.textNotifier.value.substring(
                              0,
                              widget.textNotifier.value.length - 2,
                            );
                            return;
                          }
                          if (widget.textNotifier.value.isNotEmpty) {
                            widget.textNotifier.value = widget.textNotifier.value.substring(
                              0,
                              widget.textNotifier.value.length - 1,
                            );
                          }
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
