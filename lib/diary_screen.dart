// lib/diary_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:gabits/utils/quill_utils.dart';
import 'package:gabits/calendar_diary_screen.dart';
import 'package:gabits/models/diary_entry_model.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime currentDate;
  final DiaryEntry? initialEntry;
  final Function(DiaryEntry) onSave;
  final List<DiaryEntry> allDiaryEntries;
  final DiaryEntry? Function(DateTime) getDiaryEntryForDate;

  const DiaryScreen({
    super.key,
    required this.currentDate,
    this.initialEntry,
    required this.onSave,
    required this.allDiaryEntries,
    required this.getDiaryEntryForDate,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.initialEntry != null &&
        widget.initialEntry!.contentJson.isNotEmpty) {
      try {
        final List<dynamic> deltaOps =
            jsonDecode(widget.initialEntry!.contentJson);
        _quillController = quill.QuillController(
          document: quill.Document.fromJson(deltaOps),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _saveDiaryEntry() {
    final localizations = AppLocalizations.of(context)!;
    final contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    DiaryEntry entryToSave;

    if (widget.initialEntry != null) {
      entryToSave = widget.initialEntry!.copyWith(
        contentJson: contentJson,
        updatedAt: DateTime.now(),
      );
    } else {
      entryToSave = DiaryEntry.createNew(
        date: widget.currentDate,
        contentJson: contentJson,
      );
    }
    widget.onSave(entryToSave);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.diarySaved),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final String formattedDate =
        DateFormat.yMMMMd(locale.toString()).format(widget.currentDate);

    // En v11.5.0, la localización se maneja automáticamente a través del contexto.

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          localizations.diaryFor(formattedDate),
          style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.tonal(
              onPressed: _saveDiaryEntry,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              child: Text(localizations.saveButtonLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        color: theme.dividerColor.withOpacity(0.3),
                        width: 0.5)),
                child: Column(
                  children: [
                    // CORRECCIÓN: controller como parámetro directo y QuillSimpleToolbarConfig
                    quill.QuillSimpleToolbar(
                      controller: _quillController,
                      config: quill.QuillSimpleToolbarConfig(
                        showBoldButton: true,
                        showItalicButton: true,
                        showUnderLineButton: true,
                        showStrikeThrough: true,
                        showListNumbers: true,
                        showListBullets: true,
                        showListCheck: true,
                        showCodeBlock: true,
                        showQuote: true,
                        showIndent: true,
                        showLink: true,
                        showClearFormat: true,
                        showHeaderStyle: true,
                        multiRowsDisplay: false,
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: _editorScrollController,
                        child: quill.QuillEditor.basic(
                          // CORRECCIÓN: Controladores directos en el widget
                          controller: _quillController,
                          focusNode: _editorFocusNode,
                          scrollController: _editorScrollController,
                          config: quill.QuillEditorConfig(
                            placeholder:
                                localizations.emptyDiaryEntryPlaceholder,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 10.0),
                            customStyles: QuillUtils.getDefaultStyles(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CalendarDiaryScreen(
                      allDiaryEntries: widget.allDiaryEntries,
                      getDiaryEntryForDate: widget.getDiaryEntryForDate,
                    )),
          );
        },
        label: Text(localizations.viewMyDiary),
        icon: const Icon(Icons.calendar_month_outlined),
      ),
    );
  }
}
