import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class CountrySelectionBottomSheet extends StatefulWidget {
  /// [ISO] code of the country to be selected initially
  final String? initialCounryIsoCode;

  /// Callback function to return the selected country's [ISO] code
  final Function(Country?)? seletedCountry;

  /// List of [ISO] codes to prioritize at the top of the list
  final List<String> prioritizedIsoCodes;

  final bool shrinkwrap;
  final bool showSheetHeader;

  const CountrySelectionBottomSheet({
    super.key,
    this.shrinkwrap = false,
    this.showSheetHeader = true,
    this.initialCounryIsoCode,
    this.seletedCountry,
    // required this.countriesList,
    this.prioritizedIsoCodes = const ['SA', 'AE', 'KW', 'QA', 'BH', 'PS', 'EG', 'BD'], // Default prioritized countries
  });

  @override
  State<CountrySelectionBottomSheet> createState() => _CountrySelectionBottomSheetState();
}

class _CountrySelectionBottomSheetState extends State<CountrySelectionBottomSheet> {
  List<Country> prioritizedCountries = [];
  Map<String, List<Country>> groupedCountries = {};
  Map<String, List<Country>> filteredCountries = {};
  String? selectedCountryIsoCode;
  bool isSearching = false;
  Country? previouslySelectedCountry;
  String? previousCountryGroupKey;

  @override
  void initState() {
    super.initState();
    selectedCountryIsoCode = widget.initialCounryIsoCode;
    groupCountries([...countriesList]);
    filteredCountries = groupedCountries;
  }

  void groupCountries(List<Country> countries) {
    countries.sort((a, b) => a.name.compareTo(b.name));

    // Use the provided prioritized ISO codes or default to "SA" and "PS"
    for (var isoCode in widget.prioritizedIsoCodes) {
      Country? country = countries.firstWhereOrNull((c) => c.isoCode == isoCode);
      if (country != null) {
        prioritizedCountries.add(country);
      }
      countries.removeWhere((c) => c.isoCode == isoCode);
    }

    // Now group the remaining countries alphabetically
    for (var country in countries) {
      String firstLetter = country.name[0].toUpperCase();
      if (groupedCountries[firstLetter] == null) {
        groupedCountries[firstLetter] = [];
      }
      groupedCountries[firstLetter]!.add(country);
    }
  }

  void filterCountries(String query) {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        filteredCountries = groupedCountries;
      });
    } else {
      setState(() {
        isSearching = true;
      });

      Map<String, List<Country>> tempFilteredCountries = {};

      // Ensure prioritized countries are included in the search results if they match the query
      List<Country> prioritizedList = prioritizedCountries
          .where(
            (country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.nameEn.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      if (prioritizedList.isNotEmpty) {
        tempFilteredCountries[""] = prioritizedList; // "" will ensure they appear at the top
      }

      groupedCountries.forEach((key, countries) {
        var filteredList =
            countries.where((country) => country.name.contains(query) || country.nameEn.contains(query)).toList();
        if (filteredList.isNotEmpty) {
          tempFilteredCountries[key] = filteredList;
        }
      });

      setState(() {
        filteredCountries = tempFilteredCountries;
      });
    }
  }

  void selectCountry(Country country) {
    setState(() {
      // If a prioritized country is selected, prioritize it and remove others from the top
      if (widget.prioritizedIsoCodes.contains(country.isoCode)) {
        // Reinsert the previous country back to its original position if it exists
        if (previouslySelectedCountry != null && previousCountryGroupKey != null) {
          groupedCountries[previousCountryGroupKey!]?.add(previouslySelectedCountry!);
          groupedCountries[previousCountryGroupKey!]!.sort((a, b) => a.name.compareTo(b.name));
          previouslySelectedCountry = null;
          previousCountryGroupKey = null;
        }

        prioritizedCountries.removeWhere((c) => !widget.prioritizedIsoCodes.contains(c.isoCode));
        selectedCountryIsoCode = country.isoCode;
        previouslySelectedCountry = null;
      } else {
        // If another country is selected, move it to the top and remove it from its original position
        if (previouslySelectedCountry != null && previousCountryGroupKey != null) {
          // Reinsert the previously selected country back to its original position
          groupedCountries[previousCountryGroupKey!]?.add(previouslySelectedCountry!);
          groupedCountries[previousCountryGroupKey!]!.sort((a, b) => a.name.compareTo(b.name));
        }

        // Store the current selected country and its group key before moving it
        previouslySelectedCountry = country;
        previousCountryGroupKey = country.name[0].toUpperCase();

        // Remove the selected country from its original position
        groupedCountries[previousCountryGroupKey!]?.removeWhere((c) => c.isoCode == country.isoCode);

        // Move the selected country to the top
        prioritizedCountries.removeWhere((c) => !widget.prioritizedIsoCodes.contains(c.isoCode));
        prioritizedCountries.insert(0, country);
        selectedCountryIsoCode = country.isoCode;
      }
      if (widget.seletedCountry != null) widget.seletedCountry!(country);
      // Clear search and reset the filtered list
      filterCountries("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.showSheetHeader) SizedBox(height: 12.rh),
        if (!widget.showSheetHeader)
          Container(
            width: 24.rw,
            height: 3.rh,
            decoration: ShapeDecoration(shape: StadiumBorder(), color: ColorsPallets.neutralSolid100),
          ),
        if (widget.showSheetHeader)
          Padding(
            padding: EdgeInsetsDirectional.only(start: 20.rw, top: 30.rh, end: 20.rw),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DesignSystem.closeButton(
                  onTap: () {
                    widget.seletedCountry!(
                      countriesList.firstWhereOrNull((country) => country.isoCode == selectedCountryIsoCode),
                    );
                    context.smPopSheet();
                  },
                ),
                Text(SMText.chooseTheCountry, style: TextStyles.s_16_400.copyWith(color: ColorsPallets.loud900)),
                GestureDetector(
                  onTap: () {
                    widget.seletedCountry!(
                      countriesList.firstWhereOrNull((country) => country.isoCode == selectedCountryIsoCode),
                    );
                    context.smPopSheet();
                  },
                  child: Text(SMText.apply, style: TextStyles.s_15_400.copyWith(color: ColorsPallets.primaryColor)),
                ),
              ],
            ),
          ),
        if (widget.showSheetHeader) SizedBox(height: 14.rh),
        if (widget.showSheetHeader)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.rw),
            margin: EdgeInsets.symmetric(horizontal: 22.rw),
            decoration: BoxDecoration(color: ColorsPallets.normal25, borderRadius: 100.rSp.br),
            child: TextField(
              decoration: InputDecoration(
                fillColor: ColorsPallets.normal25,
                prefixIconConstraints: BoxConstraints(maxWidth: 28.rSp, maxHeight: 20.rSp),
                prefixIcon: Padding(
                  padding: EdgeInsetsDirectional.only(end: 8.rw),
                  child: DesignSystem.svgIcon('search', color: ColorsPallets.normal500),
                ),
                hintText: SMText.searchForTheCountry,
                hintStyle: TextStyles.s_13_400.copyWith(color: ColorsPallets.disabled300),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                filterCountries(value);
              },
            ),
          ),
        if (widget.showSheetHeader) const SizedBox(height: 16),
        // !Countries List ----------------------------------------------
        Expanded(
          child: ListView.builder(
            shrinkWrap: widget.shrinkwrap,
            itemCount: isSearching
                ? filteredCountries.keys.length
                : prioritizedCountries.length + filteredCountries.keys.length,
            itemBuilder: (context, index) {
              // Handle prioritized countries at the top when not searching
              if (!isSearching && index < prioritizedCountries.length) {
                Country country = prioritizedCountries[index];
                return widget.shrinkwrap ? buildCountryTileWithDialCode(country) : buildCountryTile(country);
              }

              // Handle remaining countries alphabetically
              int adjustedIndex = isSearching ? index : index - prioritizedCountries.length;
              String key = filteredCountries.keys.elementAt(adjustedIndex);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (key.isNotEmpty) // Prevent empty header for prioritized countries in search
                    Container(
                      width: double.infinity,
                      color: ColorsPallets.normal25,
                      padding: EdgeInsets.symmetric(vertical: 8.rh, horizontal: 22.rw),
                      child: Text(key, style: TextStyles.s_14_400.copyWith(color: ColorsPallets.darkGreen)),
                    ),
                  ...filteredCountries[key]!.map((country) {
                    return widget.shrinkwrap ? buildCountryTileWithDialCode(country) : buildCountryTile(country);
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildCountryTileWithDialCode(Country country) {
    return InkWell(
      onTap: () {
        selectCountry(country);
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.rSp),
              color: selectedCountryIsoCode == country.isoCode ? ColorsPallets.disabled25 : null,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
            margin: EdgeInsets.symmetric(horizontal: 22.rw, vertical: 3.rh),
            child: Row(
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 26)),
                SizedBox(width: 14.rw),
                Text(country.name, style: TextStyles.s_14_400.copyWith(color: ColorsPallets.muted600)),
                const Spacer(),
                Text(
                  country.dialCode,
                  style: TextStyles.s_14_500.copyWith(color: ColorsPallets.subdued400, fontFamily: 'DMSans'),
                ),
              ],
            ),
          ),
          // if not last in prioritized or filtered list, show divider
          if (country != prioritizedCountries.last && country != filteredCountries[filteredCountries.keys.last]!.last)
            Container(
              margin: EdgeInsetsDirectional.only(start: 60.rw),
              height: 1.rSp,
              width: 100.w,
              color: ColorsPallets.disabled25,
            ),
        ],
      ),
    );
  }

  Widget buildCountryTile(Country country) {
    return InkWell(
      onTap: () {
        selectCountry(country);
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.rw, vertical: 16.rh),
            child: Row(
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 26)),
                SizedBox(width: 14.rw),
                Text(country.name, style: TextStyles.s_14_400.copyWith(color: ColorsPallets.muted600)),
                const Spacer(),
                DesignSystem.animatedCrossFadeWidget(
                  animationStatus: selectedCountryIsoCode == country.isoCode,
                  shownIfFalse: DesignSystem.svgIcon('check', color: ColorsPallets.transparent),
                  shownIfTrue: DesignSystem.svgIcon('check', color: ColorsPallets.primaryColor),
                ),
              ],
            ),
          ),
          // if not last in prioritized or filtered list, show divider
          if (country != prioritizedCountries.last && country != filteredCountries[filteredCountries.keys.last]!.last)
            Container(
              margin: EdgeInsetsDirectional.only(start: 60.rw),
              height: 1.rSp,
              width: 100.w,
              color: ColorsPallets.disabled25,
            ),
        ],
      ),
    );
  }
}
