part of 'screen.dart';

extension PaymentExt on Payment {
  void _selectCash() {
    model.paymentMethod = PaymentType.cash;
    _stream.add(null);
  }

  void _selectCard() {
    model.paymentMethod = PaymentType.card;
    _stream.add(null);
  }

  void _selectIdram() {
    model.paymentMethod = PaymentType.idram;
    _stream.add(null);
  }

  void _order() {
    model.additionalInfo = _infoController.text;
  }
}