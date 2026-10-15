import 'package:flutter/material.dart';
import 'package:flutter_app/database/DAO/users_dao.dart';

class BaiTapDanhBa extends StatefulWidget {
  const BaiTapDanhBa({super.key});

  @override
  State<BaiTapDanhBa> createState() => _BaiTapDanhBaState();
}

class _BaiTapDanhBaState extends State<BaiTapDanhBa> {
  var listUser = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    var listUserDB = await selectDataUser();
    setState(() {
      listUser = listUserDB;
    });
  }

  void showUserModal({Map<String, dynamic>? user}) {
    // Kiểm tra xem có phải là chỉnh sửa hay không
    final isEdit = user != null;

    //tạo controller để lấy dữ liệu từ textfield
    var nameController = TextEditingController(text: user?["name"] ?? "");
    var emailController = TextEditingController(text: user?["email"] ?? "");
    var ageController = TextEditingController(
      text: user?["age"].toString() ?? "",
    );

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isEdit ? "Cập nhật" : "Thêm mới",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Họ tên",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: "Tuổi",
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  child: const Text("Lưu"),
                  onPressed: () async {
                    //trim(): dùng để loại bỏ khoảng trắng thừa ở đầu và cuối chuỗi
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final age = ageController.text.trim();

                    if (name.isEmpty || email.isEmpty || age.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Vui lòng điền đầy đủ thông tin"),
                        ),
                      );
                      return;
                    }
                    var newUser = {'name': name, 'email': email, 'age': age};

                    if (isEdit) {
                      await updateDataUser(user["id"], newUser);
                    } else {
                      await insertDataUser(newUser);
                    }

                    //load dữ liệu
                    loadData();
                    //đóng modal
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () => showUserModal(), icon: Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        itemCount: listUser.length,
        itemBuilder: (context, index) {
          final item = listUser[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: Image.network(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(item['name']!)}&background=random&bold=true',
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) =>
                    CircleAvatar(radius: 24, child: Text(item['name']![0])),
              ),
            ),
            title: Text(item['name']!),
            subtitle: Text('${item['email']} | ${item['age']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => showUserModal(user: item),
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    //nên có thêm 1 popup xác nhận trước khi xóa
                    deleteDataUser(item['id']);
                    loadData();
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
