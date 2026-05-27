import 'package:flutter/material.dart';
import 'package:wtf_shared/shared.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.isMe});
  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    const memberColor = Color(0xFF1769E0);
    const trainerColor = Color(0xFFE50914);
    final color = isMe ? trainerColor : memberColor;
    final bgColor = isMe ? trainerColor.withValues(alpha: 0.08) : memberColor.withValues(alpha: 0.12);
    final initial = isMe ? 'A' : 'D';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: memberColor.withValues(alpha: 0.15),
              child: Text(initial, style: const TextStyle(color: memberColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(message.text, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _tick(message.status, color),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: trainerColor.withValues(alpha: 0.15),
              child: Text(initial, style: const TextStyle(color: trainerColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tick(MessageStatus status, Color color) {
    switch (status) {
      case MessageStatus.sending: return const Icon(Icons.schedule, size: 14, color: Colors.grey);
      case MessageStatus.sent: return const Icon(Icons.done, size: 14, color: Colors.grey);
      case MessageStatus.read: return Icon(Icons.done_all, size: 14, color: color);
    }
  }
}
