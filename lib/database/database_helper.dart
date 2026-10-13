// noi khởi tạo ra database -> lưu trên thiết bị di động của người dùng
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    //kiểm tra xem database đã được khởi tạo chưa
    if (_database != null) {
      return _database!;
    }

    //nếu chưa khởi tạo thì khởi tạo database
    //lấy đường dẫn đến database trên thiết bị
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "flutter_06.db");

    // mở database từ nơi lưu lên
    _database = await openDatabase(
      path, // đường dẫn đến database
      version: 1, // phiên bản của database
      onCreate: (db, version) {}, //khởi tạo table mặc định
    );
    return _database!;
  }
}



