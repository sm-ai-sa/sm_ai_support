import 'package:collection/collection.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

List<Country> countriesList = [];
List<City> citiesSA = [];

void getCountries() async {
  countriesList = await UniCountryServices.instance.getCountriesAndCities();
  citiesSA = countriesList.firstWhereOrNull((element) => element.isoCode == 'SA')?.cities ?? [];

  final riyadh = citiesSA.firstWhereOrNull((city) => city.name == "الرياض");
  final mecca = citiesSA.firstWhereOrNull((city) => city.name == "مكة المكرمة");
  final medinah = citiesSA.firstWhereOrNull((city) => city.name == "المدينة المنورة");
  final sharkiah = citiesSA.firstWhereOrNull((city) => city.name == "المنطقة الشرقية");
  final kasim = citiesSA.firstWhereOrNull((city) => city.name == "القصيم");
  final aseer = citiesSA.firstWhereOrNull((city) => city.name == "عسير");
  final tabok = citiesSA.firstWhereOrNull((city) => city.name == "تبوك");
  final ha2el = citiesSA.firstWhereOrNull((city) => city.name == "حائل");
  final baha = citiesSA.firstWhereOrNull((city) => city.name == "الباحة");
  final northernBorders = citiesSA.firstWhereOrNull((city) => city.name == "الحدود الشمالية");
  final gof = citiesSA.firstWhereOrNull((city) => city.name == "الجوف");
  final jezan = citiesSA.firstWhereOrNull((city) => city.name == "جيزان");
  final najran = citiesSA.firstWhereOrNull((city) => city.name == "نجران");

  citiesSA = [
    if (riyadh != null) riyadh,
    if (mecca != null) mecca,
    if (medinah != null) medinah,
    if (sharkiah != null) sharkiah,
    if (kasim != null) kasim,
    if (aseer != null) aseer,
    if (tabok != null) tabok,
    if (ha2el != null) ha2el,
    if (baha != null) baha,
    if (northernBorders != null) northernBorders,
    if (gof != null) gof,
    if (jezan != null) jezan,
    if (najran != null) najran,
  ];
}
