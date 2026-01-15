import 'package:isar_community/isar.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/services/database_service.dart';
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
    return await _isar.habits.where().findAll();
  }

  @override
  Future<void> putHabit(Habit habit) async {
    await _isar.writeTxn(() async {
      await _isar.habits.put(habit);
    });
  }

  @override
  Future<void> deleteHabit(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.habits.delete(id);
    });
  }
}

@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return IsarHabitRepository(isar);
}
