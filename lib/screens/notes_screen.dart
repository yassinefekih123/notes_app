import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/note_service.dart';
import '../components/note_item.dart';
import '../components/add_note_modal.dart';
import '../components/edit_note_modal.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteService _noteService = NoteService();
  List<models.Row> _notes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Only fetch the notes that belong to the logged-in user
      final fetched = await _noteService.getNotes(userId: user.$id);
      if (!mounted) return;
      setState(() {
        _notes = fetched;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load notes. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ---------- Add ----------
  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AddNoteModal(onNoteAdded: _handleNoteAdded),
    );
  }

  void _handleNoteAdded(models.Row newNote) {
    setState(() {
      _notes = [newNote, ..._notes];
    });
  }

  // ---------- Edit ----------
  void _showEditNoteDialog(models.Row note) {
    showDialog(
      context: context,
      builder: (context) => EditNoteModal(
        note: note,
        onNoteUpdated: _handleNoteUpdated,
      ),
    );
  }

  void _handleNoteUpdated(models.Row updated) {
    setState(() {
      _notes = _notes.map((n) => n.$id == updated.$id ? updated : n).toList();
    });
  }

  // ---------- Delete ----------
  Future<void> _confirmAndDelete(models.Row note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _noteService.deleteNote(note.$id);
      if (!mounted) return;
      setState(() {
        _notes = _notes.where((n) => n.$id != note.$id).toList();
      });
    } catch (e) {
      debugPrint('Error deleting note: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete note. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetchNotes, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You don't have any notes yet.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Tap the + Add Note button to create your first note!',
              style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchNotes,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return NoteItem(
            note: note,
            onEdit: () => _showEditNoteDialog(note),
            onDelete: () => _confirmAndDelete(note),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: 100,
            color: Colors.blue,
            padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _showAddNoteDialog,
                  child: const Text('+ Add Note'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}