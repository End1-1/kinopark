import 'package:flutter_bloc/flutter_bloc.dart';

enum AppMenuState {msOpen, msClosed}

int flSearch = 1 << 1;

class AppMenuCubit extends Cubit<AppMenuState> {
  AppMenuCubit() : super(AppMenuState.msClosed);

  void toggle() => emit(state == AppMenuState.msClosed ? AppMenuState.msOpen : AppMenuState.msClosed);
}

class AppSearchTitleCubit extends Cubit<String> {
  AppSearchTitleCubit(super.initialState);

}

class AppCubit extends Cubit<int> {
  AppCubit() : super(0);
}