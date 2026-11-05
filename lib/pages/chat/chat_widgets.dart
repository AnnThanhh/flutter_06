import 'package:flutter/material.dart';

String formatTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 22});

  final Map<String, dynamic>? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final u = user;
    if (u == null) {
      return CircleAvatar(radius: radius, child: const Icon(Icons.groups));
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.deepOrange.shade100,
      foregroundColor: Colors.deepOrange.shade900,
      backgroundImage: u['avatarUrl'] == null
          ? null
          : NetworkImage(u['avatarUrl']),
      onBackgroundImageError: u['avatarUrl'] == null ? null : (_, _) {},
      child: u['avatarUrl'] == null
          ? Text(
              u['name'].isEmpty ? '?' : u['name'].substring(0, 1).toUpperCase(),
            )
          : null,
    );
  }
}

// Dải báo trạng thái kết nối realtime
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key, required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    if (connected) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: const Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Expanded(child: Text('Đang kết nối lại realtime...')),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.mine,
    this.senderName,
    this.onTapFailed,
  });

  final Map<String, dynamic> message;
  final bool mine;
  // Chỉ truyền khi là phòng nhóm và không phải tin của mình.
  final String? senderName;
  final VoidCallback? onTapFailed;

  @override
  Widget build(BuildContext context) {
    final failed = message['status'] == 'failed';
    final sending = message['status'] == 'sending';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: failed ? onTapFailed : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: mine
                ? (failed ? Colors.red.shade300 : Colors.deepOrange)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Opacity(
            opacity: sending ? 0.7 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (senderName != null)
                  Text(
                    senderName!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  message['text'],
                  style: TextStyle(color: mine ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      failed
                          ? 'Gửi lỗi · chạm để thử lại'
                          : sending
                          ? 'Đang gửi...'
                          : formatTime(message['createdAt']),
                      style: TextStyle(
                        fontSize: 10,
                        color: mine ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
