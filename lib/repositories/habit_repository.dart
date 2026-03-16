import 'package:isar_community/isar.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_repository.g.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<void> putHabit(Habit habit);
  Future<void> deleteHabit(Id id);
}

class IsarHabitRepository implements HabitRepository {
  final Isar _isar;

  IsarHabitRepository(this._isar);

  @override
  Future<List<Habit>> getAllHabits() async {
    try {
      return await _isar.habits.where().findAll();
    } catch (e) {
      throw Exception('Failed to load habits: $e');
    }
  }

  @override
  Future<void> putHabit(Habit habit) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.habits.put(habit);
      });
    } catch (e) {
      throw Exception('Failed to save habit: $e');
    }
  }

  @override
  Future<void> deleteHabit(Id id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.habits.delete(id);
      });
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }
}

@Riverpod(keepAlive: true)
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return IsarHabitRepository(ref.watch(isarInstanceProvider));
}
