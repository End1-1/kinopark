import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:kinopark/screens/page1_home/screen.dart';
import 'package:kinopark/structs/dish.dart';
import 'package:kinopark/structs/dish_search_result.dart';
import 'package:kinopark/structs/dishpart1.dart';
import 'package:kinopark/structs/dishpart2.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/app_websocket.dart';
import 'package:kinopark/tools/tools.dart';

class AppModel {
  var _isInit = false;
  final part1 = DishPart1List();
  final part2 = DishPart2List();
  final dishes = DishList();
  final dishSpecial = [];
  final dishSpecialMap = {};
  final dishRecentMap = [];
  final basket = <Dish>[];

  //1 - cash, 2 - card, 3 - idram
  var paymentMethod = 0;
  var additionalInfo = '';
  DishPart2? filteredPart2;
  final searchResult = <DishSearchStruct>[];
  late final AppWebSocket webSocket;

  AppModel() {
    if (kDebugMode) {
      print('NEW APPMODEL');
    }
  }

  void init() {
    if (_isInit) {
      return;
    }
    _isInit = true;
    webSocket = AppWebSocket();
  }

  List<Dish> filteredDishes() {
    if (filteredPart2 == null) {
      return [];
    }
    return dishes.list.where((e) => e.f_part == filteredPart2!.f_id).toList();
  }

  List<Dish> recentDishes(int part1) {
    if (part1 == 0) {
      return [];
    }
    final list = [];
    for (final m in dishRecentMap) {
      final mm = jsonDecode(m["d"]);
      if (mm["f_part1"] == part1) {
        list.addAll(mm["recent"]);
      }
    }
    if (list == null) {
      return [];
    }
    return dishes.list.where((e) => list.contains(e.f_id)).toList();
  }

  double basketTotal() {
    var total = 0.0;
    for (final d in basket) {
      total += d.f_qty * d.f_price;
    }
    return total;
  }

  double totalWithService() {
    var serviceFee = (tools.getDouble('servicefee') ?? 0) * basketTotal();
    return basketTotal() + serviceFee;
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

  void closeErrorDialog() {
    BlocProvider.of<AppErrorBloc>(tools.context()).add(AppErrorEvent(''));
  }

  void closeQuestionDialog() {
    BlocProvider.of<AppQuestionBloc>(tools.context())
        .add(AppQuestionEvent('', () {}, () {}));
  }

  void clearBasket() {
    BlocProvider.of<AppQuestionBloc>(tools.context())
        .add(AppQuestionEvent(locale().clearBasket, () {
      basket.clear();
      BlocProvider.of<BasketBloc>(tools.context()).add(BasketEvent());
    }, null));
  }

  AppLocalizations locale() {
    return AppLocalizations.of(tools.context())!;
  }

  Future<void> createOrder() async {
    final body = <String, dynamic>{};
    final header = <String, dynamic>{};
    final serviceFeeValue = tools.getDouble('servicefee') ?? 0;
    final serviceFeeAmount = basketTotal() * serviceFeeValue;
    final totalAmount = basketTotal() + serviceFeeAmount;
    header['state'] = 2;
    header['hall'] = tools.getInt('hall');
    header['table'] = tools.getInt('table');
    header['comment'] = additionalInfo;
    header['amounttotal'] = totalAmount;
    header['amountcash'] = paymentMethod == 1 ? totalAmount : 0;
    header['amountcard'] = paymentMethod == 2 ? totalAmount : 0;
    header['amountidram'] = paymentMethod == 3 ? totalAmount : 0;
    header['amountother'] = 0;
    header["servicefactor"] = serviceFeeValue;
    header["amountservice"] = serviceFeeAmount;
    header['amountdiscount'] = 0;
    header['discountfactor'] = 0;
    header['partner'] = 0;
    header['taxpayertin'] = '';
    body['action'] = 'create';
    body['header'] = header;
    body['flags'] = {'f1': 0, 'f2': 0, 'f3': 0, 'f4': 0, 'f5': 0};
    body['dishes'] = [];
    int row = 0;
    for (final e in basket) {
      body['dishes'].add({
        //'obodyid': Uuid().v1().toString(),
        'state': 1,
        'dishid': e.f_id,
        'qty': e.f_qty,
        'qty2': 0,
        'price': e.f_price,
        'total': e.f_price * e.f_qty,
        'grandtotal': e.f_price * e.f_qty,
        'service': 0,
        'discount': 0,
        'store': e.f_store,
        'print1': (tools.getBool('debugmode') ?? false) ? 'tester' : e.f_print1,
        'print2': (tools.getBool('debugmode') ?? false) ? '' : e.f_print2,
        'comment': e.f_comment,
        'remind': 1,
        'adgcode': '???',
        'removereason': 0,
        'timeorder': 0,
        'package': 0,
        'row': row++,
        'emarks': null,
      });
    }

    BlocProvider.of<HttpBloc>(tools.context()).add(
        HttpEvent('kinopark/create-order.php', body, callback: _orderCreated));
  }

  void _orderCreated() {
    basket.clear();
    paymentMethod = 0;
    BlocProvider.of<AppErrorBloc>(tools.context())
        .add(AppErrorEvent(locale().yourOrderCreated));
    Navigator.pushAndRemoveUntil(tools.context(),
        MaterialPageRoute(builder: (_) => HomePage(this)), (_) => false);
  }
}
