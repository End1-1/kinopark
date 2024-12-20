part of 'screen.dart';

extension Part2Ext on Part2 {
  void _filterDishes(int part2) {
    model.searchResult.clear();
    model.filteredPart2 = model.part2.list.firstWhereOrNull((e) => e.f_id == part2);
    BlocProvider.of<Page1Bloc>(tools.context()).add(Page1Event());
  }

  void _addToBasket(Dish d) {
    model.addDishToBasket(d);

  }

  void _dishInfo(Dish d) {
    showDialog(context: tools.context(), builder: (builder) {
      return AlertDialog(
        content: DishDetails(d, _addToBasket),
      );
    });
  }

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
    if (text.isEmpty) {
      tools.context().read<AppSearchTitleCubit>().emit('');
      return;
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
    tools.context().read<AppSearchTitleCubit>().emit(
        '${locale().searchResult} "${_searchTextController.text}"');
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
}