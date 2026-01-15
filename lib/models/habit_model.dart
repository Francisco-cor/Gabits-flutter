// lib/models/habit_model.dart
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

part 'habit_model.g.dart';

enum GoalType { yesNo, time, quantity }

@Collection()
class Habit {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String name;

  String? description;

  @Enumerated(EnumType.ordinal)
  GoalType goalType;

  double? goalValue;

  // Campos persistidos para color y startTime
  late int colorValue;
  late int startTimeMinutes;

  @Ignore()
  Color get color => Color(colorValue);
  set color(Color c) => colorValue = c.value;

  @Ignore()
  TimeOfDay get startTime => TimeOfDay(hour: startTimeMinutes ~/ 60, minute: startTimeMinutes % 60);
  set startTime(TimeOfDay t) => startTimeMinutes = t.hour * 60 + t.minute;

  List<int> scheduleDays;
  bool isCompleted;

  // Constructor principal que Isar usará (y tú también puedes usarlo si tienes los valores "crudos")
  Habit({
    required this.name,
    this.description,
    required this.goalType,
    this.goalValue,
    required this.colorValue, // Acepta el int directamente
    required this.scheduleDays,
    required this.startTimeMinutes, // Acepta el int directamente
    this.isCompleted = false,
  }) {
    // Validaciones si es necesario
    if (goalType == GoalType.yesNo) {
      this.goalValue = null;
    }
  }

  // Constructor con nombre para conveniencia (para crear desde tu UI)
  factory Habit.create({
    required String name,
    String? description,
    required GoalType goalType,
    double? goalValue,
    required Color color, // Recibe Color
    required List<int> scheduleDays,
    required TimeOfDay startTime, // Recibe TimeOfDay
    bool isCompleted = false,
  }) {
    final habit = Habit(
      name: name,
      description: description,
      goalType: goalType,
      goalValue: goalValue,
      colorValue: color.value, // Convierte aquí
      scheduleDays: scheduleDays,
      startTimeMinutes: startTime.hour * 60 + startTime.minute, // Convierte aquí
      isCompleted: isCompleted,
    );
    // Validaciones específicas del constructor .create si son diferentes
    if (goalType != GoalType.yesNo && (goalValue == null || goalValue <= 0)) {
      // Manejar validación
    }
    if (goalType == GoalType.yesNo) {
      habit.goalValue = null;
    }
    return habit;
  }


  Habit copyWith({
    String? name,
    String? description,
    GoalType? goalType,
    double? goalValue,
    bool unsetGoalValue = false,
    Color? color, // Para conveniencia, acepta Color
    List<int>? scheduleDays,
    TimeOfDay? startTime, // Para conveniencia, acepta TimeOfDay
    bool? isCompleted,
  }) {
    // Al copiar, necesitamos asegurar que se usan los campos correctos
    final newHabit = Habit(
      name: name ?? this.name,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      goalValue: unsetGoalValue ? null : (goalValue ?? this.goalValue),
      colorValue: color?.value ?? this.colorValue, // Usa colorValue
      scheduleDays: scheduleDays ?? this.scheduleDays,
      startTimeMinutes: startTime != null ? (startTime.hour * 60 + startTime.minute) : this.startTimeMinutes, // Usa startTimeMinutes
      isCompleted: isCompleted ?? this.isCompleted,
    );
    newHabit.id = this.id;
    return newHabit;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final st = startTime;
    return 'Habit(id: $id, name: $name, startTime: ${st.hour}:${st.minute}, isCompleted: $isCompleted)';
  }
}