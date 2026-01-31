import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final mdDoubleFormatter = NumberFormat.decimalPattern('en_us');

extension Tools on SharedPreferences {
  static String locale = 'hy';
  static String app_version = '';

  String serverName() {
    return dotenv.env['host'] ?? '';
  }

  String webSocketAddress() {
    return dotenv.env['websocketaddress'] ?? '';
  }

  String database() {
    return dotenv.env['database'] ?? '' ;
  }

  BuildContext context() {
    return navigatorKey.currentContext!;
  }

  String mdFormatDouble(double? value) {
    return value == null
        ? '0'
        : mdDoubleFormatter
            .format(value)
            .replaceAll(RegExp('r(?!\d[\.\,][1-9]+)0+\$'), '')
            .replaceAll('[\.\,]\$', '');
  }
}

late SharedPreferences tools;
