import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gabits/models/note_model.dart';
import 'package:gabits/repositories/note_repository.dart';
import 'package:isar_community/isar.dart';

part 'notes_provider.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  FutureOr<List<Note>> build() async {
    return _fetchNotes();
  }

  Future<List<Note>> _fetchNotes() async {
    final repository = ref.read(noteRepositoryProvider);
    return await repository.getAllNotes();
  }

  Future<void> addNote(Note note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(noteRepositoryProvider);
      await repository.putNote(note);
      return _fetchNotes();
    });
  }

  Future<void> updateNote(Note note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(noteRepositoryProvider);
      await repository.putNote(note);
      return _fetchNotes();
    });
  }

  Future<void> deleteNote(Id id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(noteRepositoryProvider);
      await repository.deleteNote(id);
      return _fetchNotes();
    });
  }
}
