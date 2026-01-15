// lib/calendar_diary_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gabits/models/diary_entry_model.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:gabits/utils/quill_utils.dart';

class CalendarDiaryScreen extends StatefulWidget {
  final List<DiaryEntry> allDiaryEntries;
  final DiaryEntry? Function(DateTime) getDiaryEntryForDate;

  const CalendarDiaryScreen({
    super.key,
    required this.allDiaryEntries,
    required this.getDiaryEntryForDate,
  });

  @override
  State<CalendarDiaryScreen> createState() => _CalendarDiaryScreenState();
}

class _CalendarDiaryScreenState extends State<CalendarDiaryScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<DiaryEntry>> _events;
  quill.QuillController? _selectedDayContentController;

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DiaryEntry.normalizeDate(now);
    _selectedDay = _focusedDay;
    _events = _groupEntriesByDay(widget.allDiaryEntries);
    _loadContentForSelectedDay();
  }

  @override
  void dispose() {
    _selectedDayContentController?.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Map<DateTime, List<DiaryEntry>> _groupEntriesByDay(List<DiaryEntry> entries) {
    Map<DateTime, List<DiaryEntry>> data = {};
    for (var entry in entries) {
      final dayOnly = entry.date;
      if (data[dayOnly] == null) {
        data[dayOnly] = [];
      }
      data[dayOnly]!.add(entry);
    }
    return data;
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    final dayOnly = DiaryEntry.normalizeDate(day);
    return _events[dayOnly] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedSelectedDay = DiaryEntry.normalizeDate(selectedDay);
    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      setState(() {
        _selectedDay = normalizedSelectedDay;
        _focusedDay = DiaryEntry.normalizeDate(focusedDay);
        _loadContentForSelectedDay();
      });
    }
  }

  void _loadContentForSelectedDay() {
    _selectedDayContentController?.dispose();
    _selectedDayContentController = null;

    if (_selectedDay != null) {
      final DiaryEntry? entry = widget.getDiaryEntryForDate(_selectedDay!);
      if (entry != null && entry.contentJson.isNotEmpty) {
        try {
          final List<dynamic> deltaOps = jsonDecode(entry.contentJson);
          final quill.Document document = quill.Document.fromJson(deltaOps);
          _selectedDayContentController = quill.QuillController(
            document: document,
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true, // v11.5.0: El modo lectura se define aquí
          );
        } catch (e) {
          _selectedDayContentController = quill.QuillController.basic()
            ..readOnly = true;
        }
      } else {
        _selectedDayContentController = quill.QuillController.basic()
          ..readOnly = true;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bool hasContentForSelectedDay = _selectedDay != null &&
        _selectedDayContentController != null &&
        !_selectedDayContentController!.document.isEmpty();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.viewMyDiary),
      ),
      body: Column(
        children: [
          Card(
            elevation: 2.0,
            margin: const EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            clipBehavior: Clip.antiAlias,
            child: TableCalendar<DiaryEntry>(
              locale: Localizations.localeOf(context).toString(),
              firstDay: DateTime.utc(_focusedDay.year - 5, 1, 1),
              lastDay: DateTime.utc(_focusedDay.year + 5, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, DiaryEntry.normalizeDate(day)),
              calendarFormat: _calendarFormat,
              eventLoader: _getEntriesForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8)),
                weekendTextStyle: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.7)),
                selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary, shape: BoxShape.circle),
                selectedTextStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    shape: BoxShape.circle),
                todayTextStyle: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                markerSize: 6.0,
                markerMargin:
                    const EdgeInsets.symmetric(horizontal: 0.8, vertical: 4.0),
                markersAlignment: Alignment.bottomCenter,
                canMarkersOverflow: false,
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.8),
                    shape: BoxShape.circle),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonTextStyle:
                    TextStyle(color: theme.colorScheme.onPrimary, fontSize: 13),
                formatButtonDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20.0)),
                leftChevronIcon: Icon(Icons.chevron_left_rounded,
                    color: theme.colorScheme.primary, size: 28),
                rightChevronIcon: Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary, size: 28),
                titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format)
                  setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) =>
                  _focusedDay = DiaryEntry.normalizeDate(focusedDay),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Text(
              _selectedDay != null
                  ? DateFormat.yMMMMd(
                          Localizations.localeOf(context).toString())
                      .format(_selectedDay!)
                  : localizations.selectADay,
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                      color: theme.dividerColor.withOpacity(0.3), width: 0.5),
                ),
                child: hasContentForSelectedDay
                    ? Scrollbar(
                        thumbVisibility: true,
                        controller: _editorScrollController,
                        child: quill.QuillEditor.basic(
                          controller: _selectedDayContentController!,
                          focusNode: _editorFocusNode,
                          scrollController: _editorScrollController,
                          config: quill.QuillEditorConfig(
                            autoFocus: false,
                            expands: true,
                            padding: const EdgeInsets.all(12.0),
                            customStyles: QuillUtils.getDefaultStyles(context),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          localizations.noDiaryEntryForThisDay,
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
