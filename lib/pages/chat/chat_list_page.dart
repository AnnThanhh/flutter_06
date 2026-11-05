import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/providers/chat_provider.dart';
import 'package:flutter_app/pages/chat/chat_room_page.dart';
import 'package:flutter_app/pages/chat/chat_widgets.dart';
import 'package:flutter_app/pages/chat/new_chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChatProvider>().loadGroups();
    });
  }

  void _openRoom(int groupId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatRoomPage(groupId: groupId)),
    );
  }

  Future<void> _newChat() async {
    final groupId = await Navigator.of(
      context,
    ).push<int>(MaterialPageRoute(builder: (_) => const NewChatPage()));

    if (mounted && groupId != null) _openRoom(groupId);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tin nhắn')),
      floatingActionButton: chat.isLoggedIn
          ? FloatingActionButton(
              onPressed: _newChat,
              tooltip: 'Cuộc trò chuyện mới',
              child: const Icon(Icons.edit_square),
            )
          : null,
      body: !chat.isLoggedIn
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Vui lòng đăng nhập để chat realtime.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                ConnectionBanner(connected: chat.connected),
                Expanded(child: _content(chat)),
              ],
            ),
    );
  }

  Widget _content(ChatProvider chat) {
    final groups = chat.groups;

    if (chat.groupsLoading && groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chat.groupsError != null && groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(chat.groupsError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => chat.loadGroups(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => chat.loadGroups(refreshLast: true),
      child: groups.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 160),
                Center(
                  child: Text('Chưa có cuộc trò chuyện. Nhấn nút để bắt đầu.'),
                ),
              ],
            )
          : ListView.builder(
              itemCount: groups.length + (chat.hasMoreGroups ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == groups.length) {
                  return Center(
                    child: TextButton(
                      onPressed: chat.groupsLoading
                          ? null
                          : () => chat.loadGroups(more: true),
                      child: Text(
                        chat.groupsLoading
                            ? 'Đang tải...'
                            : 'Tải thêm cuộc trò chuyện',
                      ),
                    ),
                  );
                }

                final group = groups[index];
                final others = chat.groupOthers(group);
                final last = chat.lastMessage(group['id']);

                return ListTile(
                  leading: UserAvatar(
                    user: chat.isDirectGroup(group) && others.isNotEmpty
                        ? others.first
                        : null,
                  ),
                  title: Text(
                    chat.groupTitle(group),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    last == null
                        ? '${group['members'].length} thành viên'
                        : '${last['senderId'] == chat.myId ? 'Bạn: ' : ''}${last['text']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: last == null
                      ? null
                      : Text(
                          formatTime(last['createdAt']),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                  onTap: () => _openRoom(group['id']),
                );
              },
            ),
    );
  }
}
