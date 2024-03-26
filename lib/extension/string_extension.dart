import 'dart:convert';

import 'package:flutter/foundation.dart';

extension StringExtension on String? {


  bool get isNullOrEmpty {
    return this?.isEmpty ?? true;
  }

  String? addCommas() {
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return "${this?.split('.')[0].replaceAllMapped(regExp, (Match match) => '${match[1]},')}${(this?.contains('.') ?? false) ? '.' : ''}${this?.split('.').length == 2 ? this?.split('.')[1] : ''}";
  }

  String? removeCommasFromNumbers() {
    return this?.replaceAllMapped(RegExp(r'\b(\d{1,3})(,\d{3})+\b'), (match) {
      return match.group(0)!.replaceAll(',', '');
    });
  }

  double? toDouble({double? orElse}) {
    return double.tryParse(this ?? "") ??
        orElse; // Returns 0.0 if parsing fails
  }

  Map<String, dynamic> toJson() {
    try {
      return json.decode(this ?? "");
    } catch (e) {
      if (kDebugMode) {
        print('Error converting string to JSON: $e');
      }
      return {};
    }
  }

  String? get numberText => this?.replaceAll(RegExp(r'[^0-9.]'), '');

  String? removeLastCharacter({int number = 1}) {
    return this?.substring(0, this!.length - number);
  }

}
