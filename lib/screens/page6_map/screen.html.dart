import 'dart:convert';
import 'dart:html' as html;

import 'package:kinopark/screens/page6_map/screen.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';

extension MapScreenHtmlExt on MapScreen {
  Future<void> getPlaceMarks() async {

    String url =
        '${tools.serverName()}/engine/google.php?latlng=${currentPosition.value.latitude},${currentPosition.value.longitude}&geocode=1}';

    try {
      final response = await html.HttpRequest.request(url, method: 'GET');
      final data = json.decode(response.responseText ?? '');
      if (data['results'] != null && data['results'].isNotEmpty) {
        final place = data['results'][0];
        print(place['formatted_address']);
        currentAddressController.text = '${place['formatted_address']}';
      } else {
        currentAddressController.text = locale().cannotGetAddress;
      }
    } catch (e) {
      currentAddressController.text = locale().cannotGetAddress;
    }
  }
}
