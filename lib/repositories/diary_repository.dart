import 'package:isar_community/isar.dart';
import 'package:gabits/models/diary_entry_model.dart';
import 'package:gabits/services/database_service.dart';
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
    return await _isar.diaryEntrys.where().findAll();
  }

  @override
  Future<void> putEntry(DiaryEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.diaryEntrys.put(entry);
    });
  }

  @override
  Future<void> deleteEntry(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.diaryEntrys.delete(id);
    });
  }
}

@riverpod
DiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  return IsarDiaryRepository(isar);
}
