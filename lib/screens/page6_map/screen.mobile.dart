import 'package:geocoding/geocoding.dart';
import 'package:kinopark/screens/page6_map/screen.dart';
import 'package:kinopark/tools/localilzator.dart';

extension MapScreenHtmlExt on MapScreen {
  Future<void> getPlaceMarks() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.value.latitude,
        currentPosition.value.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        currentAddressController.text =
        '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      currentAddressController.text = locale().cannotGetAddress;
    }
  }
}