import 'package:flutter/material.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/screens/page2_part2/screen.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/tools.dart';

part 'screen.part.dart';

class HomePage extends App {
  HomePage(super.model, {super.key});

  @override
  Widget body(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final e in model.part1.list) ...[
            Expanded(
                child: InkWell(
                    onTap: () {
                      model.filteredPart2 = null;
                      model.searchResult.clear();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) =>
                                  Part2(model, part1: e.f_id)));
                    },
                    child: Container(
                        decoration: const BoxDecoration(
                            color: kMainColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        margin: const EdgeInsets.all(20),
                        child: Stack(alignment: Alignment.center, children: [
                          Row(children: [Expanded(child: image(e.f_image, 200))]),
                          if (e.f_image.isEmpty)
                            Row(children: [
                              Expanded(
                                  child: Text(e.f_name,
                                      textAlign: TextAlign.center,
                                      style: part1style))
                            ])
                        ]))))
          ]
        ]);
  }

  List<Widget> appBarActions(BuildContext context) {
    return [
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
                  Navigator.pop(context);  // Закрыть меню
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
              child: ListTile(leading: Icon(Icons.help_outline), title: Text( locale().support)),
            ),
            logoutButton()
          ];
        }),
    ];
  }
}
