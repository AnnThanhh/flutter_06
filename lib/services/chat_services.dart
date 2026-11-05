import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_app/services/auth_services.dart';

class ChatServices {
  static Future<dynamic> getGroups(
    String token, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final url = Uri.parse(
      '$DOMAIN_API/api/chat-group',
    ).replace(queryParameters: {'page': '$page', 'pageSize': '$pageSize'});
    return _get(url, token);
  }

  // Tin nhắn mới nhất ở trang 1 (BE sắp xếp giảm dần theo createdAt).
  static Future<dynamic> getMessages(
    String token,
    int groupId, {
    int page = 1,
    int pageSize = 30,
  }) async {
    final url = Uri.parse('$DOMAIN_API/api/chat-message').replace(
      queryParameters: {
        'page': '$page',
        'pageSize': '$pageSize',
        'filters': jsonEncode({'chatGroupId': groupId}),
      },
    );
    final data = await _get(url, token);
    data['totalPages'] = (data['totalPages'] as num?)?.toInt() ?? page;
    return data;
  }

  static Future<dynamic> _get(Uri url, String token) async {
    final response = await http
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    final result = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200 ||
        result is! Map ||
        result['status'] != 'success') {
      throw Exception(
        result is Map
            ? result['message'] ?? 'Lỗi ${response.statusCode}'
            : 'Lỗi',
      );
    }

    final data = result['data'];
    if (data is! Map || data['items'] is! List) {
      throw Exception('Backend không trả về data.items.');
    }
    return Map<String, dynamic>.from(data);
  }
}
