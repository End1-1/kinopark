part of 'screen.dart';

extension AppExt on App {
  void _searchSuggestDish(String? dishname, BuildContext context) {
    if (_overlayEntry != null) {
      _removeOverlay();
    }
    if (dishname == null || dishname.isEmpty) {
      return;
    }

    final msg = <String, dynamic>{
      'command': 'search_text',
      'database':'kinopark',
      'template': _searchTextController.text.toLowerCase(),
      'language': Tools.locale,
    };
    _overlayContext = context;
    model.webSocket.sendMessage(jsonEncode(msg), _searchSuggest);

  }

  void _submitSearch(String text) {
    if (_overlayEntry != null) {
      _removeOverlay();
    }

    final msg = <String, dynamic>{
      'command': 'search_text',
      'database':'kinopark',
      'template': text.toLowerCase(),
      'language': Tools.locale,
    };
    model.webSocket.sendMessage(jsonEncode(msg), _searchSubmitResult);
  }

  void _searchSuggest(Map<String, dynamic> data) {
    _searchResult.clear();
    for (final e in data['result'] ?? []) {
      _searchResult.add(DishSearchStruct.fromJson(e));
    }
    _overlayEntry = _createOverlay();
    Overlay.of(_overlayContext)?.insert(_overlayEntry!);
  }

  void _searchSubmitResult(Map<String, dynamic> data) {
    _searchResult.clear();
    for (final e in data['result'] ?? []) {
      _searchResult.add(DishSearchStruct.fromJson(e));
    }
    _searchFocus.requestFocus();
    model.filteredPart2 = null;
    model.searchResult.clear();
    model.searchResult.addAll(_searchResult);
    BlocProvider.of<Page1Bloc>(tools.context()).add(Page1Event());
  }

  void _searchDish() {
    _removeOverlay();
    _isSuggestionTap = false;

  }

  void _searchFocusChanged() {
    if (!_searchFocus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!_isSuggestionTap) {
          _removeOverlay();
        }
      }
      );
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

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

  void navigateToSendMessage() {
    Navigator.push(
        tools.context(), MaterialPageRoute(builder: (_) => SendMessage(model)));
  }

  void _navigateToLogin() {}

  void _logout() {
    BlocProvider.of<AppQuestionBloc>(tools.context())
        .add(AppQuestionEvent(locale().areYouSureToLogout, () {
      tools.setString('sessionkey', '');
      BlocProvider.of<LocaleBloc>(tools.context())
          .add(LocaleEvent(Tools.locale));
    }, null));
  }
}
