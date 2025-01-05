part of 'screen.dart';

extension SignupExt on Signup {
  void _signUp() {
    if (_phoneController.text.length != 8) {
      BlocProvider.of<AppErrorBloc>(tools.context())
          .add(AppErrorEvent(locale().invalidPhoneNumber));
      return;
    }
    BlocProvider.of<HttpBloc>(tools.context()).add(HttpEvent(
        'login.php',
        {'phone': '+374${_phoneController.text}', 'method': 5, 'step': 1}, _signupResponse));
  }

  void _back() {
    _smsController.clear();
    tools.context().read<AppCubit>().setActivationState(false);
  }

  void _signConfirmCode() {
    if (_smsController.text.length != 4) {
      BlocProvider.of<AppErrorBloc>(tools.context())
          .add(AppErrorEvent(locale().invalidConfirmationCode));
      return;
    }
    BlocProvider.of<HttpBloc>(tools.context()).add(HttpEvent(
        'login.php',
        {
          'phone': '+374${_phoneController.text}',
          'code': _smsController.text,
          'method': 5,
          'step': 2
        }, _signConfirmResponse));
  }

  Future<void> _signupResponse(dynamic data) async {
    tools.context().read<AppCubit>().setActivationState(true);
  }

  Future<void> _signConfirmResponse(dynamic data) async {
    data = data['data'];
    data = data['user'];
    await tools.setString('login', data['f_login']);
    print(tools.getString('login'));
    Navigator.pop(tools.context(), true);
  }
}
