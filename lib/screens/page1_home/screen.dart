import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/screens/page2_part2/screen.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/styles/styles.dart';

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
                child: InkWell(onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder: (builder) => Part2(model, part1: e.f_id)));
                }, child: Container(
                    decoration: const BoxDecoration(color: kMainColor, borderRadius: BorderRadius.all(Radius.circular(20))),
                    margin: const EdgeInsets.all(20),
                    child: Stack(
                      alignment: Alignment.center,
                        children:[
                          Row(children: [Expanded(child: Image.memory(base64Decode(e.f_image)))]),
                          if(e.f_image.isEmpty)
                          Row(children: [
                      Expanded(
                          child: Text(e.f_name,
                              textAlign: TextAlign.center, style: part1style))
                    ])]))))
          ]
        ]);
  }
}