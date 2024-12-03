import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinopark/screens/page0_base/model.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/screens/page4_payment/screen.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/tools.dart';

part 'screen.part.dart';

class Basket extends App {
  Basket(super.model, {super.key});

  @override
  Widget body(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.black12),
        child: BlocBuilder<BasketBloc, BasketState>(builder: (builder, state) {
          return Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                for (int i = 0; i < model.basket.length; i++) ...[
                  BasketDishWidget(model: model, row: i, gSymbol: locale().g)
                ]
              ]))),
              Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                    backgroundColor: kMainColor),
                                onPressed: _paymentPage,
                                child: Text(
                                    '${locale().next} ${tools.mdFormatDouble(model.basketTotal())} ֏',
                                    style:
                                        const TextStyle(color: Colors.white))))
                      ]))
            ],
          );
        }));
  }
}

class BasketDishWidget extends StatelessWidget {
  final AppModel model;
  final int row;
  String gSymbol;

  BasketDishWidget(
      {super.key,
      required this.model,
      required this.row,
      required this.gSymbol});

  @override
  Widget build(BuildContext context) {
    final dish = model.basket[row];
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      child: Column(children: [
        Row(children: [
          dish.f_image.isEmpty
              ? Image.asset('assets/fastfood.png', height: 90)
              : ClipRRect(

                      borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Image.memory(base64Decode(dish.f_image), height: 90),
                  ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(dish.f_name, style: basketNameStyle),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('${tools.mdFormatDouble(dish.f_price)} ֏',
                      style: basketPriceStyle),
                  const SizedBox(width: 5),
                  const Icon(Icons.circle, size: 5),
                  const SizedBox(width: 5),
                  Text('${tools.mdFormatDouble(dish.f_netweight)} $gSymbol',
                      style: basketWeightStyle)
                ])
              ])),
          const SizedBox(width: 10),
          Container(
              decoration: const BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(children: [
                IconButton(onPressed: _decQty, icon: const Icon(Icons.remove)),
                BlocBuilder<BasketBloc, BasketState>(builder: (builder, state) {
                  return Text(tools.mdFormatDouble(dish.f_qty),
                      style: basketQtyStyle);
                }),
                IconButton(onPressed: _incQty, icon: const Icon(Icons.add))
              ]))
        ])
      ]),
    );
  }
}
