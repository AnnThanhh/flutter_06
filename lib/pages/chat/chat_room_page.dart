import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/providers/chat_provider.dart';
import 'package:flutter_app/pages/chat/chat_widgets.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, required this.groupId});

  final int groupId;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final ChatProvider _chat;

  @override
  void initState() {
    super.initState();

    _chat = context.read<ChatProvider>();
    _scroll.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _chat.enterRoom(widget.groupId);
    });
  }

  @override
  void dispose() {
    _chat.leaveRoom(widget.groupId);
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  // Danh sách đảo chiều: kéo tới cuối = tin cũ nhất
  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _chat.loadOlder(widget.groupId);
    }
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    _input.clear();
    _chat.send(widget.groupId, text);
  }

  void _failedActions(Map<String, dynamic> message) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Gửi lại'),
              onTap: () {
                Navigator.pop(sheet);
                _chat.retry(widget.groupId, message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Xoá'),
              onTap: () {
                Navigator.pop(sheet);
                _chat.discard(widget.groupId, message);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final id = widget.groupId;

    final group = chat.groupById(id);
    final messages = chat.messages(id);
    final isGroupChat = (group?['members'].length ?? 0) > 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(group == null ? 'Cuộc trò chuyện' : chat.groupTitle(group)),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ lịch sử',
            icon: const Icon(Icons.refresh),
            onPressed: () => chat.loadMessages(id, refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectionBanner(connected: chat.connected),
          Expanded(child: _messageList(chat, group, messages, isGroupChat)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    tooltip: 'Gửi',
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageList(
    ChatProvider chat,
    Map<String, dynamic>? group,
    List<Map<String, dynamic>> messages,
    bool isGroupChat,
  ) {
    final id = widget.groupId;

    if (!chat.roomLoaded(id) && messages.isEmpty) {
      final error = chat.roomError(id);

      if (error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => chat.loadMessages(id, refresh: true),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      }

      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return const Center(child: Text('Chưa có tin nhắn. Hãy gửi lời chào!'));
    }

    final hasOlder = chat.hasOlder(id);

    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length + (hasOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final message = messages[messages.length - 1 - index];
        final mine = message['senderId'] == chat.myId;

        return MessageBubble(
          key: ValueKey(
            message['localId'] ?? message['id'] ?? message.hashCode,
          ),
          message: message,
          mine: mine,
          senderName: !mine && isGroupChat && group != null
              ? chat.senderName(group, message['senderId'])
              : null,
          onTapFailed: () => _failedActions(message),
        );
      },
    );
  }
}
