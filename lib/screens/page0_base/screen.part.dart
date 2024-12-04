part of 'screen.dart';

extension AppExt on App {
  AppLocalizations locale() {
    return AppLocalizations.of(tools.context())!;
  }

  void _saveLocale() async {
    final locale = await Hive.openBox('locale');
    await locale.put('locale', Tools.locale);
    BlocProvider.of<LocaleBloc>(tools.context()).add(LocaleEvent());
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

  void errorDialog(String text) {
    showDialog(
        context: tools.context(), builder: (builder) {
      return
      AlertDialog(
        icon: Image.asset('assets/kinopark.png', height: 30), content: Text(text, textAlign: TextAlign.center), actions: [
          TextButton(onPressed: (){Navigator.pop(tools.context());}, child: Text('Ok'))
      ],);
    });
  }
}