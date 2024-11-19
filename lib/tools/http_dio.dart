import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kinopark/tools/tools.dart';

class HttpDio {
  static final dio = Dio();

  Future<dynamic> post(String route,
      {Map<String, dynamic> inData = const {}}) async {
    inData.addAll({'sessionkey': tools.getString('sessionkey')});
    try {
      if (kDebugMode) {
        print('request: https://${tools.serverName()}/engine/$route');
        print(inData);
      }
      final response = await dio.post(
          'https://${tools.serverName()}/engine/$route',
          data: inData,
          options: Options(
              responseType: ResponseType.plain,
              contentType: 'application/json'));
      try {
        final strData = response.data.toString();
        if (kDebugMode) {
          print('reply size ${strData.length}');
          print(strData);
        }
        final outData = jsonDecode(strData);
        return outData;
      } catch (e) {
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
