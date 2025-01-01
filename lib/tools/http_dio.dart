import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';

class HttpDio {
  static final dio = Dio();

  Future<dynamic> post(String route,
      {Map<String, dynamic> inData = const {}}) async {
    if ((tools.getString('sessionkey') ?? '').isNotEmpty ) {
      inData.addAll({'sessionkey': tools.getString('sessionkey')});
    }
    inData['sessionid'] = 1;
    try {
      var host = '${tools.serverName()}/engine/$route';
      if (kDebugMode) {
        print('request: $host');
        print(inData);
      }
      try {
        final response = await dio.post(host,
            data: inData,
            options: Options(
                responseType: ResponseType.plain,
                contentType: 'application/json'));
        final strData = response.data.toString();
        if (kDebugMode) {
          print('reply size ${strData.length}');
          print(strData);
        }
        try {
          final outData = jsonDecode(strData);
          return outData;
        } catch (se) {

          return Future.error(strData);
        }
      } catch (e) {
        if (e is DioException) {
          var err = e.response?.data ?? e.message.toString();
          if (err.toLowerCase() == 'access denied') {
            err = locale().accessDenied;
          }
          return Future.error(err);
        }
        return Future.error(e.toString());
      }
    } on DioException catch (d, e) {
      if ((d.error is SocketException) &&
          (d.error as SocketException).osError?.errorCode == 7) {
        return Future.error(
            AppLocalizations.of(tools.context())?.checkInternet ??
                'Check internet connection and try again');
      }
      var msg = d.response?.data.toString() ?? e.toString();
      if (msg.toLowerCase().contains('unauthorized')) {
        msg = AppLocalizations.of(tools.context())?.incorrectPin ??
            'Incorrect pin';
      }
      return Future.error(msg);
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
