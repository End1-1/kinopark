part of 'screen.dart';

extension BasketExt on Basket {
  void _paymentPage() {
    if (dotenv.env['startasguest'] =='true') {
      if (_addressTextController.text.isEmpty) {
        BlocProvider.of<AppErrorBloc>(tools.context()).add(AppErrorEvent(locale().pleaseSetAddress));
        return;
      }
    }
    Navigator.push(tools.context(), MaterialPageRoute(builder: (builder) => Payment(model)));
  }

  void _getAddressFromMap() async {
    if (kIsWeb == false) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        BlocProvider.of<AppErrorBloc>(tools.context()).add(
            AppErrorEvent('Golocator blocked foreva, unblock to continue'));
        print('Геолокация выключена.');
        //return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          BlocProvider.of<AppErrorBloc>(tools.context()).add(
              AppErrorEvent('Permission denied'));
          // return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        BlocProvider.of<AppErrorBloc>(tools.context()).add(
            AppErrorEvent('Golocator blocked foreva, unblock to continue'));
        return;
      }
    }

    Navigator.push(tools.context(), MaterialPageRoute(builder: (builder) => MapScreen(model))).then((value) {
      if (value != null) {
        _addressTextController.text = tools.getString('address')!;
      }
    });
  }

  void _addressChanged(String s) {

  }
}

extension BasketDishWidgetExt on BasketDishWidget {
  void _incQty() {
    final dish = model.basket[row];
    final dish2 = dish.copyWith(f_qty: dish.f_qty + 1);
    model.basket[row] = dish2;
    BlocProvider.of<BasketBloc>(tools.context()).add(BasketEvent());
  }

  void _decQty() {
    final dish = model.basket[row];
    final dish2 = dish.copyWith(f_qty: dish.f_qty - 1);
    model.basket[row] = dish2;
    if (dish2.f_qty < 0.01) {
      model.basket.removeAt(row);
    }
    BlocProvider.of<BasketBloc>(tools.context()).add(BasketEvent());
  }


}