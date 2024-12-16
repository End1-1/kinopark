import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/structs/payment_type.dart';
import 'package:kinopark/styles/style_part1.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/tools.dart';

part 'screen.part.dart';

class Payment extends App {
  final _stream = StreamController();
  final _infoController = TextEditingController();

  Payment(super.model);

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
        child:
            Column(children: [_payments(), _additionalInfo(), _orderButton(), rowSpace()]));
  }

  Widget _payments() {
    return StreamBuilder(
        stream: _stream.stream,
        builder: (builder, snapshot) {
          return Column(children: [
            rowSpace(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(locale().selectPaymentType, style: pageHeaderStyle)
            ]),
            InkWell(
                onTap: _selectCash,
                child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: model.paymentMethod == PaymentType.cash
                            ? Color(0xff80c28b)
                            : Colors.black12),
                    child: Row(children: [
                      model.paymentMethod == PaymentType.cash
                          ? Icon(Icons.check_box)
                          : Icon(Icons.check_box_outline_blank),
                      columnSpace(),
                      Text(locale().cash, style: paymentTextStyle)
                    ]))),
            InkWell(
                onTap: _selectCard,
                child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: model.paymentMethod == PaymentType.card
                            ? Color(0xff80c28b)
                            : Colors.black12),
                    child: Row(children: [
                      model.paymentMethod == PaymentType.card
                          ? Icon(Icons.check_box)
                          : Icon(Icons.check_box_outline_blank),
                      columnSpace(),
                      Text(locale().card, style: paymentTextStyle)
                    ]))),
            InkWell(
                onTap: _selectIdram,
                child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: model.paymentMethod == PaymentType.idram
                            ? Color(0xff80c28b)
                            : Colors.black12),
                    child: Row(children: [
                      model.paymentMethod == PaymentType.idram
                          ? Icon(Icons.check_box)
                          : Icon(Icons.check_box_outline_blank),
                      columnSpace(),
                      Text(locale().idram, style: paymentTextStyle)
                    ])))
          ]);
        });
  }

  Widget _additionalInfo() {
    return Column(children: [
      Container(
          margin: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
                child: TextFormField(
                    controller: _infoController,
                    maxLines: 5,
                    decoration: InputDecoration(
                        label: Text(locale().additionalInfo),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5))))))
          ]))
    ]);
  }

  Widget _orderButton() {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          backgroundColor: kMainColor),
                      onPressed: _order,
                      child: Text(
                          '${locale().order}  ${tools.mdFormatDouble(model.basketTotal())} ֏',
                          style:
                          const TextStyle(color: Colors.white))))
            ]));
  }


}
