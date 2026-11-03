//định nghĩa, quản lý trạng thái liên quan đến auth

class AuthState {
  final bool isLogin;
  final String accessToken;

  const AuthState({
    this.accessToken = "",
    this.isLogin = false,
  });

  AuthState copyWith({
    bool? isLogin,
    String? accessToken,
  }) {
    return AuthState(
      isLogin: isLogin ?? this.isLogin,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
