import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/services/database_service.dart';
import 'package:isar_community/isar.dart';

part 'habits_provider.g.dart';

@riverpod
class HabitsNotifier extends _$HabitsNotifier {
  @override
  FutureOr<List<Habit>> build() async {
    return _fetchHabits();
  }

  Future<List<Habit>> _fetchHabits() async {
    return await isar.habits.where().findAll();
  }

  Future<void> addHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        await isar.habits.put(habit);
      });
      return _fetchHabits();
    });
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        await isar.habits.put(updatedHabit);
      });
      return _fetchHabits();
    });
  }

  Future<void> deleteHabit(Id id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        await isar.habits.delete(id);
      });
      return _fetchHabits();
    });
  }
}
