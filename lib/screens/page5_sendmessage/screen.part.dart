part of 'screen.dart';

extension SendMessageExt on SendMessage {
  void _sendMessage() {
    if (_messageController.text.isEmpty) {
      return;
    }
    final msg = {
      'sessionkey': tools.getString('sessionkey'),
      'database': tools.database(),
      'command': 'chat',
      'handler': 'newmessage',
      'from': tools.getString('sessionkey'),
      'to': tools.getInt('chatoperatoruserid'),
      'message': {'text':_messageController.text}
    };
    model.webSocket.sendMessage(jsonEncode(msg), _sendMessageResponse);
    _messageController.clear();
  }

  void _comeToHere() {
    _messageController.text = locale().pleaseComeHere;
    _sendMessage();
  }

  void _sendMessageResponse(Map<String, dynamic> response) {
    BlocProvider.of<AppErrorBloc>(tools.context()).add(AppErrorEvent(locale().yourMessageWasSent));
    Navigator.pop(tools.context());
  }
}
