import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  //tạo state tương ứng cho auth
  bool _isLogin = false;
  bool _isLoading = false;
  String _accesstoken = "";

  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  String get accesstoken => _accesstoken;

  //cập nhật trạng thái
  void setLogin(String token) {
    _isLogin = true;
    _accesstoken = token;

    // thông báo cho các listener biết trạng thái đã thay đổi
    notifyListeners();
  }

  void setLogout() {
    _isLogin = false;
    _accesstoken = "";

    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
