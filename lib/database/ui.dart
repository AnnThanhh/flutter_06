import 'package:flutter/material.dart';
import 'package:flutter_app/database/DAO/users_dao.dart';
import 'package:flutter_app/database/tables/users_table.dart';

class Ui_db extends StatelessWidget {
  const Ui_db({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database UI'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                createTableUser();
              },
              child: Text("Tạo bảng"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteTableUser();
              },
              child: Text("Xóa bảng"),
            ),
            ElevatedButton(
              onPressed: () {
                selectDataUser();
              },
              child: Text("Xem dữ liệu"),
            ),
            ElevatedButton(
              onPressed: () {
                insertDataUser();
              },
              child: Text("Thêm dữ liệu"),
            ),
          ],
        ),
      ),
    );
  }
}
