import 'package:flutter_app/database/database_helper.dart';

DatabaseHelper databaseHelper = DatabaseHelper();

//tạo bảng users trong database
Future<void> createTableUser() async {
  //lấy thông tin database
  final db = await databaseHelper.database;

  final result = await db.rawQuery(''' 
    CREATE TABLE users (
	    id INTEGER PRIMARY KEY AUTOINCREMENT,
  	  name TEXT,
  	  age INTEGER,
  	  email TEXT
    )
  ''');

  print(result);
}

Future<void> deleteTableUser() async {
  //lấy thông tin database
  final db = await databaseHelper.database;

  final result = await db.rawQuery(''' 
    DROP TABLE users
  ''');

  print(result);
}
