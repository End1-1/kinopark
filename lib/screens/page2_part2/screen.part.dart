part of 'screen.dart';

extension Part2Ext on Part2 {
  void _filterDishes(int part2) {
    model.searchResult.clear();
    model.filteredPart2 = model.part2.list.firstWhereOrNull((e) => e.f_id == part2);
    BlocProvider.of<Page1Bloc>(tools.context()).add(Page1Event());
  }

  void _addToBasket(Dish d) {
    if (model.dishSpecialMap.containsKey(d.f_id)) {
      showDialog(context: tools.context() , builder: (builder) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
              children: [
           for (final e in model.dishSpecialMap[d.f_id])...[
             InkWell(onTap:(){
               Navigator.pop(builder, e);
             }, child: Container(
               padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
               child: Text(e)
             ))
           ] 
          ]),
        );
      }).then((comment) {
        if (comment == null) {
          BlocProvider.of<AppErrorBloc>(tools.context()).add(AppErrorEvent(locale().atLeastOneOptionMustSelected));
          return;
        }
        model.addDishToBasket(d.copyWith(f_comment: comment));
      });
    } else {
      model.addDishToBasket(d);
    }
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
      'database': tools.database(),
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
      'database': tools.database(),
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
    if (data['errorCode'] != 0) {
      _searchResult.add(DishSearchStruct(id: 0, mode: -1, name: ''));
      Future.delayed(const Duration(seconds: 2), (){
        if (_searchTextController.text.isNotEmpty) {
          _searchSuggestDish(_searchTextController.text, _textFieldKey.currentContext!);
        }
      });
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