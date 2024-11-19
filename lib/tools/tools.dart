import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final mdDoubleFormatter = NumberFormat.decimalPattern('en_us');

extension Tools on SharedPreferences {

  String serverName() {
    return 'kinopark.picasso.am';
  }
  BuildContext context()  {
    return navigatorKey.currentContext!;
  }

  String mdFormatDouble(double? value) {
    return value == null ? '0' : mdDoubleFormatter.format(value).replaceAll(RegExp('r(?!\d[\.\,][1-9]+)0+\$'), '').replaceAll('[\.\,]\$', '');
  }
}

late SharedPreferences tools;