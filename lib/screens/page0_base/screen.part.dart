part of 'screen.dart';

extension AppExt on App {
  AppLocalizations locale() {
    return AppLocalizations.of(tools.context())!;
  }
}