import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/screens/page3_basket/screen.dart';
import 'package:kinopark/structs/dish.dart';
import 'package:kinopark/structs/dishpart2.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/app_cubit.dart';
import 'package:kinopark/tools/tools.dart';

part 'screen.part.dart';

class Part2 extends App {
  final rectWidth = (MediaQuery.sizeOf(tools.context()).width / 2) - 20;
  final int part1;

  Part2(super.model, {super.key, required this.part1});

  @override
  Widget body(BuildContext context) {
    return Column(children: [
      _part2Row(),
      Expanded(child: Container(color: Colors.black12, child: _dishesRow()))
    ]);
  }

  @override
  List<Widget> appMenuWidget() {
    return [for (final e in model.part2.get(part1)) ...[
      InkWell(onTap: (){
        tools.context().read<AppMenuCubit>().toggle();
        _filterDishes(e.f_id);}, child: Container(
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child:  Text(e.name(Tools.locale), style: appMenuItemStyle )))
    ]];
  }

  @override
  Widget? appBarTitle(BuildContext context) {
    return Row(children: [Expanded(child: Container()), appBarSearch(context), Expanded(child: Container())]);
  }

  Widget _topOfDishes() {
    return BlocBuilder<AppSearchTitleCubit, String>(builder: (builder, state) {return  Row(children: [
      Expanded(
          child: Container(
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.indigo),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              child: Text(
                state,
                style: topDishPartStyle,
              )))
    ]);});
  }

  Widget _dishWidget(Dish e) {
    return Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white),
        width: rectWidth,
        child: Stack(children: [
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.info_outlined))
            ]),
          ]),
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              e.f_image.isEmpty
                  ? Image.asset('assets/fastfood.png', height: 100)
                  : image(e.f_image, 100)
            ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('${tools.mdFormatDouble(e.f_price)} ֏')]),
            Container(
                height: 70, child: Text(e.name(Tools.locale), textAlign: TextAlign.center)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(
                  onPressed: () {
                    _addToBasket(e);
                  },
                  child: Text('+ ${locale().add}'))
            ])
          ])
        ]));
  }

  Widget _part2Widget(DishPart2 e) {
    return Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white),
        width: rectWidth,
        child: Stack(children: [
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.info_outlined))
            ]),
          ]),
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              e.f_image.isEmpty
                  ? Image.asset('assets/fastfood.png', height: 100)
                  : image(e.f_image, 100)
            ]),
            Container(
                height: 70, child: Text(e.name(Tools.locale), textAlign: TextAlign.center)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(
                  onPressed: () {
                    tools
                        .context()
                        .read<AppSearchTitleCubit>()
                        .emit(e.name(Tools.locale));
                    model.filteredPart2 = e;
                    BlocProvider.of<Page1Bloc>(tools.context()).add(Page1Event());
                  },
                  child: Text('+ ${locale().goto}'))
            ])
          ])
        ]));
  }

  Widget _dishesRow() {
    return BlocBuilder<Page1Bloc, Page1State>(builder: (builder, state) {
      return Column(children: [
        _topOfDishes(),
        Expanded(
            child: SingleChildScrollView(
                child: Wrap(
          children: [
            for (final e in model.filteredDishes()) ...[_dishWidget(e)],
            for (final es in model.searchResult)...[
              if (es.mode == 1)
                _dishWidget(model.dishes.list.firstWhere((e) => e.f_id == es.id)),
              if (es.mode == 2)
                _part2Widget(model.part2.list.firstWhere((e) => e.f_id== es.id))
              ]
          ],
        )))
      ]);
    });
  }



  Widget _part2Row() {
    return Row(children: [
      Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(5),
          child: IconButton(
              onPressed: tools.context().read<AppMenuCubit>().toggle,
              icon: Icon(Icons.menu))),
      Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final e in model.part2.get(part1)) ...[
                  InkWell(
                      onTap: () {
                        _filterDishes(e.f_id);
                        tools.context().read<AppSearchTitleCubit>().emit(e.name(Tools.locale));
                      },
                      child: Container(
                          decoration: const BoxDecoration(
                              color: kMainColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(5),
                          height: 60,
                          child: Text(
                            e.name(Tools.locale),
                            style: part2style,
                          )))
                ]
              ])))
    ]);
  }

  @override
  List<Widget> appBarActions(BuildContext context) {
    return [
      IconButton(
          onPressed: _goToBasket,
          icon: BlocBuilder<BasketBloc, BasketState>(builder: (builder, state) {
            return SizedBox(
                width: 32,
                height: 32,
                child: Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.shopping_basket_outlined),
                  model.basket.isEmpty
                      ? Container()
                      : Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              width: 16,
                              height: 16,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                  model.basket.isEmpty
                                      ? ''
                                      : '${model.basket.length}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))))
                ]));
          })),
      PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (builder) {
            return [
              username(),
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
              ),
              logoutButton()
            ];
          }),
    ];
  }
}
