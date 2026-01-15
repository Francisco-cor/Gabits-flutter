// lib/models/diary_entry_model.dart
import 'package:isar_community/isar.dart';

part 'diary_entry_model.g.dart';

@collection
class DiaryEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final DateTime date;

  String contentJson;

  @Index()
  DateTime createdAt; // Propiedad NO NULA

  @Index()
  DateTime updatedAt; // Propiedad NO NULA

  // Constructor que Isar usará.
  DiaryEntry({
    required this.date, // Asumimos que 'date' ya está normalizada ANTES de llamar
    required this.contentJson,
    required this.createdAt, // AHORA ES REQUERIDO Y NO NULO
    required this.updatedAt, // AHORA ES REQUERIDO Y NO NULO
  });

  // Constructor factory para conveniencia desde la UI
  factory DiaryEntry.createNew({
    required DateTime date,
    required String contentJson,
  }) {
    return DiaryEntry(
      date: normalizeDate(date), // Asegura normalización
      contentJson: contentJson,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static DateTime normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  DiaryEntry copyWith({
    DateTime? date,
    String? contentJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newEntry = DiaryEntry(
      date: date ?? this.date,
      contentJson: contentJson ?? this.contentJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    newEntry.id = this.id;
    return newEntry;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return 'DiaryEntry(id: $id, date: $formattedDate, contentJson: ${contentJson.length > 20 ? contentJson.substring(0,20) + "..." : contentJson}, updatedAt: $updatedAt)';
  }
}