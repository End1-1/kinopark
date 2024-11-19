import 'package:flutter/material.dart';
import 'package:kinopark/screens/page0_base/model.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        minimum: const EdgeInsets.fromLTRB(5, 5, 5, 5),
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
}
