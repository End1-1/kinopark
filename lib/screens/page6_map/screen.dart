import 'package:kinopark/widgets/textfield_address.dart';

import 'screen.mobile.dart' if (dart.library.html)  'screen.html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';

part 'screen.part.dart';

class MapScreen extends App {
  late GoogleMapController mapController;
  final ValueNotifier<LatLng> currentPosition =
      ValueNotifier<LatLng>(LatLng(40.1872, 44.503490));
  final LatLng _center = const LatLng(40.1872, 44.503490);
  final currentAddressController = TextEditingController();
  late Marker _currentMarker;

  MapScreen(super.model, {super.key}) {
    _currentMarker = Marker(
      markerId: MarkerId('currentLocation'),
      position: currentPosition.value,
      draggable: false,
    );
  }

  @override
  Widget body(BuildContext context) {
    return Stack(children: [
      ValueListenableBuilder<LatLng>(
          valueListenable: currentPosition,
          builder: (context, position, _) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 15),
              onMapCreated: _mapCreated,
              onCameraMove: _cameraMove,
              onCameraIdle: _cameraIdle,
              markers: {_currentMarker},
            );
          }),
      TextFieldAddress(currentAddressController, IconButton(onPressed: _setAddress, icon: const Icon(Icons.done_all, color: Colors.green)))
    ]);
  }
}
