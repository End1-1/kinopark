import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinopark/tools/tools.dart';

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

  @override
  List<Object?> get props => [id, isLoading];
}

class Page1State extends AppState {
  const Page1State(super.id);
}

class BasketState extends AppState {
  const BasketState(super.id);
}

class LocaleState extends AppState {
  final String locale;

  const LocaleState(super.id, this.locale);

  @override
  List<Object?> get props => [id, locale];
}

class AppErrorState extends AppState {
  final String errorString;

  const AppErrorState(super.id, this.errorString);

  @override
  List<Object?> get props => [id, errorString];
}

class AppQuestionState extends AppState {
  final String questionString;
  final VoidCallback funcYes;
  final VoidCallback? funcNo;

  const AppQuestionState(
      super.id, this.questionString, this.funcYes, this.funcNo);

  @override
  List<Object?> get props => [id, questionString];
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
    if (kDebugMode) {
      print('NEW EVENT ID: $id');
    }
  }

  @override
  List<Object?> get props => [id];

  int newId() {
    return ++_counter;
  }
}

class LoadingEvent extends AppEvent {
  final bool isLoading;

  LoadingEvent(this.isLoading);
}

class Page1Event extends AppEvent {}

class BasketEvent extends AppEvent {}

class LocaleEvent extends AppEvent {
  final String locale;

  LocaleEvent(this.locale);

  @override
  List<Object?> get props => [id, locale];
}

class AppErrorEvent extends AppEvent {
  final String errorString;

  AppErrorEvent(this.errorString);
}

class AppQuestionEvent extends AppEvent {
  final String questionString;
  final VoidCallback funcYes;
  final VoidCallback? funcNo;

  AppQuestionEvent(this.questionString, this.funcYes, this.funcNo);
}

class HttpEvent extends AppEvent {
  final String route;
  final Map<String, dynamic> data;
  final Function(dynamic) onSuccess;
  HttpEvent(this.route, this.data, this.onSuccess);
}

class AppLoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  AppLoadingBloc(super.initialState) {
    on<LoadingEvent>(
        (event, emit) => emit(LoadingState(event.id, event.isLoading)));
  }
}

class HttpBloc extends Bloc<AppEvent, AppState> {
  HttpBloc(super.initialState) {
    on<HttpEvent>((event, emit) => _httpQuery(event));
  }

  void _httpQuery(HttpEvent e) async {
    BlocProvider.of<AppLoadingBloc>(tools.context()).add(LoadingEvent(true));
    try {
      final response = await HttpDio().post(e.route, inData: e.data);
      e.onSuccess(response).then((_) {
        BlocProvider.of<AppLoadingBloc>(tools.context()).add(LoadingEvent(false));
      });
    } catch (ex) {
      BlocProvider.of<AppLoadingBloc>(tools.context()).add(LoadingEvent(false));
      BlocProvider.of<AppErrorBloc>(tools.context())
          .add(AppErrorEvent(ex.toString()));
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
    on<LocaleEvent>((event, emit) => emit(LocaleState(event.id, event.locale)));
  }
}

class AppErrorBloc extends Bloc<AppErrorEvent, AppErrorState> {
  AppErrorBloc(super.initialState) {
    on<AppErrorEvent>(
        (event, emit) => emit(AppErrorState(event.id, event.errorString)));
  }
}

class AppQuestionBloc extends Bloc<AppQuestionEvent, AppQuestionState> {
  AppQuestionBloc(super.initialState) {
    on<AppQuestionEvent>((event, emit) => emit(AppQuestionState(
        event.id, event.questionString, event.funcYes, event.funcNo)));
  }
}
