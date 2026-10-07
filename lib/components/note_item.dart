import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;

class NoteItem extends StatelessWidget {
  final models.Row note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteItem({
    super.key,
    required this.note,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString).toLocal();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = note.data['title'] as String? ?? '';
    final content = note.data['content'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${_formatDate(note.$updatedAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onEdit != null || onDelete != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    TextButton(
                      onPressed: onEdit,
                      child: const Text('Edit'),
                    ),
                  if (onDelete != null)
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}