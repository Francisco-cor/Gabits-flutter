import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gabits/models/diary_entry_model.dart';
import 'package:gabits/repositories/diary_repository.dart';
import 'package:isar_community/isar.dart';

part 'diary_provider.g.dart';

@riverpod
class DiaryNotifier extends _$DiaryNotifier {
  @override
  FutureOr<List<DiaryEntry>> build() async {
    return _fetchEntries();
  }

  Future<List<DiaryEntry>> _fetchEntries() async {
    final repository = ref.read(diaryRepositoryProvider);
    return await repository.getAllEntries();
  }

  Future<void> saveEntry(DiaryEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(diaryRepositoryProvider);
      await repository.putEntry(entry);
      return _fetchEntries();
    });
  }

  Future<void> deleteEntry(Id id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(diaryRepositoryProvider);
      await repository.deleteEntry(id);
      return _fetchEntries();
    });
  }
}
