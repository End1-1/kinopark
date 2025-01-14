import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/structs/dish.dart';
import 'package:kinopark/structs/dish_search_result.dart';
import 'package:kinopark/structs/dishpart2.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/app_cubit.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:kinopark/widgets/dish_details.dart';

part 'screen.part.dart';

class Part2 extends App {
  final rectWidth = (MediaQuery.sizeOf(tools.context()).width / 2) - 20;
  final int part1;
  final _searchTextController = TextEditingController();
  final _searchFocus = FocusNode();
  var _isSuggestionTap = false;
  late BuildContext _overlayContext;
  OverlayEntry? _overlayEntry;
  final GlobalKey _textFieldKey = GlobalKey();
  final _searchResult = <DishSearchStruct>[];

  Part2(super.model, {super.key, required this.part1}) {
    _searchFocus.addListener(_searchFocusChanged);
  }

  @override
  Widget body(BuildContext context) {
    return Column(children: [
      _part2Row(context),
      Expanded(child: Container(color: Colors.white, child: _dishesRow()))
    ]);
  }

  @override
  List<Widget> appMenuWidget() {
    final l = <Widget>[];
    String parentname = '';
    for (final e in model.part2.get(part1)) {
      if (e.parentname(Tools.locale) != parentname) {
        parentname = e.parentname(Tools.locale);
        l.add(rowSpace());
        l.add(rowSpace());
        l.add(Text(e.parentname(Tools.locale),
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent)));
      }
      l.add(InkWell(
          onTap: () {
            tools.context().read<AppMenuCubit>().toggle();
            tools
                .context()
                .read<AppSearchTitleCubit>()
                .emit(e.name(Tools.locale));
            _filterDishes(e.f_id);
          },
          child: Row(children: [
            Expanded(
                child: Container(
                    height: 30,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(e.name(Tools.locale), style: appMenuItemStyle)))
          ])));
    }
    l.add(const SizedBox(height: 60));
    return l;
  }

  @override
  Widget? appBarTitle(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: []);
  }

  Widget appBarSearch(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.fromBorderSide(BorderSide(color: Colors.yellow)),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(children: [
          Expanded(
              child: TextFormField(
                  key: _textFieldKey,
                  controller: _searchTextController,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: _submitSearch,
                  onChanged: (text) {
                    _searchSuggestDish(text, context);
                  },
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                      hintText: locale().searchDish,
                      border:
                          OutlineInputBorder(borderSide: BorderSide.none)))),
          InkWell(
              onTap: () {
                _searchTextController.clear();
              },
              child: Container(
                  height: kToolbarHeight * 0.9,
                  width: 40,
                  child: Icon(Icons.clear))),
          InkWell(
              onTap: () {
                _submitSearch(_searchTextController.text);
              },
              child: Container(
                  height: kToolbarHeight * 0.9,
                  width: 40,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: const BoxDecoration(),
                  child: Icon(Icons.search, color: Colors.black)))
        ]));
  }

  Widget _topOfDishes() {
    return BlocBuilder<AppSearchTitleCubit, String>(builder: (builder, state) {
      if (state.isEmpty) {
        return Container();
      }
      return Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.indigo),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          child: Row(children: [
            Expanded(
                child: Text(
              state,
              style: topDishPartStyle,
              textAlign: TextAlign.center,
            )),
          ]));
    });
  }

  Widget _dishWidget(Dish e) {
    if (e.f_id == 0) {
      return Container();
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
            boxShadow: [
        BoxShadow(
        color: Colors.grey, // Цвет тени
      spreadRadius:2, // Расширение
      blurRadius: 15, // Размытие
      offset: const Offset(2, 4), // Смещение (x, y)
    )],
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white),
        width: rectWidth,
        child: Stack(children: [
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                  onPressed: () {
                    _dishInfo(e);
                  },
                  icon: Icon(Icons.info_outlined))
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
                height: 70,
                child: Text(e.name(Tools.locale), textAlign: TextAlign.center)),
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
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.info_outlined))
            ]),
          ]),
          Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              e.f_image.isEmpty
                  ? Image.asset('assets/fastfood.png', height: 100)
                  : image(e.f_image, 100)
            ]),
            Container(
                height: 70,
                child: Text(e.name(Tools.locale), textAlign: TextAlign.center)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(
                  onPressed: () {
                    tools
                        .context()
                        .read<AppSearchTitleCubit>()
                        .emit(e.name(Tools.locale));
                    model.filteredPart2 = e;
                    BlocProvider.of<Page1Bloc>(tools.context())
                        .add(Page1Event());
                  },
                  child: Text('+ ${locale().goto}'))
            ])
          ])
        ]));
  }

  Widget _dishesRow() {
    return BlocBuilder<Page1Bloc, Page1State>(builder: (builder, state) {
      return Container( child:  Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        _topOfDishes(),
        Expanded(
            child: SingleChildScrollView(
                child: Row(
                    children: [Expanded(child: Wrap(
                      alignment: WrapAlignment.center,
                  runSpacing: 10,
          children: [
            for (final e in model.filteredDishes()) ...[_dishWidget(e)],
            for (final es in model.searchResult) ...[
              if (es.mode == 1)
                _dishWidget(
                    model.dishes.list.firstWhere((e) => e.f_id == es.id, orElse: () => Dish(f_id: 0, f_part: 0, f_name: '', f_image: '', f_print1: '', f_print2: '', f_price: 0, f_qty: 0, f_netweight: 0, f_store: 0, f_comment: '', f_en: '', f_ru: '', f_descriptionhy: '', f_descriptionen: '', f_descriptionru: ''))),
              if (es.mode == 2)
                _part2Widget(
                    model.part2.list.firstWhere((e) => e.f_id == es.id)),
            ],
            if (model.filteredDishes().isEmpty && model.searchResult.isEmpty)
              for (final e in model.recentDishes(part1)) ...[_dishWidget(e)]
          ],
        ))])
            ))
      ]));
    });
  }

  Widget _part2Row(BuildContext context) {
    return Row(children: [
      Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(5),
          child: IconButton(
              onPressed: tools.context().read<AppMenuCubit>().toggle,
              icon: const Icon(Icons.menu))),
      Expanded(child: appBarSearch(context))
    ]);
  }

  @override
  List<Widget> appBarActions(BuildContext context) {
    return [
      basketButton(),
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

  OverlayEntry _createOverlay() {
    RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    var position = renderBox.localToGlobal(Offset.zero);
    var width = renderBox.size.width;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + renderBox.size.height,
        left: position.dx,
        width: width,
        child: Material(
          elevation: 5,
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    _searchResult.length,
                    (index) => InkWell(
                        onTap: () {
                          _isSuggestionTap = true;
                          _searchTextController.text =
                              _searchResult[index].name;
                          _removeOverlay();
                          if (_searchResult[index].mode == 2) {
                            final part2 = model.part2.list.firstWhere(
                                (e) => e.f_id == _searchResult[index].id,
                                orElse: () => DishPart2(
                                    f_id: 0,
                                    f_part: 0,
                                    f_name: '',
                                    f_en: '',
                                    f_parentnameen: '',
                                    f_parentnamehy: '',
                                    f_parentnameru: '',
                                    f_ru: '',
                                    f_image: ''));
                            if (part2.f_id > 0) {
                              tools
                                  .context()
                                  .read<AppSearchTitleCubit>()
                                  .emit(part2.name(Tools.locale));
                              model.filteredPart2 = part2;
                              BlocProvider.of<Page1Bloc>(tools.context())
                                  .add(Page1Event());
                              return;
                            }
                          }
                          if (_searchResult[index].mode == 1) {
                            final dish = model.dishes.list.firstWhere(
                                (e) => e.f_id == _searchResult[index].id,
                                orElse: () => Dish(
                                    f_id: 0,
                                    f_part: 0,
                                    f_name: '',
                                    f_image: '',
                                    f_print1: '',
                                    f_print2: '',
                                    f_descriptionen: '',
                                    f_descriptionhy: '',
                                    f_descriptionru: '',
                                    f_price: 0,
                                    f_qty: 0,
                                    f_netweight: 0,
                                    f_store: 0,
                                    f_comment: '',
                                    f_en: '',
                                    f_ru: ''));
                            if (dish.f_id > 0) {
                              model.filteredPart2 = null;
                              model.searchResult.clear();
                              model.searchResult.add(_searchResult[index]);
                              BlocProvider.of<Page1Bloc>(tools.context())
                                  .add(Page1Event());
                            }
                          }
                        },
                        mouseCursor: SystemMouseCursors.click,
                        child: Container(
                            padding: const EdgeInsets.all(2),
                            color: Colors.white,
                            child: _searchResult[index].mode == -1
                                ? Row(children: [
                                    CircularProgressIndicator(),
                                    Expanded(child: Container())
                                  ])
                                : Row(children: [
                                    Expanded(
                                        child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            color: Colors.white,
                                            child: Text(
                                                _searchResult[index].name)))
                                  ]))))),
          ),
        ),
      ),
    );
  }
}
