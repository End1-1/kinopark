import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:uuid/uuid.dart';

class TextFieldAddress extends StatefulWidget {
  final TextEditingController addressController;
  final IconButton rightButton;

  const TextFieldAddress(this.addressController, this.rightButton, {super.key});

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
      if (!_focusNode.hasFocus ) {
        Future.delayed(const Duration(milliseconds: 250), ()
        {
          if (!_isSuggestionTap) {
            _removeOverlay();
          }
        });}
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
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              suffix:  widget.addressController.text.isEmpty ? null : IconButton(onPressed: _clearText, icon: Icon(Icons.clear)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
            ),
            controller: widget.addressController,
          )),
          widget.rightButton
        ]));
  }
  
  void _clearText() {
    widget.addressController.clear();
    setState(() {

    });
  }

  void _query(String s) async {
    print('$s');
    _removeOverlay();
    if (_lastInput.isNotEmpty && _lastInput != s) {
      _lastInput = s;
      return;
    }
    _lastInput = s;
    predictions.clear();
    if (s.isNotEmpty) {
      try {
        var response = await Dio().get('${tools.serverName()}/engine/google.php?autocomplete=1&input=$s&sessionToken=$_sessionToken', options: Options(responseType: ResponseType.plain));
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
                child:  Container(
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
                                onTap: () {
                                  _isSuggestionTap = true;
                                  widget.addressController.text =
                                      predictions[index]['description'] ?? '';
                                  _removeOverlay();
                                  setState(() {
                                    
                                  });
                                },
                                mouseCursor: SystemMouseCursors.click,
                                child: Container(
                                    margin: const EdgeInsets.all(5),
                                    child: Row(children: [
                                      Expanded(
                                          child: Text(
                                              predictions[index]['description'] ??
                                                  ''))
                                    ])))))))));
  }
}
