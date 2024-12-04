import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:kinopark/screens/page0_base/model.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/tools.dart';
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
       body(context)
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
}
