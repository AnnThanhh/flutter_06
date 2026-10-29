import 'dart:convert';

import 'package:http/http.dart' as http;
import "package:flutter_app/utils/env.dart";

class ProductServices {
  static Future<dynamic> getProducts(keyword) async {
    //xử lý url backend
    final url = Uri.parse("$DOMAIN_API/api/product?keyword=$keyword");

    try {
      //kết nối được đến backend thành công, nhận được response
      final response = await http.get(url);

      // print(response);

      if (response.statusCode == 200) {
        //chuyển đổi dữ liệu JSON thành Object
        final result = jsonDecode(response.body);
        return result["content"];
      } else {
        throw Exception("Failed to load products");
      }
    } catch (err) {
      // xử lý lỗi liên quan đến kết nối, JSON k hợp lệ
      // print(err);
      throw Exception("Failed to load products: $err");
    }
  }

  static Future<dynamic> addProduct(data) async {
    //xử lý url backend
    final url = Uri.parse("$DOMAIN_API/api/product");

    try {
      //kết nối được đến backend thành công, nhận được response
      //tham số 1: url
      //tham số 2: headers -> khai báo dữ liệu sẽ gửi đi khi request
      //tham số 3: body
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (err) {
      // xử lý lỗi liên quan đến kết nối, JSON k hợp lệ
      // print(err);
      throw Exception("Failed to load products: $err");
    }
  }

  static Future<dynamic> getProductById(id) async {
    //xử lý url backend
    final url = Uri.parse("$DOMAIN_API/api/Product/getbyid?id=$id");

    try {
      //kết nối được đến backend thành công, nhận được response
      final response = await http.get(url);

      // print(response);

      if (response.statusCode == 200) {
        //chuyển đổi dữ liệu JSON thành Object
        final result = jsonDecode(response.body);
        return result["content"];
      } else {
        throw Exception("Failed to load products");
      }
    } catch (err) {
      // xử lý lỗi liên quan đến kết nối, JSON k hợp lệ
      // print(err);
      throw Exception("Failed to load products: $err");
    }
  }
}
