import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:kinopark/structs/dish.dart';
import 'package:kinopark/structs/dishpart1.dart';
import 'package:kinopark/structs/dishpart2.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/tools.dart';

class AppModel {
  final part1 = DishPart1List();
  final part2 = DishPart2List();
  final dishes = DishList();
  final basket = <Dish>[];
  DishPart2? filteredPart2;

  List<Dish> filteredDishes() {
    if(filteredPart2 == null) {
      return [];
    }
    return dishes.list.where((e) => e.f_part == filteredPart2!.f_id).toList();
  }

  double basketTotal() {
    var total = 0.0;
    for (final d in basket) {
      total += d.f_qty * d.f_price;
    }
    return total;
  }

  Future<void> addDishToBasket(Dish d) async {
    basket.add(d.copyWith());
    await saveBasketToStorage();
    BlocProvider.of<BasketBloc>(tools.context()).add(BasketEvent());

  }

  Future<void> saveBasketToStorage() async {
    final basketBox = await Hive.openBox<List>('basket');
    await basketBox.put('basket', basket);
    await basketBox.close();
  }
}