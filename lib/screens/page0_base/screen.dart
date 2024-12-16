import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:kinopark/screens/page0_base/model.dart';
import 'package:kinopark/screens/page3_basket/screen.dart';
import 'package:kinopark/screens/page5_sendmessage/screen.dart';
import 'package:kinopark/structs/dish.dart';
import 'package:kinopark/structs/dish_search_result.dart';
import 'package:kinopark/structs/dishpart2.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/app_cubit.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:kinopark/widgets/app_menu.dart';
import 'package:shimmer/shimmer.dart';

part 'screen.part.dart';

abstract class App extends StatelessWidget {
  final AppModel model;
  final _searchTextController = TextEditingController();
  final _searchFocus = FocusNode();
  var _isSuggestionTap = false;
  late BuildContext _overlayContext;
  OverlayEntry? _overlayEntry;
  final GlobalKey _textFieldKey = GlobalKey();
  final _searchResult = <DishSearchStruct>[];

  App(this.model, {super.key}) {
    _searchFocus.addListener(_searchFocusChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(context),
        body: SafeArea(
            //minimum: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Stack(children: [
          body(context),
          BlocBuilder<AppErrorBloc, AppErrorState>(builder: (context, state) {
            if (state.errorString.isNotEmpty) {
              return errorDialog(state.errorString);
            }
            return Container();
          }),
          BlocBuilder<AppQuestionBloc, AppQuestionState>(
              builder: (builder, state) {
            return state.questionString.isEmpty
                ? Container()
                : questionDialog(
                    state.questionString, state.funcYes, state.funcNo);
          }),
          BlocBuilder<AppLoadingBloc, LoadingState>(builder: (builder, state) {
            return state.isLoading ? _loadingWidget() : Container();
          }),
          AppMenu(appMenuWidget())
        ])));
  }

  Widget body(BuildContext context);

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      backgroundColor: kMainColor,
      title: appBarTitle(context),
      actions: appBarActions(context),
    );
  }

  Widget? appBarTitle(BuildContext context) {
    return null;
  }

  Widget appBarSearch(BuildContext context) {
    var width = MediaQuery.sizeOf(tools.context()).width;
    width = width > 500 ? 400 : width * 0.5;
    return Expanded(child: Container(
        constraints:
            BoxConstraints(maxHeight: kToolbarHeight * 0.9),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.fromBorderSide(BorderSide(color: Colors.yellow)),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Row(children: [
          Expanded(
              child: TextFormField(
                  autofocus: true,
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
          InkWell(onTap: (){_searchTextController.clear();}, child: Container(
            height: kToolbarHeight * 0.9,
            width: 40,
              child: Icon(Icons.clear)
          )),
        InkWell(onTap: (){_submitSearch( _searchTextController.text);}, child:Container(
              height: kToolbarHeight * 0.9,
              width: 40,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: Icon(Icons.search)))
        ])));
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
                                orElse: () => DishPart2(f_id: 0, f_part: 0, f_name: '', f_en: '', f_ru: '', f_image: ''));
                            if (part2.f_id > 0) {
                              tools
                                  .context()
                                  .read<AppSearchTitleCubit>()
                                  .emit(part2.name(Tools.locale));
                              model.filteredPart2 = part2;
                              BlocProvider.of<Page1Bloc>(tools.context()).add(Page1Event());
                              return;
                            }
                          }
                          if (_searchResult[index].mode == 1) {
                            tools
                                .context()
                                .read<AppSearchTitleCubit>()
                                .emit('${locale().searchResult} "${_searchTextController.text}"');
                            final dish = model.dishes.list.firstWhere((e) =>
                            e.f_id == _searchResult[index].id, orElse: () =>
                                Dish(f_id: 0,
                                    f_part: 0,
                                    f_name: '',
                                    f_image: '',
                                    f_print1: '',
                                    f_print2: '',
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
                              BlocProvider.of<Page1Bloc>(tools.context()).add(Page1Event());
                            }
                          }
                        },
                        mouseCursor: SystemMouseCursors.click,
                        child: Row(children: [
                          Expanded(
                              child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  color: Colors.white,
                                  child: Text(_searchResult[index].name)))
                        ])))),
          ),
        ),
      ),
    );
  }

  List<Widget> appBarActions(BuildContext context) {
    return [];
  }

  List<Widget> appMenuWidget() {
    return [];
  }

  Widget columnSpace() {
    return const SizedBox(width: 10);
  }

  Widget rowSpace() {
    return const SizedBox(height: 10);
  }

  Widget basketButton() {
    return IconButton(
        onPressed: goToBasket,
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
        }));
  }

  Widget languageButton() {
    return PopupMenuButton(
        icon: Image.asset('assets/flags/${Tools.locale}.png',
            height: 30, width: 30),
        itemBuilder: (itemBuilder) {
          return popupMenuLanguageItems();
        });
  }

  PopupMenuItem username() {
    if (tools.getString('last') == null) {
      return PopupMenuItem(
          onTap: _navigateToLogin,
          child: ListTile(
              leading: Icon(Icons.login), title: Text(locale().login)));
    }
    return PopupMenuItem(
        enabled: false,
        child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.black),
            child: Text(
                '${tools.getString('last')} ${tools.getString('first')}')));
  }

  PopupMenuItem logoutButton() {
    return PopupMenuItem(
      onTap: _logout,
      child: ListTile(
          leading: Icon(
            Icons.exit_to_app,
            size: 30,
          ),
          title: Text(locale().logout)),
    );
  }

  List<PopupMenuItem> popupMenuLanguageItems() {
    return [
      PopupMenuItem(
          onTap: setLocaleHy,
          child: Row(children: [
            Image.asset('assets/flags/hy.png', width: 30, height: 30),
            columnSpace(),
            Text('Հայերեն')
          ])),
      PopupMenuItem(
          onTap: setLocaleRu,
          child: Row(children: [
            Image.asset('assets/flags/ru.png', width: 30),
            columnSpace(),
            Text('Русский')
          ])),
      PopupMenuItem(
          onTap: setLocaleUs,
          child: Row(children: [
            Image.asset('assets/flags/en.png', width: 30),
            columnSpace(),
            Text('English')
          ])),
    ];
  }

  Widget image(String path, double size) {
    return SizedBox(
        height: size,
        width: size,
        child: CachedNetworkImage(
          imageUrl:
              'https://${tools.serverName()}/engine/media/dishes/$path.png',
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: size,
              height: size,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) =>
              Image.asset('assets/fastfood.png', height: 50),
          fit: BoxFit.scaleDown,
        ));
  }

  Widget errorDialog(String text) {
    return Container(
        color: Colors.black26,
        child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    columnSpace(),
                    Container(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.sizeOf(tools.context()).height *
                                    0.7),
                        child: SingleChildScrollView(
                            child: Text(text,
                                maxLines: 10,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black)))),
                    TextButton(
                        onPressed: model.closeErrorDialog,
                        child: Text(locale().close))
                  ],
                ),
              )
            ])));
  }

  Widget questionDialog(String text, VoidCallback ifYes, VoidCallback? ifNo) {
    return Container(
        color: Colors.black26,
        child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.question_answer_outlined,
                      color: Colors.green,
                    ),
                    columnSpace(),
                    Container(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.sizeOf(tools.context()).height *
                                    0.7),
                        child: SingleChildScrollView(
                            child: Text(text, textAlign: TextAlign.center))),
                    columnSpace(),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      TextButton(
                          onPressed: () {
                            model.closeQuestionDialog();
                            ifYes();
                          },
                          child: Text(locale().yes)),
                      TextButton(
                          onPressed: () {
                            model.closeQuestionDialog();
                            if (ifNo != null) {
                              ifNo!();
                            }
                          },
                          child: Text(locale().no))
                    ])
                  ],
                ),
              )
            ])));
  }

  Widget _loadingWidget() {
    return Container(
        color: Colors.black26,
        child: Center(child: CircularProgressIndicator()));
  }
}
