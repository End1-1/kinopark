import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kinopark/structs/dish.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:shimmer/shimmer.dart';

class DishDetails extends StatelessWidget {
  final Dish dish;
  Function(Dish) addToBasket;

  DishDetails(this.dish, this.addToBasket, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(
              onPressed: () {
                Navigator.pop(tools.context());
              },
              icon: const Icon(Icons.close))
        ]),
      ]),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          dish.f_image.isEmpty
              ? Image.asset('assets/fastfood.png', height: 100)
              : SizedBox(
                  height: 200,
                  width: 200,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://${tools.serverName()}/engine/media/dishes/${dish.f_image}.png',
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 200,
                        height: 200,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/fastfood.png', height: 50),
                    fit: BoxFit.scaleDown,
                  ))
        ]),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('${tools.mdFormatDouble(dish.f_price)} ֏')]),
        Row(children: [
          Expanded(
              child: Text(dish.name(Tools.locale),
                  textAlign: TextAlign.center, style: dishNameStyle))
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(dish.description(Tools.locale),
                  textAlign: TextAlign.center, style: dishDescriptionStyle))
        ]),
        if (dish.f_netweight > 0.001)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Text('${tools.mdFormatDouble(dish.f_netweight)} ${locale().g}',
                    textAlign: TextAlign.center, style: basketWeightStyle))
          ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          OutlinedButton(
              onPressed: () {
                addToBasket(dish);
              },
              child: Text('+ ${locale().add}'))
        ])
      ])
    ]);
  }
}
