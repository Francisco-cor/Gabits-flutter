import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/repositories/habit_repository.dart';
import 'package:isar_community/isar.dart';

part 'habits_provider.g.dart';

@riverpod
class HabitsNotifier extends _$HabitsNotifier {
  @override
  FutureOr<List<Habit>> build() async {
    final repository = ref.read(habitRepositoryProvider);
    return repository.getAllHabits();
  }

  Future<void> addHabit(Habit habit) async {
    final current = state.valueOrNull ?? [];
    state = await AsyncValue.guard(() async {
      await ref.read(habitRepositoryProvider).putHabit(habit);
      return [...current, habit];
    });
  }

  Future<void> updateHabit(Habit habit) async {
    final current = state.valueOrNull ?? [];
    state = await AsyncValue.guard(() async {
      await ref.read(habitRepositoryProvider).putHabit(habit);
      return current.map((h) => h.id == habit.id ? habit : h).toList();
    });
  }

  Future<void> deleteHabit(Id id) async {
    final current = state.valueOrNull ?? [];
    state = await AsyncValue.guard(() async {
      await ref.read(habitRepositoryProvider).deleteHabit(id);
      return current.where((h) => h.id != id).toList();
    });
  }
}
