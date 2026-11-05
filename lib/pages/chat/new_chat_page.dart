import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/providers/chat_provider.dart';
import 'package:flutter_app/pages/chat/chat_widgets.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final Set<int> _selected = {};
  final _name = TextEditingController();
  final _search = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChatProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _create(ChatProvider chat) async {
    setState(() => _error = null);

    try {
      final id = await chat.createRoom(_selected.toList(), name: _name.text);
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final keyword = _search.text.trim().toLowerCase();

    final users = chat.users.where((u) {
      if (u['id'] == chat.myId) return false;
      return keyword.isEmpty ||
          u['name'].toLowerCase().contains(keyword) ||
          u['email'].toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cuộc trò chuyện mới')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm người dùng',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (_selected.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: TextField(
                controller: _name,
                decoration: const InputDecoration(
                  hintText: 'Tên nhóm (tuỳ chọn)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: chat.usersLoading && chat.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chat.usersError != null && chat.users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(chat.usersError!),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => chat.loadUsers(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: users.length + (chat.hasMoreUsers ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == users.length) {
                        return Center(
                          child: TextButton(
                            onPressed: chat.usersLoading
                                ? null
                                : () => chat.loadUsers(more: true),
                            child: Text(
                              chat.usersLoading ? 'Đang tải...' : 'Tải thêm',
                            ),
                          ),
                        );
                      }

                      final user = users[index];

                      return CheckboxListTile(
                        value: _selected.contains(user['id']),
                        secondary: UserAvatar(user: user),
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        onChanged: (v) => setState(() {
                          v == true
                              ? _selected.add(user['id'])
                              : _selected.remove(user['id']);
                        }),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.isEmpty || chat.creatingRoom
                      ? null
                      : () => _create(chat),
                  child: Text(
                    chat.creatingRoom
                        ? 'Đang tạo...'
                        : _selected.length > 1
                        ? 'Tạo nhóm (${_selected.length})'
                        : 'Bắt đầu chat',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
