
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/tools.dart';

part 'screen.part.dart';

class SendMessage extends App {
  final _messageController = TextEditingController();
  SendMessage(super.model);

  @override
  Widget body(BuildContext context) {
    return Column(children:[
      Expanded(child: SingleChildScrollView(child: Column(children: [

      ]))),
      Container(
        margin: const EdgeInsets.all(10),

      child: Row(children: [
        Expanded(child: TextFormField(
          autofocus: true,
            textInputAction: TextInputAction.done,
          maxLines: 2,
            minLines: 2,
            controller: _messageController,
          onFieldSubmitted: (_){_sendMessage();},
          decoration: InputDecoration(border: OutlineInputBorder( borderSide: BorderSide(color: Colors.black12)),label: Text(locale().yourMessage)))),
        Container(child: IconButton(onPressed: _sendMessage, icon: Icon(Icons.send)))
        ]
      )),
    Container(
    margin: const EdgeInsets.all(10),

    child: Row(children: [
      TextButton(onPressed: _comeToHere, child: Text(locale().pleaseComeHere))
      ]))
    ]);
  }

}