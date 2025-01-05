import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kinopark/tools/localilzator.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:uuid/uuid.dart';

class TextFieldAddress extends StatefulWidget {
  final TextEditingController addressController;
  final _aptController = TextEditingController();
  final IconButton rightButton;

   TextFieldAddress(this.addressController, this.rightButton, {super.key}) {
     _aptController.text = tools.getString('apt') ?? '';
   }

  @override
  State<StatefulWidget> createState() => _TextFieldAddress();
}

class _TextFieldAddress extends State<TextFieldAddress> {
  final GlobalKey _textFieldKey = GlobalKey();
  late FocusNode _focusNode;
  var _isSuggestionTap = false;
  OverlayEntry? _overlayEntry;
  final List<dynamic> predictions = [];
  late String _sessionToken;
  var _lastInput = '';

  @override
  void initState() {
    super.initState();
    _sessionToken = const Uuid().v1().toString();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!_isSuggestionTap) {
            _removeOverlay();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.white),
        child: Row(children: [
          Expanded(
              child: TextField(
            focusNode: _focusNode,
            key: _textFieldKey,
            onChanged: _query,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              suffixIcon: widget.addressController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearText,
                      icon: Icon(Icons.clear),
                      splashRadius: 20),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
            ),
            controller: widget.addressController,
          )),
          const SizedBox(width: 10),
          Text(locale().aptNumber),
          const SizedBox(width: 10),
          Container(width: 100, child: TextField(


            onChanged: _setAptNumber,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),

              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
            ),
            controller: widget._aptController,
          )),
          const SizedBox(width: 10),
          widget.rightButton
        ]));
  }

  void _clearText() {
    widget.addressController.clear();
    tools.setString('address', '');
    tools.setString('full_address', '');
    setState(() {});
  }

  void _setAptNumber(String s) {
    tools.setString('apt', s);
  }

  void _query(String s) async {
    _removeOverlay();
    if (_lastInput.isNotEmpty && _lastInput != s) {
      _lastInput = s;
      return;
    }
    _lastInput = s;
    predictions.clear();
    if (s.isNotEmpty) {
      try {
        var response = await Dio().get(
            '${tools.serverName()}/engine/google.php?autocomplete=1&input=$s&sessionToken=$_sessionToken',
            options: Options(responseType: ResponseType.plain));
        if (_lastInput != s) {
          _query(_lastInput);
          return;
        }
        predictions.addAll(json.decode(response.data)['predictions']);
        _overlayEntry = _createOverlay();
        Overlay.of(_textFieldKey.currentContext!)?.insert(_overlayEntry!);
      } catch (e) {
        if (e is DioException) {
          print(e.message.toString());
        }
        print(e.toString());
      }
    }
    _lastInput = '';
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    _isSuggestionTap = false;
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8)
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            predictions.length,
                            (index) => InkWell(
                                onTap: () async {
                                  _isSuggestionTap = true;
                                  final m = predictions[index];
                                  print(m);
                                  widget.addressController.text =
                                      m['structured_formatting']['main_text'] ??
                                          '';
                                  tools.setString('address',
                                      m['structured_formatting']['main_text']);
                                  tools.setString(
                                      'full_address', m['description']);
                                  tools.setString('coord', '');
                                  try {
                                    final url =
                                        '${tools.serverName()}/engine/google.php?pointofaddress=1&address=${m['description']}&sessionToken=$_sessionToken';
                                    print(url);
                                    var response = await Dio().get(url,
                                        options: Options(
                                            responseType: ResponseType.plain));
                                    final data = jsonDecode(response.data);
                                    if (data['status'] == 'OK' &&
                                        data['results'].isNotEmpty) {
                                      final g = data['results'][0]['geometry']
                                          ['location'];
                                      tools.setString('address_location',
                                          '${g['lat']},${g['lng']}');
                                    }
                                  } catch (e) {
                                    print(e);
                                    if (e is DioException) {
                                      print(e.response?.data);
                                    }
                                  }
                                  _removeOverlay();
                                  setState(() {});
                                },
                                mouseCursor: SystemMouseCursors.click,
                                child: Container(
                                    margin: const EdgeInsets.all(5),
                                    child: Row(children: [
                                      Expanded(
                                          child: Text(predictions[index]
                                                  ['description'] ??
                                              ''))
                                    ])))))))));
  }
}
