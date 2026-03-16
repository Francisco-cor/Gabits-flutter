import 'package:isar_community/isar.dart';
import 'package:gabits/models/note_model.dart';
import 'package:gabits/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_repository.g.dart';

abstract class NoteRepository {
  Future<List<Note>> getAllNotes();
  Future<void> putNote(Note note);
  Future<void> deleteNote(Id id);
}

class IsarNoteRepository implements NoteRepository {
  final Isar _isar;

  IsarNoteRepository(this._isar);

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      return await _isar.notes.where().sortByCreatedAtDesc().findAll();
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
  }

  @override
  Future<void> putNote(Note note) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.notes.put(note);
      });
    } catch (e) {
      throw Exception('Failed to save note: $e');
    }
  }

  @override
  Future<void> deleteNote(Id id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.notes.delete(id);
      });
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}

@Riverpod(keepAlive: true)
NoteRepository noteRepository(NoteRepositoryRef ref) {
  return IsarNoteRepository(ref.watch(isarInstanceProvider));
}
