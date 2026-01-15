import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/repositories/habit_repository.dart';
import 'package:isar_community/isar.dart';

part 'habits_provider.g.dart';

@riverpod
class HabitsNotifier extends _$HabitsNotifier {
  @override
  FutureOr<List<Habit>> build() async {
    return _fetchHabits();
  }

  Future<List<Habit>> _fetchHabits() async {
    final repository = ref.read(habitRepositoryProvider);
    return await repository.getAllHabits();
  }

  Future<void> addHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(habitRepositoryProvider);
      await repository.putHabit(habit);
      return _fetchHabits();
    });
  }

  Future<void> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(habitRepositoryProvider);
      await repository.putHabit(habit);
      return _fetchHabits();
    });
  }

  Future<void> deleteHabit(Id id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(habitRepositoryProvider);
      await repository.deleteHabit(id);
      return _fetchHabits();
    });
  }
}
