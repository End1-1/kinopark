part of 'screen.dart';

extension AppExt on App {

  AppLocalizations locale() {
    return AppLocalizations.of(tools.context())!;
  }

  void _saveLocale() async {
    final locale = await Hive.openBox('locale');
    await locale.put('locale', Tools.locale);
    BlocProvider.of<LocaleBloc>(tools.context()).add(LocaleEvent(Tools.locale));
  }

  void setLocaleHy() {
    Tools.locale = 'hy';
    _saveLocale();
  }

  void setLocaleRu() {
    Tools.locale = 'ru';
    _saveLocale();
  }

  void setLocaleUs() {
    Tools.locale = 'en';
    _saveLocale();
  }

  String localeName() {
    switch (Tools.locale) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'hy':
        return 'Հայերեն';
    }
    return '';
  }

  void showError(String text) {
    BlocProvider.of<AppErrorBloc>(tools.context()).add(AppErrorEvent(text));
  }

  void goToBasket() {
    Navigator.push(tools.context(), MaterialPageRoute(builder: (builder) => Basket(model)));
  }

  void navigateToSendMessage() {
    Navigator.push(
        tools.context(), MaterialPageRoute(builder: (_) => SendMessage(model)));
  }

  void _navigateToLogin() {}

  void _logout() {
    if (tools.getBool('denylogout') ?? false) {
      BlocProvider.of<AppErrorBloc>(tools.context()).add(AppErrorEvent(locale().noPermissionForThisAction));
      return;
    }
    BlocProvider.of<AppQuestionBloc>(tools.context())
        .add(AppQuestionEvent(locale().areYouSureToLogout, () {
      tools.setString('sessionkey', '');
      BlocProvider.of<LocaleBloc>(tools.context())
          .add(LocaleEvent(Tools.locale));
    }, null));
  }
}
