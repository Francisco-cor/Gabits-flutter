import 'package:isar_community/isar.dart';
import 'package:gabits/models/diary_entry_model.dart';
import 'package:gabits/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diary_repository.g.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getAllEntries();
  Future<void> putEntry(DiaryEntry entry);
  Future<void> deleteEntry(Id id);
}

class IsarDiaryRepository implements DiaryRepository {
  final Isar _isar;

  IsarDiaryRepository(this._isar);

  @override
  Future<List<DiaryEntry>> getAllEntries() async {
    try {
      return await _isar.diaryEntrys.where().findAll();
    } catch (e) {
      throw Exception('Failed to load diary entries: $e');
    }
  }

  @override
  Future<void> putEntry(DiaryEntry entry) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.diaryEntrys.put(entry);
      });
    } catch (e) {
      throw Exception('Failed to save diary entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(Id id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.diaryEntrys.delete(id);
      });
    } catch (e) {
      throw Exception('Failed to delete diary entry: $e');
    }
  }
}

@Riverpod(keepAlive: true)
DiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  return IsarDiaryRepository(ref.watch(isarInstanceProvider));
}
