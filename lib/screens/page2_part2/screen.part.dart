part of 'screen.dart';

extension Part2Ext on Part2 {
  void _filterDishes(int part2) {
    model.filteredPart2 = model.part2.list.firstWhereOrNull((e) => e.f_id == part2);
    BlocProvider.of<Page1Bloc>(tools.context()).add(Page1Event());
  }

  void _addToBasket(Dish d) {
    model.basket.add(d.copyWith());
    BlocProvider.of<BasketBloc>(tools.context()).add(BasketEvent());
  }

  void _goToBasket() {
    Navigator.push(tools.context(), MaterialPageRoute(builder: (builder) => Basket(model)));
  }
}