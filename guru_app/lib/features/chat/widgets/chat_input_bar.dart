import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wtf_shared/shared.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.chatId,
    required this.onTextChanged,
    required this.onSend,
    required this.draft,
    required this.attachments,
    required this.isSending,
    required this.onAttachmentsSelected,
    required this.onRemoveAttachment,
  });

  final String chatId;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSend;
  final String draft;
  final List<PendingAttachment> attachments;
  final bool isSending;
  final ValueChanged<List<PendingAttachment>> onAttachmentsSelected;
  final ValueChanged<int> onRemoveAttachment;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft);
  }

  @override
  void didUpdateWidget(ChatInputBar old) {
    super.didUpdateWidget(old);
    if (old.draft != widget.draft && widget.draft != _controller.text) {
      _controller.text = widget.draft;
      _controller.selection =
          TextSelection.collapsed(offset: widget.draft.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _maxAttachmentSizeBytes = 10 * 1024 * 1024;

  String _guessMimeType(String name, String? extension) {
    final ext = (extension ?? name.split('.').last).toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = <PendingAttachment>[];
    final skipped = <String>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) {
        skipped.add(file.name);
        continue;
      }
      if (file.size > _maxAttachmentSizeBytes) {
        skipped.add(file.name);
        continue;
      }
      picked.add(
        PendingAttachment(
          name: file.name,
          bytes: bytes,
          sizeBytes: file.size,
          mimeType: _guessMimeType(file.name, file.extension),
        ),
      );
    }

    if (picked.isNotEmpty) {
      widget.onAttachmentsSelected(picked);
    }
    if (skipped.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Skipped ${skipped.length} file${skipped.length == 1 ? '' : 's'} over 10 MB or without data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend =
        widget.draft.trim().isNotEmpty || widget.attachments.isNotEmpty;
    final fillColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest
        .withValues(alpha: 0.45);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.attachments.isNotEmpty) ...[
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final attachment = widget.attachments[index];
                    return _AttachmentPreview(
                      attachment: attachment,
                      onRemove: () => widget.onRemoveAttachment(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: widget.isSending ? null : _pickAttachments,
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Attach file',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    minLines: 1,
                    onChanged: widget.onTextChanged,
                    enabled: !widget.isSending,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      filled: true,
                      fillColor: fillColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  scale: canSend ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 150),
                  child: FloatingActionButton.small(
                    heroTag: 'send_${widget.chatId}',
                    onPressed: !canSend || widget.isSending
                        ? null
                        : () {
                            widget.onSend();
                            _controller.clear();
                          },
                    child: widget.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.attachment, required this.onRemove});

  final PendingAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isImage =
        attachment.mimeType?.toLowerCase().startsWith('image/') ?? false;
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
              isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
              color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(attachment.sizeLabel,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}
