part of 'screen.dart';

extension BasketExt on Basket {
  void _paymentPage() {
    Navigator.push(tools.context(), MaterialPageRoute(builder: (builder) => Payment(model)));
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