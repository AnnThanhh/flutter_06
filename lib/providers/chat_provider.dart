import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:flutter_app/socketio/chat_socket.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/services/auth_services.dart';
import 'package:flutter_app/services/chat_services.dart';
import 'package:flutter_app/services/user_services.dart';

class ChatProvider extends ChangeNotifier with WidgetsBindingObserver {
  ChatProvider(this._auth) {
    _socket = ChatSocket(
      onMessage: _onSocketMessage,
      onConnected: _onSocketConnected,
      onDisconnected: _onSocketDisconnected,
    );

    WidgetsBinding.instance.addObserver(this);
    _auth.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  static const _groupPageSize = 50;
  static const _syncInterval = Duration(seconds: 10);
  static const _echoTimeout = Duration(seconds: 5);

  final AuthProvider _auth;
  late final ChatSocket _socket;

  String _token = '';
  int _session = 0; // đổi mỗi lần đổi phiên đăng nhập để bỏ kết quả cũ
  Timer? _syncTimer;
  bool _disposed = false;

  int? _myId;
  bool _connected = false;

  // ---- danh sách phòng
  List<Map<String, dynamic>> _groups = [];
  final Map<int, Map<String, dynamic>> _last = {};
  bool _groupsLoading = false;
  String? _groupsError;
  bool _hasMoreGroups = true;
  int _groupPage = 0;
  bool _syncingGroups = false;

  // ---- người dùng (màn hình tạo phòng)
  List<Map<String, dynamic>> _users = [];
  bool _usersLoading = false;
  String? _usersError;
  bool _hasMoreUsers = true;
  int _userPage = 0;

  bool _creatingRoom = false;

  final Map<int, Map<String, dynamic>> _rooms = {};
  final Set<int> _active = {}; // các phòng đang mở trên màn hình

  int _localSeq = 0;

  bool get isLoggedIn => _token.isNotEmpty;

  int? get myId => _myId;
  bool get connected => _connected;
  bool get groupsLoading => _groupsLoading;
  String? get groupsError => _groupsError;
  bool get hasMoreGroups => _hasMoreGroups;
  List<Map<String, dynamic>> get users => _users;
  bool get usersLoading => _usersLoading;
  String? get usersError => _usersError;
  bool get hasMoreUsers => _hasMoreUsers;
  bool get creatingRoom => _creatingRoom;

  // Phòng sắp xếp theo tin mới nhất
  List<Map<String, dynamic>> get groups {
    final list = [..._groups];
    list.sort((a, b) {
      final ta = _last[a['id']]?['createdAt'];
      final tb = _last[b['id']]?['createdAt'];
      if (ta == null && tb == null) return b['id'].compareTo(a['id']);
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });
    return list;
  }

  Map<String, dynamic>? groupById(int id) {
    for (final g in _groups) {
      if (g['id'] == id) return g;
    }
    return null;
  }

  Map<String, dynamic>? lastMessage(int groupId) {
    final room = _rooms[groupId];
    if (room != null && room['pending'].isNotEmpty) return room['pending'].last;
    return _last[groupId];
  }

  List<Map<String, dynamic>> messages(int groupId) {
    final room = _rooms[groupId];
    if (room == null) return const [];
    return [...room['confirmed'], ...room['pending']];
  }

  bool roomLoading(int groupId) => _rooms[groupId]?['loading'] ?? false;
  bool roomLoaded(int groupId) => _rooms[groupId]?['loaded'] ?? false;
  bool hasOlder(int groupId) {
    final room = _rooms[groupId];
    return room != null && room['page'] < room['totalPages'];
  }

  String? roomError(int groupId) => _rooms[groupId]?['error'];

  Map<String, dynamic> _room(int id) => _rooms.putIfAbsent(
    id,
    () => {
      // Tin đã có trên BE, tăng dần theo thời gian.
      'confirmed': <Map<String, dynamic>>[],
      'pending': <Map<String, dynamic>>[], // tin vừa gửi, chưa được BE xác nhận
      'page': 0,
      'totalPages': 1,
      'loading': false, // đang hiện vòng quay
      'busy': false, // đang có request, kể cả làm mới ngầm
      'loaded': false,
      'error': null,
    },
  );

  List<Map<String, dynamic>> _items(dynamic data) => (data['items'] as List)
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();

  // Chuẩn hoá JSON thành Map để giữ cách hiển thị và xử lý dữ liệu hiện tại.
  Map<String, dynamic> _userData(Map<String, dynamic> data) {
    final fullName = '${data['fullName'] ?? ''}'.trim();
    final email = '${data['email'] ?? ''}';
    final avatar = '${data['avatar'] ?? ''}';
    String? avatarUrl;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      avatarUrl = avatar;
    } else if (avatar.isNotEmpty) {
      avatarUrl =
          '$DOMAIN_API/${avatar.startsWith('images/') ? avatar : 'images/$avatar'}';
    }

    return {
      'id': (data['id'] as num).toInt(),
      'name': fullName.isNotEmpty
          ? fullName
          : (email.isNotEmpty ? email : 'Người dùng #${data['id']}'),
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  Map<String, dynamic> _groupData(Map<String, dynamic> data) {
    final members = <Map<String, dynamic>>[];
    final raw = data['ChatGroupMembers'];
    if (raw is List) {
      for (final item in raw) {
        final user = item is Map ? item['Users'] : null;
        if (user is Map && user['id'] is num) {
          members.add(_userData(Map<String, dynamic>.from(user)));
        }
      }
    }

    return {
      'id': (data['id'] as num).toInt(),
      'name': '${data['name'] ?? ''}'.trim(),
      'members': members,
    };
  }

  Map<String, dynamic> _messageData(Map<String, dynamic> data) => {
    'id': (data['id'] as num?)?.toInt(),
    'localId': null,
    'groupId': (data['chatGroupId'] as num).toInt(),
    'senderId': (data['userIdSender'] as num).toInt(),
    'text': '${data['messageText'] ?? ''}',
    'createdAt':
        DateTime.tryParse('${data['createdAt'] ?? ''}')?.toLocal() ??
        DateTime.now(),
    'status': 'sent',
  };

  List<Map<String, dynamic>> groupOthers(Map<String, dynamic> group) =>
      (group['members'] as List<Map<String, dynamic>>)
          .where((member) => member['id'] != _myId)
          .toList();

  bool isDirectGroup(Map<String, dynamic> group) =>
      group['name'].isEmpty && group['members'].length <= 2;

  String groupTitle(Map<String, dynamic> group) {
    if (group['name'].isNotEmpty) return group['name'];
    final others = groupOthers(group);
    if (others.isEmpty) return 'Cuộc trò chuyện #${group['id']}';
    return others.map((user) => user['name']).join(', ');
  }

  String senderName(Map<String, dynamic> group, int senderId) {
    for (final member in group['members']) {
      if (member['id'] == senderId) return member['name'];
    }
    return 'Người dùng #$senderId';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ------------------------------------------------------------------ phiên

  // userId nằm trong payload JWT do BE ký
  int? _idFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final id = payload is Map ? (payload['userId'] ?? payload['id']) : null;
      return id is num ? id.toInt() : int.tryParse('$id');
    } catch (_) {
      return null;
    }
  }

  void _onAuthChanged() {
    final next = _auth.isLogin ? _auth.accesstoken : '';
    if (next == _token) return;

    _session++;
    _token = next;

    _syncTimer?.cancel();
    _syncTimer = null;
    _socket.dispose();

    _connected = false;
    _myId = _idFromToken(next);

    _groups = [];
    _last.clear();
    _rooms.clear();
    _active.clear();
    _groupsLoading = false;
    _groupsError = null;
    _hasMoreGroups = true;
    _groupPage = 0;
    _syncingGroups = false;

    _users = [];
    _usersLoading = false;
    _usersError = null;
    _hasMoreUsers = true;
    _userPage = 0;
    _creatingRoom = false;

    if (next.isNotEmpty) {
      _socket.connect(next, userId: _myId);
      _syncTimer = Timer.periodic(_syncInterval, (_) => _sync());
    }

    _notify();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isLoggedIn) {
      _socket.connect(
        _token,
        userId: _myId,
      ); // nối lại nếu socket đã bị hệ điều hành cắt
      _sync();
    }
  }

  // ----------------------------------------------------------------- socket

  void _onSocketConnected() {
    _connected = true;
    _notify();

    // Bù phòng mới và tin bị lỡ trong lúc mất kết nối
    _sync(refreshLast: true);
  }

  void _onSocketDisconnected() {
    if (!_connected) return;
    _connected = false;
    _notify();
  }

  void _onSocketMessage(Map<String, dynamic> data) {
    final message = _messageData(data);
    final groupId = message['groupId'];

    if (groupById(groupId) == null) {
      loadGroups(silent: true); // phòng do người khác vừa tạo
    }

    final room = _room(groupId);

    // Tin của chính mình: thay thế tin đang chờ
    if (message['senderId'] == _myId) {
      _removePending(room, message['text']);
    }

    if (room['loaded']) {
      _integrate(room, [message]);
    }

    final latest = _last[groupId];
    if (latest == null || !message['createdAt'].isBefore(latest['createdAt'])) {
      _last[groupId] = message;
    }

    _notify();
  }

  // Định kỳ + khi kết nối lại: đồng bộ phòng và các phòng đang mở
  void _sync({bool refreshLast = false}) {
    if (!isLoggedIn) return;

    if (!_socket.isConnected) _socket.connect(_token, userId: _myId);

    loadGroups(silent: true, refreshLast: refreshLast);

    for (final id in _active) {
      loadMessages(id, refresh: true);
    }
  }

  // --------------------------------------------------------------- phòng chat

  Future<void> loadGroups({
    bool more = false,
    bool silent = false,
    bool refreshLast = false,
  }) async {
    final token = _token;
    if (token.isEmpty) return;
    if (silent ? _syncingGroups : _groupsLoading) return;
    if (more && !_hasMoreGroups) return;

    final session = _session;

    if (silent) {
      _syncingGroups = true;
    } else {
      _groupsLoading = true;
      _groupsError = null;
      _notify();
    }

    try {
      final page = more ? _groupPage + 1 : 1;
      final data = await ChatServices.getGroups(
        token,
        page: page,
        pageSize: _groupPageSize,
      );
      final values = _items(data).map(_groupData).toList();
      if (session != _session) return;

      if (silent) {
        // Giữ các trang đã tải, chỉ thêm/cập nhật phòng
        final ids = values.map((g) => g['id']).toSet();
        _groups = [...values, ..._groups.where((g) => !ids.contains(g['id']))];
      } else {
        _groups = more ? [..._groups, ...values] : values;
        _groupPage = page;
        // totalPages của BE không chính xác cho danh sách phòng riêng của user.
        _hasMoreGroups = values.length == _groupPageSize;
      }

      _notify();
      await _loadLasts(
        values
            .where((g) => refreshLast || !_last.containsKey(g['id']))
            .toList(),
        session,
      );
    } catch (e) {
      if (session == _session && !silent) _groupsError = '$e';
    } finally {
      if (session == _session) {
        if (silent) {
          _syncingGroups = false;
        } else {
          _groupsLoading = false;
        }
        _notify();
      }
    }
  }

  // Lấy tin mới nhất của từng phòng để hiện xem trước và sắp xếp danh sách
  Future<void> _loadLasts(
    List<Map<String, dynamic>> groups,
    int session,
  ) async {
    final token = _token;
    if (token.isEmpty) return;

    for (var i = 0; i < groups.length; i += 6) {
      final chunk = groups.skip(i).take(6);

      await Future.wait(
        chunk.map((g) async {
          try {
            final data = await ChatServices.getMessages(
              token,
              g['id'],
              pageSize: 1,
            );
            final items = _items(data).map(_messageData).toList();
            if (session != _session || items.isEmpty) return;

            final latest = items.first;
            final current = _last[g['id']];
            if (current == null ||
                latest['createdAt'].isAfter(current['createdAt'])) {
              _last[g['id']] = latest;
            }
          } catch (_) {
            // Bỏ qua; lần đồng bộ sau sẽ thử lại.
          }
        }),
      );

      if (session != _session) return;
      _notify();
    }
  }

  Future<int> createRoom(List<int> userIds, {String? name}) async {
    if (_creatingRoom) throw StateError('Đang tạo phòng chat.');

    final session = _session;
    _creatingRoom = true;
    _notify();

    try {
      final id = await _socket.createRoom(userIds, name: name);
      if (session != _session) throw StateError('Phiên đăng nhập đã thay đổi.');

      await loadGroups(silent: true);
      return id;
    } finally {
      if (session == _session) {
        _creatingRoom = false;
        _notify();
      }
    }
  }

  Future<void> loadUsers({bool more = false}) async {
    final token = _token;
    if (token.isEmpty || _usersLoading || (more && !_hasMoreUsers)) return;

    final session = _session;
    _usersLoading = true;
    _usersError = null;
    _notify();

    try {
      final page = more ? _userPage + 1 : 1;
      final result = await UserServices.getUsers(token, page: page);
      final items = _items(result).map(_userData).toList();
      if (session != _session) return;

      _users = more ? [..._users, ...items] : items;
      _userPage = page;
      _hasMoreUsers = page < result['totalPages'];
    } catch (e) {
      if (session == _session) _usersError = '$e';
    } finally {
      if (session == _session) {
        _usersLoading = false;
        _notify();
      }
    }
  }

  // -------------------------------------------------------------- tin nhắn

  // Màn hình phòng chat gọi khi mở / đóng
  Future<void> enterRoom(int groupId) async {
    _active.add(groupId);

    // Chủ động join phòng như FE (join lại khi kết nối lại); không chờ ACK để khỏi chặn tải lịch sử
    _socket.join(groupId).catchError((Object _) {});

    await loadMessages(groupId, refresh: true);
  }

  void leaveRoom(int groupId) {
    _active.remove(groupId);
    _socket.leave(groupId);
  }

  Future<void> loadOlder(int groupId) => loadMessages(groupId, older: true);

  // refresh: tải lại trang 1 và gộp (không reset phân trang đã tải)
  Future<void> loadMessages(
    int groupId, {
    bool older = false,
    bool refresh = false,
  }) async {
    final token = _token;
    if (token.isEmpty) return;

    final room = _room(groupId);
    if (room['busy'] || (older && !(room['page'] < room['totalPages']))) return;

    final session = _session;
    final visible = !refresh || !room['loaded'];

    room['busy'] = true;
    room['loading'] = visible;
    room['error'] = null;
    if (visible) _notify();

    try {
      final page = older ? room['page'] + 1 : 1;
      final result = await ChatServices.getMessages(token, groupId, page: page);
      final items = _items(result).map(_messageData).toList();
      if (session != _session) return;

      // Tin từ REST: chỉ coi là xác nhận tin đang chờ nếu mới hơn lúc gửi
      for (final m in items) {
        if (m['senderId'] == _myId) {
          _removePending(room, m['text'], notBefore: m['createdAt']);
        }
      }

      _integrate(room, items);

      // Làm mới trang 1 không được reset phân trang đã tải
      if (older || room['page'] <= 1) {
        room['page'] = page;
        room['totalPages'] = result['totalPages'];
      }

      room['loaded'] = true;

      if (room['confirmed'].isNotEmpty) {
        final latest = room['confirmed'].last;
        final current = _last[groupId];
        if (current == null ||
            !latest['createdAt'].isBefore(current['createdAt'])) {
          _last[groupId] = latest;
        }
      }
    } catch (e) {
      if (session == _session && !room['loaded']) room['error'] = '$e';
    } finally {
      room['busy'] = false;
      if (session == _session) {
        room['loading'] = false;
        _notify();
      }
    }
  }

  // Gộp tin vào phòng: bỏ trùng, sắp xếp tăng dần theo thời gian
  void _integrate(
    Map<String, dynamic> room,
    List<Map<String, dynamic>> incoming,
  ) {
    final list = room['confirmed'] as List<Map<String, dynamic>>;

    for (final m in incoming) {
      if (m['id'] != null && list.any((e) => e['id'] == m['id'])) continue;
      list.add(m);
    }

    // BE lưu createdAt theo giây nên tin từ socket (có ms, chưa có id) lệch so với
    // bản lưu DB (có id) tối đa ~1s: ghép từng cặp rồi bỏ bản socket.
    final withId = list.where((m) => m['id'] != null).toList();
    final claimed = <Map<String, dynamic>>{};

    list.removeWhere((m) {
      if (m['id'] != null) return false;

      for (final other in withId) {
        if (claimed.contains(other)) continue;
        if (other['senderId'] == m['senderId'] &&
            other['text'] == m['text'] &&
            other['createdAt']
                    .difference(m['createdAt'])
                    .inMilliseconds
                    .abs() <=
                2000) {
          claimed.add(other);
          return true;
        }
      }
      return false;
    });

    list.sort((a, b) {
      final c = a['createdAt'].compareTo(b['createdAt']);
      if (c != 0) return c;
      return (a['id'] ?? 1 << 30).compareTo(b['id'] ?? 1 << 30);
    });
  }

  // Xoá một tin chờ có cùng nội dung (tin đã được BE xác nhận)
  void _removePending(
    Map<String, dynamic> room,
    String text, {
    DateTime? notBefore,
  }) {
    final i = room['pending'].indexWhere((p) {
      if (p['text'] != text) return false;
      if (notBefore == null) return true;
      return !notBefore.isBefore(
        p['createdAt'].subtract(const Duration(seconds: 5)),
      );
    });

    if (i != -1) room['pending'].removeAt(i);
  }

  // Gửi tin: hiện ngay, BE phát lại thì xác nhận; không thấy thì kiểm tra lại bằng REST
  Future<void> send(int groupId, String text) async {
    final value = text.trim();
    final me = _myId;
    if (value.isEmpty || me == null) return;

    final room = _room(groupId);
    final message = <String, dynamic>{
      'id': null,
      'localId': 'local-${_localSeq++}',
      'groupId': groupId,
      'senderId': me,
      'text': value,
      'createdAt': DateTime.now(),
      'status': 'sending',
    };

    room['pending'].add(message);
    _notify();

    await _dispatch(room, message);
  }

  Future<void> retry(int groupId, Map<String, dynamic> failed) async {
    final room = _room(groupId);
    if (!room['pending'].contains(failed)) return;

    failed['status'] = 'sending';
    _notify();

    await _dispatch(room, failed);
  }

  void discard(int groupId, Map<String, dynamic> failed) {
    _room(groupId)['pending'].remove(failed);
    _notify();
  }

  Future<void> _dispatch(
    Map<String, dynamic> room,
    Map<String, dynamic> message,
  ) async {
    final session = _session;

    try {
      await _socket.send(message['groupId'], message['text']);
    } catch (_) {
      if (room['pending'].contains(message)) {
        message['status'] = 'failed';
        _notify();
      }
      return;
    }

    // Đợi BE phát lại; nếu không thấy thì đối chiếu với lịch sử
    await Future<void>.delayed(_echoTimeout);
    if (session != _session || !room['pending'].contains(message)) return;

    await loadMessages(message['groupId'], refresh: true);

    if (session == _session && room['pending'].contains(message)) {
      message['status'] = 'failed';
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _auth.removeListener(_onAuthChanged);
    _syncTimer?.cancel();
    _socket.dispose();
    super.dispose();
  }
}
