//library international_phone_input;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:international_phone_input/src/phone_service.dart';

import 'country.dart';

class InternationalPhoneInputController extends StatefulWidget {
  final  String initialSelection;
  final String errorText;
  final String hintText;
  final String labelText;
  final TextStyle errorStyle;
  final TextStyle hintStyle;
  final TextStyle labelStyle;
  final int errorMaxLines;
  final bool showCountryCodes;
  final bool showCountryFlags;
  final Widget dropdownIcon;
  final List<String> removeDuplicates;
  final List<String> enabledCountries;
  final InputDecoration decoration;
  final InputBorder border;
  final bool withError;
  final void Function(String phoneNumber, String internationalizedPhoneNumber,
      String isoCode, String dialCode,bool isValid) onPhoneNumberChange;
  final Key key;
  final TextEditingController controller;
  InternationalPhoneInputController(
      {
        this.initialSelection,
        this.onPhoneNumberChange,
        this.enabledCountries,
        this.removeDuplicates,
        this.key,
        this.dropdownIcon,
        this.decoration,
        this.showCountryCodes,
        this.showCountryFlags,
        this.controller,
        this.errorText,
        this.hintText,
        this.labelText,
        this.errorStyle,
        this.hintStyle,
        this.labelStyle,
        this.errorMaxLines,
        this.border,
        this.withError
      })
      : super(key: key);
  static Future<String> internationalizeNumber(String number, String iso) {
    return PhoneService.getNormalizedPhoneNumber(number, iso);
  }

  @override
  _InternationalPhoneInputState createState() =>
      _InternationalPhoneInputState();
}

class _InternationalPhoneInputState extends State<InternationalPhoneInputController> {
  Country selectedItem;
  List<Country> itemList = [];
  Widget dropdownIcon;
  InputDecoration decoration;
  bool showCountryCodes;
  bool showCountryFlags;
  bool withError;
  String errorText;
  String hintText;
  String labelText;
  TextStyle errorStyle;
  TextStyle hintStyle;
  TextStyle labelStyle;
  bool hasError = false;
  InputBorder border;
  int errorMaxLines;

  _InternationalPhoneInputState();

  final phoneTextController = TextEditingController();
  @override
  void initState() {
    errorText = widget.errorText ?? 'Please enter a valid phone number';
    hintText = widget.hintText ?? 'eg. 244056345';
    labelText = widget.labelText;
    errorStyle = widget.errorStyle;
    hintStyle = widget.hintStyle;
    labelStyle = widget.labelStyle;
    errorMaxLines = widget.errorMaxLines;
    decoration = widget.decoration;
    showCountryCodes = widget.showCountryCodes;
    showCountryFlags = widget.showCountryFlags;
    dropdownIcon = widget.dropdownIcon;
    withError = widget.withError;
    widget.controller.addListener(() {
      final String text = widget.controller.text.toLowerCase();
      widget.controller.value = widget.controller.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
      _validatePhoneNumber(text);
    });
    _fetchCountryData().then((list) {
      Country preSelectedItem;


      if (widget.initialSelection != null) {
        preSelectedItem = list.firstWhere(
                (e) =>
            (e.code.toUpperCase() ==
                widget.initialSelection.toUpperCase()) ||
                (e.dialCode == widget.initialSelection.toString()),
            orElse: () => list[0]);
      } else {
        preSelectedItem = list[0];
      }

      setState(() {
        itemList = list;
        selectedItem = preSelectedItem;

        _validatePhoneNumber(widget.controller.text);
      });
    });


    super.initState();
  }


  _validatePhoneNumber(String number) {

    if (number != null) {
      PhoneService.parsePhoneNumber(number, selectedItem.code)
          .then((isValid) {

        if(withError){
          setState(() {
            hasError = !isValid;
          });
        }

        if (widget.onPhoneNumberChange != null) {
          if (isValid) {

            PhoneService.getNormalizedPhoneNumber(widget.controller.text, selectedItem.code)
                .then((number) {
              widget.onPhoneNumberChange(widget.controller.text, number, selectedItem.code, selectedItem.dialCode,true);
            });
          } else {

            widget.onPhoneNumberChange('', '', selectedItem.code, selectedItem.dialCode,false);
          }
        }
      });
    }
  }
  Future<List<Country>> _fetchCountryData() async {

    var list = await DefaultAssetBundle.of(context)
        .loadString('packages/international_phone_input/assets/countries.json');
    List<dynamic> jsonList = json.decode(list);

    List<Country> countries = List<Country>.generate(jsonList.length, (index) {
      Map<String, String> elem = Map<String, String>.from(jsonList[index]);
      if (widget.enabledCountries.isEmpty && widget.removeDuplicates.isEmpty) {
        return Country(
            name: elem['en_short_name'],
            code: elem['alpha_2_code'],
            dialCode: elem['dial_code'],
            flagUri: 'assets/flags/${elem['alpha_2_code'].toLowerCase()}.png');
      } else if ((widget.enabledCountries.contains(elem['alpha_2_code']) ||
          widget.enabledCountries.contains(elem['dial_code'])) &&
          !widget.removeDuplicates.contains(elem['alpha_2_code'])) {
        return Country(
            name: elem['en_short_name'],
            code: elem['alpha_2_code'],
            dialCode: elem['dial_code'],
            flagUri: 'assets/flags/${elem['alpha_2_code'].toLowerCase()}.png');
      } else {
        return null;
      }
    });


    countries.removeWhere((value) => value == null);

    return countries;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DropdownButtonHideUnderline(
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: DropdownButton<Country>(
                value: selectedItem,
                icon: Padding(
                  padding:
                  EdgeInsets.only(bottom: (decoration != null) ? 6 : 0),
                  child: dropdownIcon ?? Icon(Icons.arrow_drop_down),
                ),
                onChanged: (Country newValue) {
                  setState(() {
                    selectedItem = newValue;
                    _validatePhoneNumber(widget.controller.text);

                  });
                  // _validatePhoneNumber(widget.controller.text);
                },
                items: itemList.map<DropdownMenuItem<Country>>((Country value) {
                  return DropdownMenuItem<Country>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          if (showCountryFlags) ...[
                            Image.asset(
                              value.flagUri,
                              width: 32.0,
                              package: 'international_phone_input',
                            )
                          ],
                          if (showCountryCodes) ...[
                            SizedBox(width: 4),
                            Text(value.dialCode)
                          ]
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Flexible(
              child: TextField(
                keyboardType: TextInputType.phone,
                controller:  widget.controller,
                decoration: decoration ??
                    InputDecoration(
                      hintText: hintText,
                      labelText: labelText,
                      errorText: hasError ? errorText : null,
                      hintStyle: hintStyle ?? null,
                      errorStyle: errorStyle ?? null,
                      labelStyle: labelStyle,
                      errorMaxLines: errorMaxLines ?? 3,
                      border: border ?? null,
                    ),
              )
          )
        ],
      ),
    );
  }
}
