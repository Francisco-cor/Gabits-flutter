import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/models/note_model.dart';
import 'package:gabits/models/diary_entry_model.dart';

class DatabaseService {
  static Isar? _isar;

  static Isar get instance {
    final db = _isar;
    if (db == null) {
      throw StateError(
        'DatabaseService has not been initialized. Call DatabaseService.init() first.',
      );
    }
    return db;
  }

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [HabitSchema, NoteSchema, DiaryEntrySchema],
      directory: dir.path,
    );
  }
}
