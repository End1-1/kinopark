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
    if (model.paymentMethod == 0) {
      errorDialog(locale().selectPaymentType);
      return;
    }
    model.additionalInfo = _infoController.text;
    model.createOrder();
    final data = <String, dynamic>{
      'header': <String, dynamic> {
        'hall': tools.getInt('hall'),
        'table': tools.getInt('table'),
        'amounttotal': model.basketTotal(),
        'amountcash': model.paymentMethod == 1 ? model.basketTotal() : 0,
        'amountcard': model.paymentMethod == 2 ? model.basketTotal() : 0,
        'amountidram': model.paymentMethod == 3 ? model.basketTotal() : 0,
        'amountother': 0,
        'amountdiscount':0,
        'discountfactor':0,
        'partner':0,
        'taxpayertin': ''

      }
    };
    BlocProvider.of<HttpBloc>(tools.context()).add(HttpEvent('engine/kinopark/create-order.php', data));
  }
}
