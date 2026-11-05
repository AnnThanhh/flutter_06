//nhận event từ auth, xử lý và cập nhật vào state

import 'package:flutter_app/blocs/auth/auth_events.dart';
import 'package:flutter_app/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvents, AuthState> {
  // AuthBloc nhận vào initialState để khởi tạo state ban đầu
  // 1. Khởi tạo state ban đầu với initialState được truyền vào 
  // 2. mặc định là AuthState()
  AuthBloc({AuthState initialState = const AuthState()}): super(initialState){
    //on: đăng ký xử lý sự kiện
    //event: dữ liệu của sự kiện được gửi lên bloc
    //emit: cập nhật state mới cho bloc

    on<LoginEvent>((event, emit){
      emit(state.copyWith(
        isLogin: true,
        accessToken: event.accessToken,
      )); 
    });

    on<LogoutEvent>((event, emit){
      emit(const AuthState());
    });
  }
}