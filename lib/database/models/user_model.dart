class User{
  // thuộc tính
  int? id;
  String? name;
  String? email;
  int? age;

  // chuyển đổi từ sql sang đối tượng User
  User.fromSql(Map<String, dynamic> sqlData) {
    id = sqlData['id'];
    name = sqlData['name'];
    email = sqlData['email'];
    age = sqlData['age'];
  }

  // chuyển đổi từ đối tượng User sang sql
  Map<String, dynamic> toSql() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
    };
  }
}