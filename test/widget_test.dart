import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/providers/habits_provider.dart';
import 'package:gabits/repositories/habit_repository.dart';
import 'package:isar_community/isar.dart';

// In-memory fake that simulates Isar ID assignment.
class FakeHabitRepository implements HabitRepository {
  final List<Habit> _habits = [];
  int _nextId = 1;
  bool shouldThrow = false;

  @override
  Future<List<Habit>> getAllHabits() async => List.of(_habits);

  @override
  Future<void> putHabit(Habit habit) async {
    if (shouldThrow) throw Exception('DB error');
    if (habit.id == Isar.autoIncrement) {
      habit.id = _nextId++;
      _habits.add(habit);
    } else {
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index >= 0) {
        _habits[index] = habit;
      } else {
        _habits.add(habit);
      }
    }
  }

  @override
  Future<void> deleteHabit(Id id) async {
    _habits.removeWhere((h) => h.id == id);
  }
}

Habit _makeHabit(String name) => Habit.create(
      name: name,
      goalType: GoalType.yesNo,
      color: const Color(0xFF4FA7B3),
      scheduleDays: [1, 2, 3],
      startTime: const TimeOfDay(hour: 7, minute: 0),
    );

void main() {
  group('HabitsNotifier', () {
    late ProviderContainer container;
    late FakeHabitRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeHabitRepository();
      container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('starts with empty list', () async {
      await container.read(habitsNotifierProvider.future);
      expect(container.read(habitsNotifierProvider).valueOrNull, isEmpty);
    });

    test('addHabit appends to list without triggering loading state', () async {
      await container.read(habitsNotifierProvider.future);

      bool loadingOccurred = false;
      container.listen(habitsNotifierProvider, (_, next) {
        if (next.isLoading) loadingOccurred = true;
      });

      await container.read(habitsNotifierProvider.notifier).addHabit(_makeHabit('Morning Run'));

      final habits = container.read(habitsNotifierProvider).valueOrNull!;
      expect(habits.length, 1);
      expect(habits.first.name, 'Morning Run');
      expect(loadingOccurred, isFalse);
    });

    test('updateHabit replaces matching entry in-place', () async {
      await container.read(habitsNotifierProvider.future);
      await container.read(habitsNotifierProvider.notifier).addHabit(_makeHabit('Morning Run'));

      final original = container.read(habitsNotifierProvider).valueOrNull!.first;
      final updated = original.copyWith(isCompleted: true);
      await container.read(habitsNotifierProvider.notifier).updateHabit(updated);

      final habits = container.read(habitsNotifierProvider).valueOrNull!;
      expect(habits.length, 1);
      expect(habits.first.isCompleted, isTrue);
    });

    test('deleteHabit removes entry by id', () async {
      await container.read(habitsNotifierProvider.future);
      await container.read(habitsNotifierProvider.notifier).addHabit(_makeHabit('Morning Run'));
      await container.read(habitsNotifierProvider.notifier).addHabit(_makeHabit('Evening Walk'));

      final idToDelete = container.read(habitsNotifierProvider).valueOrNull!.first.id;
      await container.read(habitsNotifierProvider.notifier).deleteHabit(idToDelete);

      final habits = container.read(habitsNotifierProvider).valueOrNull!;
      expect(habits.length, 1);
      expect(habits.first.name, 'Evening Walk');
    });

    test('error during addHabit propagates as AsyncError', () async {
      await container.read(habitsNotifierProvider.future);

      fakeRepo.shouldThrow = true;
      await container.read(habitsNotifierProvider.notifier).addHabit(_makeHabit('Morning Run'));

      expect(container.read(habitsNotifierProvider).hasError, isTrue);
    });
  });
}
