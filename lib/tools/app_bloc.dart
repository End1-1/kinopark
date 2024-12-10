import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'http_dio.dart';

const hrIdle = -2;
const hrFail = 0;
const hrOk = 1;

class AppState extends Equatable {
  final int id;

  const AppState(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadingState extends AppState {
  final bool isLoading;

  const LoadingState(super.id, this.isLoading);
}

class Page1State extends AppState {
  const Page1State(super.id);
}

class BasketState extends AppState {
  const BasketState(super.id);
}

class LocaleState extends AppState {
  const LocaleState(super.id);
}

class AppErrorState extends AppState {
  final String errorString;
  const AppErrorState(super.id, this.errorString);

  @override
  List<Object?> get props => [id, errorString];

}

class HttpState extends AppState {
  final int responseCode;
  var errorMessage = '';
  final dynamic data;

  HttpState(super.id, this.data,
      {this.responseCode = hrIdle, this.errorMessage = ''}) {
    if (kDebugMode) {
      print('ID OF STATE $this.id');
    }
  }

  @override
  List<Object?> get props => [id, responseCode, errorMessage, data];
}

class AppEvent extends Equatable {
  static int _counter = 0;
  late final int id;

  AppEvent() {
    id = ++_counter;
  }

  @override
  List<Object?> get props => [];

  int newId() {
    return ++_counter;
  }
}

class Page1Event extends AppEvent {}

class BasketEvent extends AppEvent {}

class LocaleEvent extends AppEvent {}

class AppErrorEvent extends AppEvent {
  final String errorString;
  AppErrorEvent(this.errorString);
}

class HttpEvent extends AppEvent {
  final String route;
  final Map<String, dynamic> data;

  HttpEvent(this.route, this.data);
}

class HttpBloc extends Bloc<AppEvent, AppState> {
  HttpBloc(super.initialState) {
    on<HttpEvent>((event, emit) => _httpQuery(event));
  }

  void _httpQuery(HttpEvent e) async {
    emit(LoadingState(e.id, true));
    try {
      final response = await HttpDio().post(e.route, inData: e.data);
      emit(LoadingState(e.id, false));
    } catch (ex) {
      emit(LoadingState(e.id, false));
      emit(AppErrorState(e.newId(), ex.toString()));
    }
  }
}

class Page1Bloc extends Bloc<Page1Event, Page1State> {
  Page1Bloc(super.initialState) {
    on<Page1Event>((event, emit) => emit(Page1State(event.id)));
  }
}

class BasketBloc extends Bloc<BasketEvent, BasketState> {
  BasketBloc(super.initialState) {
    on<BasketEvent>((event, emit) => emit(BasketState(event.id)));
  }
}

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(super.initialState) {
    on<LocaleEvent>((event, emit) => emit(LocaleState(event.id)));
  }
}

class AppErrorBloc extends Bloc<AppErrorEvent, AppErrorState> {
  AppErrorBloc(super.initialState) {
    on<AppErrorEvent>((event, emit) => emit(AppErrorState(event.id, event.errorString)));
  }
}
