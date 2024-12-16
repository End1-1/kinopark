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
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(color: Colors.black12),
        child: BlocBuilder<BasketBloc, BasketState>(builder: (builder, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                    if (model.basket.isEmpty)
                      _emptyBasket()
                    else
                      for (int i = 0; i < model.basket.length; i++) ...[
                        BasketDishWidget(
                            imageWidget: image,
                            model: model,
                            row: i,
                            gSymbol: locale().g)
                      ]
                  ]))),
              if (model.basket.isNotEmpty)...[
                Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${locale().counted}  ${tools.mdFormatDouble(model.basketTotal())} ֏', style: totalTextStyle),
                          columnSpace(),
                          if ((tools.getDouble('servicefee') ?? 0) > 0)
                            Text(
                                '+${locale().serviceFee} ${tools.mdFormatDouble((tools.getDouble('servicefee') ?? 0) * 100)}% ${tools.mdFormatDouble(model.basketTotal() * (tools.getDouble('servicefee') ?? 0))} ֏',
                            style: totalTextStyle),
                          columnSpace(),
                          Expanded(
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      backgroundColor: kMainColor),
                                  onPressed: _paymentPage,
                                  child: Text(
                                      '${locale().goToPayment} ${tools.mdFormatDouble(model.basketTotal() + model.basketTotal() * (tools.getDouble('servicefee') ?? 0))} ֏',
                                      style:totalTextStyle)))
                        ]))],
              rowSpace()
            ],
          );
        }));
  }

  List<Widget> appBarActions(BuildContext context) {
    return [
      IconButton(
          onPressed: model.clearBasket, icon: Icon(Icons.delete_forever)),
      PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (builder) {
            return [
              PopupMenuItem(
                child: ListTile(
                  leading: Image.asset(
                    'assets/flags/${Tools.locale}.png',
                    height: 30,
                  ),
                  title: Text(localeName()),
                  onTap: () {
                    Navigator.pop(context); // Закрыть меню
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                      items: popupMenuLanguageItems(),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                onTap: navigateToSendMessage,
                child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text(locale().support)),
              )
            ];
          }),
    ];
  }

  Widget _emptyBasket() {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      rowSpace(),
      Text(locale().yourBasketEmpty),
      rowSpace(),
      Image.asset(
        'assets/smile.png',
        height: MediaQuery.sizeOf(tools.context()).width / 3,
        color: Colors.blueAccent,
      )
    ]);
  }
}

class BasketDishWidget extends StatelessWidget {
  final AppModel model;
  final int row;
  String gSymbol;
  Function(String, double) imageWidget;

  BasketDishWidget(
      {super.key,
      required this.imageWidget,
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
                  child: imageWidget(dish.f_image, 100),
                ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(dish.name(Tools.locale), style: basketNameStyle),
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
