import 'package:flutter_app/database/database_helper.dart';

DatabaseHelper databaseHelper = DatabaseHelper();

//read
Future<dynamic> selectDataUser() async {
  //lấy thông tin database
  final db = await databaseHelper.database;

  // final result = await db.rawQuery('''
  //   SELECT * FROM users
  // ''');

  //tham số 1: tên bảng cần truy vấn dữ liệu
  final result = await db.query("users");

  return result;
}

/*
  var user = {
    "name": "John Doe",
    "age": 30,
    "email": "john@example.com"
  }
 */
//create
Future<dynamic> insertDataUser(user) async {
  //lấy thông tin database
  final db = await databaseHelper.database;

  // final result = await db.rawQuery('''
  //   INSERT INTO users (name, age, email) VALUES ('John Doe', 30, 'john@example.com')
  // ''');

  //tham số 1: tên bảng cần thêm mới dữ liệu
  //tham số 2: dữ liệu cần thêm mới dưới dạng Map<String, dynamic>
  final result = await db.insert("users", user);

  return result;
}

//delete
Future<dynamic> deleteDataUser(id) async {
  final db = await databaseHelper.database;

  //học trên lớp
  //tham số 1: tên bảng cần xóa dữ liệu
  //tham số 2: điều kiện xóa dữ liệu
  //tham số 3: giá trị của điều kiện xóa dữ liệu
  final result = await db.delete("users", where: "id = ?", whereArgs: [id]);

  //trong trường hợp có isDeleted (đi làm)
  // final result = await db.update("users", {"isDeleted": 1}, where: "id = ?", whereArgs: [id]);

  return result;
}

//update
Future<dynamic> updateDataUser(id, user) async {
  final db = await databaseHelper.database;

  //tham số 1: tên bảng cần cập nhật dữ liệu
  //tham số 2: dữ liệu cần cập nhật dưới dạng Map<String, dynamic>
  //tham số 3: điều kiện cập nhật dữ liệu
  //tham số 4: giá trị của điều kiện cập nhật dữ liệu
  final result = await db.update(
    "users",
    user,
    where: "id = ?",
    whereArgs: [id],
  );

  return result;
}
