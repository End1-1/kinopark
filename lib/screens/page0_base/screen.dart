import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:kinopark/screens/page0_base/model.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:shimmer/shimmer.dart';
part 'screen.part.dart';

abstract class App extends StatelessWidget {
  final AppModel model;

  App(this.model, {super.key});

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
              if (state is AppStateError) {
                return errorDialog(state.text);
              }
              return Container();
            }),
      ]))
    );
  }

  Widget body(BuildContext context);

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      backgroundColor: kMainColor,
      actions: appBarActions(context),
    );
  }

  List<Widget> appBarActions(BuildContext context) {
    return [];
  }

  Widget columnSpace() {
    return const SizedBox(width: 10);
  }

  Widget rowSpace() {
    return const SizedBox(height: 10);
  }

  Widget languageButton() {
    return PopupMenuButton(
        icon: Image.asset('assets/flags/${Tools.locale}.png', height: 30, width: 30),
        itemBuilder: (itemBuilder) {
          return [
            PopupMenuItem(onTap: setLocaleHy, child: Row(children: [ Image.asset('assets/flags/hy.png', width: 30, height: 30), columnSpace(), Text('Հայերեն')])),
            PopupMenuItem(onTap: setLocaleRu, child: Row(children: [Image.asset('assets/flags/ru.png', width: 30), columnSpace(), Text('Русский')])),
            PopupMenuItem(onTap: setLocaleUs, child: Row(children: [Image.asset('assets/flags/en.png', width: 30), columnSpace(), Text('English')])),
          ];
        });
  }

  Widget image(String path, double size) {
    return SizedBox(height: size,
        width: size, child: CachedNetworkImage(
          imageUrl: 'https://${tools.serverName()}/engine/media/dishes/$path.png',

          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: size,
              height: size,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Image.asset('assets/fastfood.png', height: 50),
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
                                child: Styling.textCenter(text))),
                        columnSpace(),
                        Styling.textButton(model.closeDialog, model.tr('Close'))
                      ],
                    ),
                  )
                ])));
  }
}
