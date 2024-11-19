import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinopark/screens/page0_base/model.dart';

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
  Page1State(super.id);

}

class BasketState extends AppState {
  BasketState(super.id);
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
}

class Page1Event extends AppEvent {

}

class BasketEvent extends AppEvent {

}

class HttpEvent extends AppEvent {
  final String route;
  final Map<String, dynamic> data;

  HttpEvent(this.route, this.data);
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(super.initialState) {
    on<HttpEvent>((event, emit) => _httpQuery(event));
  }

  void _httpQuery(HttpEvent e) async {
    emit(LoadingState(e.id, true));
    final dio = Dio();
    final response =
        await dio.post('/engine/kinopark/${e.route}', data: e.data);
    emit(LoadingState(e.id, false));
    if (response.statusCode == 200) {
      emit(HttpState(e.id, response.data,
          responseCode: response.statusCode ?? 0,
          errorMessage: response.statusMessage ?? response.data));
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