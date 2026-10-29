import 'dart:convert';

import 'package:flutter_app/utils/env.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<dynamic> login(data) async {
    //xử lý url backend
    final url = Uri.parse("$DOMAIN_API/api/Users/signin");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result["content"];
      } else {
        throw Exception("Failed to login");
      }
    } catch (err) {
      // xử lý lỗi liên quan đến kết nối, JSON k hợp lệ
      // print(err);
      throw Exception("Failed to login: $err");
    }
  }

  static Future<dynamic> register(data) async {
    //xử lý url backend
    final url = Uri.parse("$DOMAIN_API/api/Users/signup");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception("Failed to register");
      }
    } catch (err) {
      throw Exception("Failed to register: $err");
    }
  }

  static Future<dynamic> getProfile(token) async {
    final url = Uri.parse("$DOMAIN_API/api/Users/getProfile");
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "$token"},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result["content"];
      } else {
        throw Exception("Failed to get profile");
      }
    } catch (err) {
      throw Exception("Failed to get profile: $err");
    }
  }
}
