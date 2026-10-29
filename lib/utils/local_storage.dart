import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

//lưu dữ liệu -> lưu access token, refresh token(hạn chế)
Future<void> saveData(String key, String value) async {
  await storage.write(key: key, value: value);
}

//đọc dữ liệu -> đọc access token -> truy cập những thông tin cần thiết để xác thực người dùng, request thông tin cần thiết (profile, giỏ hàng, setting, comment,....)
Future<dynamic> readData(String key) async {
  return await storage.read(key: key);
}

//xóa dữ liệu
Future<void> deleteData(String key) async {
  await storage.delete(key: key);
}
