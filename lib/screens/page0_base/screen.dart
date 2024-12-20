import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:kinopark/screens/page0_base/model.dart';
import 'package:kinopark/screens/page3_basket/screen.dart';
import 'package:kinopark/screens/page5_sendmessage/screen.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/app_cubit.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:kinopark/widgets/app_menu.dart';
import 'package:shimmer/shimmer.dart';

part 'screen.part.dart';

abstract class App extends StatelessWidget {
  final AppModel model;

  App(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: canPop(),
        onPopInvokedWithResult: onPopHandle,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBar(context),
            body: SafeArea(
                //minimum: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Stack(children: [
              body(context),
              BlocBuilder<AppErrorBloc, AppErrorState>(
                  builder: (context, state) {
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
              BlocBuilder<AppLoadingBloc, LoadingState>(
                  builder: (builder, state) {
                return state.isLoading ? _loadingWidget() : Container();
              }),
              AppMenu(appMenuWidget())
            ]))));
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
    return BlocBuilder<BasketBloc, BasketState>(builder: (builder, state) {
      if (model.basket.isEmpty) {
        return Container();
      }
      return InkWell(
          onTap: goToBasket,
          child: Container(
            padding: const EdgeInsets.fromLTRB(2, 1, 5, 1),
            decoration: const BoxDecoration(
              color: Colors.yellowAccent,
              borderRadius: BorderRadius.all(Radius.circular(5))
            ),
          margin: const EdgeInsets.all(1),  
              child:  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
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
                ])),
            columnSpace(),
            Text('${tools.mdFormatDouble(model.totalWithService())} ֏', style: basketPriceStyle,)
          ])));
    });
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
