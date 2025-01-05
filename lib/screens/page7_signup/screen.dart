import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kinopark/screens/page0_base/screen.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/app_cubit.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';

part 'screen.part.dart';

class Signup extends App {
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();

  Signup(super.model, {super.key});

  @override
  Widget body(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/${dotenv.env['icon']}', height: 200),
          rowSpace(),
           BlocBuilder<AppCubit, int>(builder: (builder, state) {
            if (context.read<AppCubit>().activationState()) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [..._phoneStep()]);
            }
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [..._smsStep()]);
          })
        ]);
  }

  List<Widget> _phoneStep() {
    return [
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(locale().phoneNumber, textAlign: TextAlign.center)]),
      rowSpace(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('+374'),
        columnSpace(),
        SizedBox(
            width: 300,
            child: TextField(
              controller: _phoneController,
              autofocus: true,
              onSubmitted: (_) {
                _signUp();
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'xx xxx xxx', border: OutlineInputBorder()),
            ))
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(onPressed: _signUp, child: Text(locale().signUp))
      ])
    ];
  }

  List<Widget> _smsStep() {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${locale().whereAreSendCodeOn} +374 ${_phoneController.text}')
      ]),
      rowSpace(),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(locale().inputComfirmationCode)]),
      rowSpace(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 100,
            child: TextField(
              controller: _smsController,
              autofocus: true,
              onSubmitted: (_) {
                _signConfirmCode();
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ))
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(onPressed: _back, child: Text(locale().changePhoneNumber)),
        columnSpace(),
        TextButton(onPressed: _signConfirmCode, child: Text(locale().confirm))
      ])
    ];
  }
}
