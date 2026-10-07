import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/note_service.dart';

class AddNoteModal extends StatefulWidget {
  final void Function(models.Row) onNoteAdded;

  const AddNoteModal({super.key, required this.onNoteAdded});

  @override
  State<AddNoteModal> createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteService = NoteService();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() => _error = 'Please fill in both title and content');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _error = 'You must be logged in to add a note');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newNote = await _noteService.createNote({
        'title': title,
        'content': content,
        'userId': user.$id,
      });

      if (!mounted) return;
      widget.onNoteAdded(newNote);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error creating note: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to save note. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: Text(_isLoading ? 'Saving...' : 'Save Note'),
        ),
      ],
    );
  }
}