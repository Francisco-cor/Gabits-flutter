// lib/notes_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:gabits/utils/quill_utils.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:gabits/new_note_screen.dart';
import 'package:gabits/models/note_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:isar_community/isar.dart';
import 'package:gabits/main.dart'
    show isar; // <-- IMPORTA TU INSTANCIA GLOBAL DE ISAR

class NotesScreen extends StatefulWidget {
  final Note? newlyAddedNote;

  const NotesScreen({super.key, this.newlyAddedNote});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Note> _notes = [];
  Id? _noteIdWithOptionsOpen;

  @override
  void initState() {
    super.initState();
    _loadNotesThenHandleNew();
  }

  Future<void> _loadNotesThenHandleNew() async {
    await _loadNotesFromIsar();
    if (widget.newlyAddedNote != null && mounted) {
      await _addOrUpdateNote(widget.newlyAddedNote!);
    }
  }

  Future<void> _loadNotesFromIsar() async {
    final notesFromDb =
        await isar.notes.where().sortByUpdatedAtDesc().findAll();
    if (mounted) {
      setState(() {
        _notes.clear();
        _notes.addAll(notesFromDb);
      });
    }
  }

  // _sortNotes() ya no sería necesario si la consulta de Isar ordena como quieres.
  // void _sortNotes() {
  //   _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  // }

  String _getPlainTextFromDelta(String deltaJson, {int maxLength = 80}) {
    if (deltaJson.isEmpty) return '';
    try {
      final List<dynamic> ops = jsonDecode(deltaJson);
      if (ops.isEmpty) return '';
      final quill.Document doc = quill.Document.fromJson(ops);
      String plainText = doc.toPlainText().replaceAll('\n', ' ').trim();
      return plainText.length > maxLength
          ? '${plainText.substring(0, maxLength - 3)}...'
          : plainText;
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener plain text de Delta: $e');
      return '';
    }
  }

  Future<void> _addOrUpdateNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
    if (mounted) {
      await _loadNotesFromIsar();
    }
  }

  void _navigateToNewNoteScreen({Note? noteToEdit}) async {
    final currentContext = context; // Capturar antes de await

    final Note? resultNote = await Navigator.push<Note>(
      currentContext,
      MaterialPageRoute(
        builder: (context) => NewNoteScreen(noteToEdit: noteToEdit),
      ),
    );

    if (resultNote != null && mounted) {
      await _addOrUpdateNote(resultNote);
      if (noteToEdit != null && _noteIdWithOptionsOpen == noteToEdit.id) {
        if (mounted) {
          setState(() => _noteIdWithOptionsOpen = null);
        }
      }
    }
  }

  void _confirmDeleteNote(Note noteToDelete, AppLocalizations localizations) {
    final theme = Theme.of(context); // Capturar antes de await

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.confirmDeleteTitle),
        content: Text(localizations.confirmDeleteMessage.replaceAll(
            '%s',
            noteToDelete.title.isEmpty
                ? localizations.newNoteTitle
                : noteToDelete.title)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: <Widget>[
          TextButton(
            child: Text(localizations.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: Text(localizations.deleteButtonLabel),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await isar.writeTxn(() async {
                await isar.notes.delete(noteToDelete.id);
              });
              if (mounted) {
                if (_noteIdWithOptionsOpen == noteToDelete.id) {
                  _noteIdWithOptionsOpen = null;
                }
                await _loadNotesFromIsar();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showNoteDetailsPopup(
      Note note, AppLocalizations localizations, ThemeData theme) {
    quill.QuillController? controller;
    try {
      final docJson =
          note.contentJson.isNotEmpty ? jsonDecode(note.contentJson) : null;
      final quill.Document document =
          docJson != null ? quill.Document.fromJson(docJson) : quill.Document();
      controller = quill.QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    } catch (e) {
      // ignore: avoid_print
      print("Error creando QuillController para vista previa: $e");
      controller = quill.QuillController.basic();
    }

    String formattedCreationDate =
        DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .add_Hm()
            .format(note.createdAt);
    String formattedUpdateDate =
        DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .add_Hm()
            .format(note.updatedAt);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        titlePadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        contentPadding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          note.title.isEmpty ? localizations.newNoteTitle : note.title,
          style: theme.dialogTheme.titleTextStyle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (note.title.isNotEmpty) const SizedBox(height: 8),
                quill.QuillEditor.basic(
                  controller: controller!,
                  config: quill.QuillEditorConfig(
                    autoFocus: false,
                    expands: false,
                    padding: EdgeInsets.zero,
                    customStyles: QuillUtils.getDefaultStyles(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${localizations.created}: $formattedCreationDate", // Usar clave de localización
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (note.updatedAt.difference(note.createdAt).inSeconds.abs() >
                    60)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "${localizations.updated}: $formattedUpdateDate", // Usar clave de localización
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
        actions: <Widget>[
          TextButton(
            child: Text(localizations.editButtonLabel),
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToNewNoteScreen(noteToEdit: note);
            },
          ),
          TextButton(
            child: Text(localizations.ok),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    ).whenComplete(() {
      controller?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myNotes),
      ),
      body: _notes.isEmpty
          ? _buildEmptyState(localizations, theme)
          : _buildNotesList(_notes, localizations, theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewNoteScreen(),
        label: Text(localizations.newNoteOption),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.noNotesYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.tapPlusToCreateOneNote,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scaleXY(begin: 0.95, curve: Curves.easeOutCubic), // DESCOMENTADO
    ); // DESCOMENTADO
  }

  Widget _buildNotesList(
      List<Note> notes, AppLocalizations localizations, ThemeData theme) {
    final cardBaseBorderRadius =
        (theme.cardTheme.shape as RoundedRectangleBorder?)
                ?.borderRadius
                ?.resolve(Directionality.of(context)) ??
            BorderRadius.circular(16.0);

    return ListView.builder(
      padding:
          const EdgeInsets.only(top: 8.0, bottom: 80.0, left: 8.0, right: 8.0),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final bool showInlineOptions = _noteIdWithOptionsOpen == note.id;
        final String formattedDate =
            DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                .add_jm()
                .format(note.updatedAt);
        final String contentPreview =
            _getPlainTextFromDelta(note.contentJson, maxLength: 70);
        final bool isTitleEmpty = note.title.trim().isEmpty;

        final BorderRadius cardActualBorderRadius = showInlineOptions
            ? BorderRadius.only(
                topLeft: cardBaseBorderRadius.topLeft,
                topRight: cardBaseBorderRadius.topRight,
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              )
            : cardBaseBorderRadius;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(borderRadius: cardActualBorderRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              final currentLocalizations = AppLocalizations.of(context)!;
              final currentTheme = Theme.of(context);
              if (showInlineOptions) {
                if (mounted) {
                  setState(() => _noteIdWithOptionsOpen = null);
                }
              } else {
                _showNoteDetailsPopup(note, currentLocalizations, currentTheme);
              }
            },
            onLongPress: () {
              if (mounted) {
                setState(() {
                  _noteIdWithOptionsOpen = showInlineOptions ? null : note.id;
                });
              }
            },
            borderRadius: cardBaseBorderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTitleEmpty ? localizations.newNoteTitle : note.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isTitleEmpty
                              ? theme.colorScheme.onSurface.withOpacity(0.6)
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (contentPreview.isNotEmpty || !isTitleEmpty)
                        const SizedBox(height: 6),
                      if (contentPreview.isNotEmpty)
                        Text(
                          contentPreview,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.75),
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    );
                  },
                  child: showInlineOptions
                      ? Container(
                          key: ValueKey<Id>(note.id),
                          decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.only(
                                bottomLeft: cardBaseBorderRadius.bottomLeft,
                                bottomRight: cardBaseBorderRadius.bottomRight,
                              )),
                          child: Row(
                            children: [
                              _buildInlineOptionButton(
                                theme: theme,
                                icon: Icons.edit_outlined,
                                label: localizations.editButtonLabel,
                                color: theme.colorScheme.primary,
                                onTap: () {
                                  _navigateToNewNoteScreen(noteToEdit: note);
                                },
                              ),
                              _buildInlineOptionButton(
                                theme: theme,
                                icon: Icons.delete_outline_rounded,
                                label: localizations.deleteButtonLabel,
                                color: theme.colorScheme.error,
                                onTap: () {
                                  final currentLocalizations =
                                      AppLocalizations.of(context)!;
                                  _confirmDeleteNote(
                                      note, currentLocalizations);
                                },
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(
                          key: ValueKey<String>("shrink_${note.id}")),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 40).ms)
            .slideX(begin: 0.05, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildInlineOptionButton(
      {required ThemeData theme,
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
