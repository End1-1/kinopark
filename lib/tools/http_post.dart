import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class HttpState extends AppState {

  final int responseCode;
  var errorMessage = '';
  final dynamic data;

  HttpState(super.id, this.data, {this.responseCode = hrIdle, this.errorMessage = ''}) {
    if (kDebugMode) {
      print('ID OF STATE $this.id');
    }
  }

  @override
  List<Object?> get props => [id, responseCode, errorMessage, data];
}

class HttpEvent extends Equatable {
  static int _counter = 0;
  late final int id;
  final String route;
  final Map<String, dynamic> data;

  HttpEvent(this.route, this.data) {
    id = ++_counter;
  }

  @override
  List<Object?> get props => [];
}

class HttpBloc extends Bloc<HttpEvent, AppState> {
  HttpBloc(super.initialState) {
    on<HttpEvent>((event, emit) => _httpQuery(event));
  }

  void _httpQuery(HttpEvent e) async {
    emit(LoadingState(e.id, true));
    final dio = Dio();
    final response = await  dio.post('/engine/kinopark/${e.route}', data: e.data);
    emit(LoadingState(e.id, false));
    if (response.statusCode == 200) {
      emit(HttpState(e.id, response.data,
          responseCode: response.statusCode ?? 0,
          errorMessage: response.statusMessage ?? response.data));
    }
  }
}


