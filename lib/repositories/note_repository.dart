import 'package:isar_community/isar.dart';
import 'package:gabits/models/note_model.dart';
import 'package:gabits/services/database_service.dart';
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
    return await _isar.notes.where().sortByCreatedAtDesc().findAll();
  }

  @override
  Future<void> putNote(Note note) async {
    await _isar.writeTxn(() async {
      await _isar.notes.put(note);
    });
  }

  @override
  Future<void> deleteNote(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.notes.delete(id);
    });
  }
}

@riverpod
NoteRepository noteRepository(NoteRepositoryRef ref) {
  return IsarNoteRepository(isar);
}
