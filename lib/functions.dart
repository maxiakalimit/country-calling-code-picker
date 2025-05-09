import 'dart:convert';

import 'package:country_calling_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

import './country.dart';

///This function returns list of countries
Future<List<Country>> getCountries(BuildContext context) async {
  String rawData = await DefaultAssetBundle.of(context).loadString(
      'packages/country_calling_code_picker/raw/country_codes.json');
  final parsed = json.decode(rawData.toString()).cast<Map<String, dynamic>>();
  return parsed.map<Country>((json) => new Country.fromJson(json)).toList();
}

///This function returns an user's current country. User's sim country code is matched with the ones in the list.
///If there is no sim in the device, first country in the list will be returned.
///This function returns an user's current country. User's sim country code is matched with the ones in the list.
///If there is no sim in the device, first country in the list will be returned.
Future<Country> getDefaultCountry(BuildContext context) async {
  final list = await getCountries(context);
  try {
    final countryCode = await FlutterSimCountryCode.simCountryCode;
    if (countryCode == null) {
      return list.first;
    }
    return list.firstWhere((element) =>
        element.countryCode.toLowerCase() == countryCode.toLowerCase());
  } catch (e) {
    return list.first;
  }
}

///This function returns an country whose [countryCode] matches with the passed one.
Future<Country?> getCountryByCountryCode(
    BuildContext context, String countryCode) async {
  final list = await getCountries(context);
  return list.firstWhere((element) => element.countryCode == countryCode);
}

Future<Country?> showCountryPickerSheet(
  BuildContext context, {
  double cornerRadius = 24.0,
  bool focusSearchBox = false,
  double heightFactor = 0.9,
}) {
  assert(heightFactor <= 1.0 && heightFactor >= 0.4,
      'heightFactor must be between 0.4 and 0.9');
  return showModalBottomSheet<Country?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(cornerRadius),
              topRight: Radius.circular(cornerRadius))),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * heightFactor,
          child: Column(
            children: <Widget>[
              SizedBox(height: 24.0),
              Container(
                height: 4.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Color(0xFFD6D9D6),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              SizedBox(height: 28),
              Expanded(
                child: CountryPickerWidget(
                    onSelected: (country) => Navigator.of(context).pop(country),
                    focusSearchBox: focusSearchBox),
              ),
            ],
          ),
        );
      });
}

Future<Country?> showCountryPickerDialog(
  BuildContext context, {
  Widget? title,
  double cornerRadius = 35,
  bool focusSearchBox = false,
}) {
  return showDialog<Country?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(cornerRadius),
            )),
            child: Column(
              children: <Widget>[
                SizedBox(height: 16),
                Expanded(
                  child: CountryPickerWidget(
                    onSelected: (country) => Navigator.of(context).pop(country),
                    focusSearchBox: focusSearchBox,
                  ),
                ),
              ],
            ),
          ));
}
