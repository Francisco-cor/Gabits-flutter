// lib/models/note_model.dart
import 'package:isar_community/isar.dart';

part 'note_model.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String title;

  String contentJson;

  @Index()
  DateTime createdAt; // Propiedad NO NULA

  @Index()
  DateTime updatedAt; // Propiedad NO NULA

  // Constructor que Isar usará.
  // Los parámetros DEBEN COINCIDIR con los tipos de las propiedades.
  Note({
    required this.title,
    required this.contentJson,
    required this.createdAt, // AHORA ES REQUERIDO Y NO NULO
    required this.updatedAt, // AHORA ES REQUERIDO Y NO NULO
  });

  // Constructor factory para conveniencia al crear nuevas notas desde la UI
  // donde quieres que createdAt y updatedAt se establezcan a DateTime.now()
  factory Note.createNew({
    required String title,
    required String contentJson,
  }) {
    return Note(
      title: title,
      contentJson: contentJson,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Si necesitas crear una nota donde TÚ controlas las fechas (ej. al migrar datos)
  // puedes usar el constructor por defecto directamente.

  Note copyWith({
    String? title,
    String? contentJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newNote = Note(
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    newNote.id = this.id; // Importante para mantener el ID en la copia
    return newNote;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Note(id: $id, title: "$title", updatedAt: $updatedAt)';
  }
}