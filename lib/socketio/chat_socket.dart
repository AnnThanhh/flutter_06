import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:flutter_app/services/auth_services.dart';

class ChatSocket {
  ChatSocket({
    required this.onMessage,
    required this.onConnected,
    required this.onDisconnected,
  });

  final void Function(Map<String, dynamic> message) onMessage;
  final void Function() onConnected;
  final void Function() onDisconnected;

  io.Socket? _socket;
  String _token = '';

  final Set<int> _wanted = {}; // phòng cần có mặt
  final Set<int> _joined = {}; // phòng đã join trên socket hiện tại
  final Map<int, Future<void>> _joining = {};

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token, {int? userId}) {
    if (token.isEmpty) return;
    if (token == _token && _socket != null) {
      if (!isConnected) _socket!.connect();
      return;
    }

    dispose();
    _token = token;

    final socket = io.io(
      DOMAIN_API,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setQuery({if (userId != null) 'userId': userId})
          .setAuth({'token': ''})
          .disableAutoConnect()
          .enableForceNew()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );
    _socket = socket;

    //connect socket events
    socket.onConnect((_) {
      debugPrint('[chat-socket] connect ${socket.id}');
      // Room phía BE gắn với socket id nên mất sau mỗi lần kết nối lại
      _joined.clear();
      _joining.clear();
      onConnected();
      for (final id in _wanted.toList()) {
        join(id).catchError((Object _) {});
      }
    });

    socket.onDisconnect((reason) {
      debugPrint('[chat-socket] disconnect $reason');
      _joined.clear();
      _joining.clear();
      onDisconnected();
    });

    socket.onConnectError((e) {
      debugPrint('[chat-socket] connect_error $e');
      onDisconnected();
    });
    socket.onError((e) => debugPrint('[chat-socket] error $e'));

    socket.on('SEND_MESSAGE', (dynamic data) {
      if (data is! Map) return;
      try {
        onMessage(Map<String, dynamic>.from(data));
      } catch (_) {
        // Bỏ qua gói tin sai định dạng.
      }
    });

    socket.connect();
  }

  Future<Map<dynamic, dynamic>> _emitAck(
    String event,
    Map<String, dynamic> payload,
  ) async {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      throw Exception('Chưa kết nối realtime.');
    }

    final done = Completer<dynamic>();
    socket.emitWithAck(
      event,
      payload,
      ack: (dynamic res) {
        if (!done.isCompleted) done.complete(res);
      },
    );

    // BE không trả lời nếu token sai/hết hạn nên cần timeout
    final res = await done.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () => throw Exception('Máy chủ không phản hồi.'),
    );

    if (res is! Map || res['status'] != 'success') {
      throw Exception(
        res is Map ? '${res['message']}' : 'Phản hồi không hợp lệ.',
      );
    }
    return res['data'] is Map ? res['data'] as Map : const {};
  }

  Future<int> createRoom(List<int> userIds, {String? name}) async {
    final data = await _emitAck('CREATE_ROOM', {
      'accessToken': _token,
      'targetUserIds': userIds,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
    });

    final id = data['chatGroupId'];
    if (id is! num) throw Exception('Không nhận được chatGroupId.');

    _wanted.add(id.toInt());
    _joined.add(id.toInt());
    return id.toInt();
  }

  // Join phòng (gộp các lần gọi đồng thời, tự thử lại một lần)
  Future<void> join(int groupId) {
    _wanted.add(groupId);
    if (!isConnected) return Future.value();

    return _joining[groupId] ??= _doJoin(groupId).whenComplete(() {
      _joining.remove(groupId);
    });
  }

  Future<void> _doJoin(int groupId) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await _emitAck('JOIN_ROOM', {
          'chatGroupId': groupId,
          'accessToken': _token,
        });
        if (isConnected) _joined.add(groupId);
        return;
      } catch (_) {
        if (attempt == 1 || !isConnected) rethrow;
      }
    }
  }

  // Rời phòng như FE: emit LEAVE_ROOM, không đợi phản hồi
  void leave(int groupId) {
    _wanted.remove(groupId);
    _joined.remove(groupId);

    final socket = _socket;
    if (socket == null || !socket.connected) return;
    socket.emit('LEAVE_ROOM', {'chatGroupId': groupId});
  }

  bool isJoined(int groupId) => _joined.contains(groupId);

  // Gửi tin: trả về khi đã emit lên socket (BE không có ACK cho sự kiện này)
  Future<void> send(int groupId, String text) async {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      throw Exception('Mất kết nối realtime.');
    }

    socket.emit('SEND_MESSAGE', {
      'chatGroupId': groupId,
      'accessToken': _token,
      'message': text,
    });
  }

  void dispose() {
    final old = _socket;
    _socket = null;
    _token = '';
    _wanted.clear();
    _joined.clear();
    _joining.clear();

    old?.dispose();
  }
}
