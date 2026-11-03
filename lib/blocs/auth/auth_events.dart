//định nghĩa hành động liên quan đến auth
//định nghĩa tên các sự kiện liên quan, không chứa logic xử lý
abstract class AuthEvents {}

class LoginEvent extends AuthEvents {
  //khai báo các thuộc tính (tham số) của sự kiện Login
  final String accessToken;

  LoginEvent(this.accessToken);
}

class LogoutEvent extends AuthEvents {}
