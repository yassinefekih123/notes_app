import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'appwrite_config.dart';

class NoteService {
  final TablesDB _db = TablesDB(getClient());

  String get _databaseId => dotenv.env['APPWRITE_DATABASE_ID']!;
  String get _tableId => dotenv.env['APPWRITE_COLLECTION_ID']!;

  // Get the notes of one user (newest first)
  Future<List<models.Row>> getNotes({required String userId}) async {
    final response = await _db.listRows(
      databaseId: _databaseId,
      tableId: _tableId,
      queries: [
        Query.equal('userId', userId),
        Query.orderDesc('createdAt'),
      ],
    );
    return response.rows;
  }

  // Create a note that only its owner can read, edit, or delete
  Future<models.Row> createNote(Map<String, dynamic> data) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final userId = data['userId'] as String;
    final owner = Role.user(userId);

    return await _db.createRow(
      databaseId: _databaseId,
      tableId: _tableId,
      rowId: ID.unique(),
      data: {...data, 'createdAt': now, 'updatedAt': now},
      permissions: [
        Permission.read(owner),
        Permission.update(owner),
        Permission.delete(owner),
      ],
    );
  }

  // Update an existing note
  Future<models.Row> updateNote(String noteId, Map<String, dynamic> data) async {
    return await _db.updateRow(
      databaseId: _databaseId,
      tableId: _tableId,
      rowId: noteId,
      data: {...data, 'updatedAt': DateTime.now().toUtc().toIso8601String()},
    );
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await _db.deleteRow(
      databaseId: _databaseId,
      tableId: _tableId,
      rowId: noteId,
    );
  }
}