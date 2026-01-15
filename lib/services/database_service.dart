import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/models/note_model.dart';
import 'package:gabits/models/diary_entry_model.dart';

late Isar isar;

class DatabaseService {
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, NoteSchema, DiaryEntrySchema],
      directory: dir.path,
    );
  }
}
