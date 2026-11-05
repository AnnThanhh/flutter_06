// import 'dart:convert';

// import 'package:flutter_app/utils/env.dart';
// import 'package:http/http.dart' as http;

// class AuthServices {
//   static Future<dynamic> login(data) async {
//     //xử lý url backend
//     final url = Uri.parse("$DOMAIN_API/api/Users/signin");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(data),
//       );

//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         return result["content"];
//       } else {
//         throw Exception("Failed to login");
//       }
//     } catch (err) {
//       // xử lý lỗi liên quan đến kết nối, JSON k hợp lệ
//       // print(err);
//       throw Exception("Failed to login: $err");
//     }
//   }

//   static Future<dynamic> register(data) async {
//     //xử lý url backend
//     final url = Uri.parse("$DOMAIN_API/api/Users/signup");
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(data),
//       );

//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         return result;
//       } else {
//         throw Exception("Failed to register");
//       }
//     } catch (err) {
//       throw Exception("Failed to register: $err");
//     }
//   }

//   static Future<dynamic> getProfile(token) async {
//     final url = Uri.parse("$DOMAIN_API/api/Users/getProfile");
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json", "Authorization": "$token"},
//       );

//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         return result["content"];
//       } else {
//         throw Exception("Failed to get profile");
//       }
//     } catch (err) {
//       throw Exception("Failed to get profile: $err");
//     }
//   }
// }

import 'dart:convert';

import 'package:http/http.dart' as http;

// Android Emulator: http://10.0.2.2:3069
// iOS Simulator: http://127.0.0.1:3069
// Điện thoại thật: dùng IP LAN của máy chạy ExpressJS
const String DOMAIN_API = 'http://10.0.2.2:3069';

class AuthServices {
  static Future<dynamic> login(data) async {
    // Xử lý URL backend
    final url = Uri.parse('$DOMAIN_API/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final result = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && result['status'] == 'success') {
        // ExpressJS trả về data.accessToken
        return result['data'];
      } else {
        throw Exception(result['message'] ?? 'Failed to login');
      }
    } catch (err) {
      throw Exception('Failed to login: $err');
    }
  }

  static Future<dynamic> register(data) async {
    // Xử lý URL backend
    final url = Uri.parse('$DOMAIN_API/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final result = jsonDecode(utf8.decode(response.bodyBytes));

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          result['status'] == 'success') {
        return result['data'];
      } else {
        throw Exception(result['message'] ?? 'Failed to register');
      }
    } catch (err) {
      throw Exception('Failed to register: $err');
    }
  }

  static Future<dynamic> getProfile(token) async {
    final url = Uri.parse('$DOMAIN_API/api/auth/get-info');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final result = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && result['status'] == 'success') {
        return result['data'];
      } else {
        throw Exception(result['message'] ?? 'Failed to get profile');
      }
    } catch (err) {
      throw Exception('Failed to get profile: $err');
    }
  }
}
