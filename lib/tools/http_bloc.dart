import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HttpState extends Equatable {
  static int _counter = 0;
  late final int version;
  HttpState() {
    version = ++_counter;
  }
  @override
  List<Object?> get props => [version];

}

class HttpEvent extends Equatable {
  @override
  List<Object?> get props => [];

}

class HttpBloc extends Bloc<HttpEvent, HttpState> {
  HttpBloc(super.initialState) {
    on<HttpEvent>((event, emit) => _httpPost(event));
  }

  void _httpPost(HttpEvent e) async {

  }

}