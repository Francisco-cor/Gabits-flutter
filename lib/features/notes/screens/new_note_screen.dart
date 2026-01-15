// lib/new_note_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:gabits/models/note_model.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:gabits/utils/quill_utils.dart';

class NewNoteScreen extends StatefulWidget {
  final Note? noteToEdit;

  const NewNoteScreen({super.key, this.noteToEdit});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = quill.QuillController.basic();

    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!.title;
      try {
        if (widget.noteToEdit!.contentJson.isNotEmpty) {
          final List<dynamic> deltaOps =
              jsonDecode(widget.noteToEdit!.contentJson);
          _quillController = quill.QuillController(
            document: quill.Document.fromJson(deltaOps),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } catch (e) {
        _quillController = quill.QuillController.basic();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final localizations = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() ?? false) {
      if (_quillController.document.isEmpty()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.noteContentRequired,
                style: TextStyle(color: Theme.of(context).colorScheme.onError)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      final title = _titleController.text.trim();
      final contentJson =
          jsonEncode(_quillController.document.toDelta().toJson());

      Note noteData;

      if (widget.noteToEdit != null) {
        noteData = widget.noteToEdit!.copyWith(
          title: title,
          contentJson: contentJson,
          updatedAt: DateTime.now(),
        );
      } else {
        noteData = Note.createNew(
          title: title,
          contentJson: contentJson,
        );
      }
      Navigator.pop(context, noteData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // En v11.5.0, la localización se maneja automáticamente a través del contexto
    // o se puede configurar directamente si es necesario, pero QuillSharedConfig ya no existe.

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: appBarWidget,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            titleTextFormField,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: theme.dividerColor.withOpacity(0.3),
                          width: 0.5)),
                  child: Column(
                    children: [
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
                            controller: _quillController,
                            focusNode: _editorFocusNode,
                            scrollController: _editorScrollController,
                            config: quill.QuillEditorConfig(
                              autoFocus: false,
                              expands: true,
                              padding: const EdgeInsets.all(16),
                              placeholder: localizations.noteContentHint,
                              customStyles:
                                  QuillUtils.getDefaultStyles(context),
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
      ),
    );
  }

  AppBar get appBarWidget => AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          widget.noteToEdit == null
              ? AppLocalizations.of(context)!.newNoteTitle
              : AppLocalizations.of(context)!.editButtonLabel,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.tonal(
              onPressed: _saveNote,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEEEEEE),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              child: Text(AppLocalizations.of(context)!.saveButtonLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      );

  Widget get titleTextFormField => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
        child: TextFormField(
          controller: _titleController,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.noteTitleHint,
            hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.7),
                fontSize: 20,
                fontWeight: FontWeight.w500),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          validator: (value) {
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
        ),
      );
}
