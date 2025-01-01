part of 'screen.dart';

extension MapScreenExt on MapScreen {
  void _mapCreated(GoogleMapController mc) {
    mapController = mc;
  }

  void _cameraMove(CameraPosition p) {
    currentPosition.value = p.target;
    _currentMarker = _currentMarker.copyWith(
        positionParam: LatLng(p.target.latitude, p.target.longitude));
  }

  void _cameraIdle() async {
    if (currentPosition.value == null) {
      return;
    }
    await getPlaceMarks();
  }

  void _setAddress() {
    if (currentAddressController.text.isEmpty) {
      BlocProvider.of<AppErrorBloc>(tools.context())
          .add(AppErrorEvent(locale().pleaseSetAddress));
      return;
    }
    tools.setString('address', currentAddressController.text);
    tools.setDouble('lat', currentPosition.value.latitude);
    tools.setDouble('lon', currentPosition.value.longitude);
    Navigator.pop(tools.context(), true);
  }
}
