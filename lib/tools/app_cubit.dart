import 'package:flutter_bloc/flutter_bloc.dart';

enum AppMenuState {msOpen, msClosed}

class AppMenuCubit extends Cubit<AppMenuState> {
  AppMenuCubit() : super(AppMenuState.msClosed);

  void toggle() => emit(state == AppMenuState.msClosed ? AppMenuState.msOpen : AppMenuState.msClosed);
}

class AppSearchTitleCubit extends Cubit<String> {
  AppSearchTitleCubit(super.initialState);

}