import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wtf_shared/shared.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.isMe});
  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    const memberColor = Color(0xFF1769E0);
    const trainerColor = Color(0xFFE50914);
    final color = isMe ? memberColor : trainerColor;
    final bgColor = isMe
        ? memberColor.withValues(alpha: 0.12)
        : trainerColor.withValues(alpha: 0.08);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: trainerColor.withValues(alpha: 0.15),
                child: const Text('A',
                    style: TextStyle(
                        color: trainerColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isMe
                        ? const Radius.circular(18)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(18),
                  ),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.text.isNotEmpty)
                      Text(message.text, style: const TextStyle(fontSize: 15)),
                    if (message.text.isNotEmpty &&
                        message.attachments.isNotEmpty)
                      const SizedBox(height: 8),
                    if (message.attachments.isNotEmpty) ...[
                      ...message.attachments.map((attachment) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _AttachmentView(
                                attachment: attachment, accentColor: color),
                          )),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _time(message.createdAt),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _StatusTick(status: message.status),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 14,
                backgroundColor: memberColor.withValues(alpha: 0.15),
                child: const Text('D',
                    style: TextStyle(
                        color: memberColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _StatusTick extends StatelessWidget {
  const _StatusTick({required this.status});
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.schedule, size: 14, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.done, size: 14, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 14, color: Color(0xFF1769E0));
    }
  }
}

class _AttachmentView extends StatelessWidget {
  const _AttachmentView({required this.attachment, required this.accentColor});

  final MessageAttachment attachment;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage) {
      return GestureDetector(
        onTap: () => _open(attachment.url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: accentColor.withValues(alpha: 0.14))),
            child: Image.network(
              attachment.url,
              width: 240,
              height: 180,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: 240,
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes == null
                          ? null
                          : progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) =>
                  _fileCard(icon: Icons.broken_image_outlined),
            ),
          ),
        ),
      );
    }
    return _fileCard(icon: Icons.insert_drive_file_outlined);
  }

  Widget _fileCard({required IconData icon}) {
    return InkWell(
      onTap: () => _open(attachment.url),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attachment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${attachment.sizeLabel} • tap to open',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
