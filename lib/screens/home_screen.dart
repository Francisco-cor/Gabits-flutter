// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:isar_community/isar.dart';

import 'package:gabits/habits_screen.dart';
import 'package:gabits/notes_screen.dart';
import 'package:gabits/diary_screen.dart';
import 'package:gabits/new_habit_screen.dart';
import 'package:gabits/new_note_screen.dart';
import 'package:gabits/calendar_screen.dart';
import 'package:gabits/timer_screen.dart';

import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/models/note_model.dart';
import 'package:gabits/models/diary_entry_model.dart';
import 'package:gabits/services/database_service.dart';
import 'package:gabits/theme/app_theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<Habit> _allHabits = [];
  List<Habit> _dailyRoutineHabits = [];
  List<DiaryEntry> _allDiaryEntries = [];
  Timer? _updateTimer;
  String _currentDate = '';

  OverlayEntry? _fabMenuOverlayEntry;
  final LayerLink _fabLayerLink = LayerLink();
  late AnimationController _fabIconAnimationController;

  @override
  void initState() {
    super.initState();
    _fabIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadInitialDataFromIsar();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCurrentDateAndRoutine();
      }
    });
  }

  Future<void> _loadInitialDataFromIsar() async {
    await _loadInitialHabits();
    await _loadInitialDiaryEntries();
    if (mounted) {
      _filterAndUpdateDailyRoutine();
      setState(() {});
    }
  }

  Future<void> _loadInitialHabits() async {
    final habitsFromDb = await isar.habits.where().findAll();
    if (mounted) {
      _allHabits = habitsFromDb;
      // YA NO SE CREAN HÁBITOS POR DEFECTO
    }
  }

  Future<void> _loadInitialDiaryEntries() async {
    final entriesFromDb = await isar.diaryEntrys.where().findAll();
    if (mounted) {
      _allDiaryEntries = entriesFromDb;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _updateCurrentDateAndRoutine();
    }
  }

  @override
  void dispose() {
    _closeFabMenu();
    _updateTimer?.cancel();
    _fabIconAnimationController.dispose();
    super.dispose();
  }

  void _updateCurrentDateAndRoutine() {
    final locale = Localizations.localeOf(context).toString();
    final newDateString = DateFormat.yMMMMd(locale).format(DateTime.now());
    bool dateChanged = _currentDate != newDateString;

    final List<Habit> oldDailyRoutineHabits = List.from(_dailyRoutineHabits);

    if (dateChanged) {
      _currentDate = newDateString;
      _filterAndUpdateDailyRoutine();
    } else {
      _filterAndUpdateDailyRoutine();
    }

    if (!listEquals(oldDailyRoutineHabits, _dailyRoutineHabits)) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _getGreeting(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return localizations.goodMorning;
    if (hour < 18) return localizations.goodAfternoon;
    return localizations.goodEvening;
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 6 || hour >= 21) return Icons.nightlight_round;
    if (hour < 12) return Icons.wb_sunny_outlined;
    if (hour < 18) return Icons.filter_drama_outlined;
    return Icons.brightness_4_outlined;
  }

  String _getRemainingTime(
      TimeOfDay habitStartTime, AppLocalizations localizations) {
    final now = DateTime.now();
    final habitDateTimeToday = DateTime(now.year, now.month, now.day,
        habitStartTime.hour, habitStartTime.minute);
    final difference = habitDateTimeToday.difference(now);
    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 0)
        return localizations.passedDaysAgo(absDifference.inDays);
      if (absDifference.inHours > 0)
        return localizations.passedHoursAgo(absDifference.inHours);
      return localizations.passedStatus;
    }
    if (difference.inHours > 0)
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    if (difference.inMinutes > 0)
      return '${difference.inMinutes}m ${difference.inSeconds.remainder(60)}s';
    if (difference.inSeconds > 0) return '${difference.inSeconds}s';
    return localizations.startsNowStatus;
  }

  void _filterAndUpdateDailyRoutine() {
    final now = DateTime.now();
    final int dayIndexForSchedule = now.weekday - 1;

    _dailyRoutineHabits = _allHabits.where((h) {
      return h.scheduleDays.contains(dayIndexForSchedule);
    }).toList()
      ..sort((a, b) {
        final aDT = DateTime(0, 0, 0, a.startTime.hour, a.startTime.minute);
        final bDT = DateTime(0, 0, 0, b.startTime.hour, b.startTime.minute);
        int comp = aDT.compareTo(bDT);
        return comp != 0
            ? comp
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
  }

  Future<void> _addHabit(Habit h) async {
    await isar.writeTxn(() async {
      await isar.habits.put(h);
    });
    if (mounted) {
      await _loadInitialHabits();
      _filterAndUpdateDailyRoutine();
      setState(() {});
    }
  }

  Future<void> _updateHabit(Habit updatedHabit, Habit oldHabit) async {
    updatedHabit.id = oldHabit.id;
    await isar.writeTxn(() async {
      await isar.habits.put(updatedHabit);
    });
    if (mounted) {
      await _loadInitialHabits();
      _filterAndUpdateDailyRoutine();
      setState(() {});
    }
  }

  Future<void> _deleteHabit(Habit d) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(d.id);
    });
    if (mounted) {
      await _loadInitialHabits();
      _filterAndUpdateDailyRoutine();
      setState(() {});
    }
  }

  Future<void> _toggleHabitCompleted(Habit t) async {
    final updatedHabit = t.copyWith(isCompleted: !t.isCompleted);
    await isar.writeTxn(() async {
      await isar.habits.put(updatedHabit);
    });
    if (mounted) {
      final indexAll = _allHabits.indexWhere((h) => h.id == t.id);
      if (indexAll != -1) _allHabits[indexAll] = updatedHabit;
      _filterAndUpdateDailyRoutine();
      setState(() {});
    }
  }

  Future<void> _addOrUpdateDiaryEntry(DiaryEntry entry) async {
    await isar.writeTxn(() async {
      await isar.diaryEntrys.put(entry);
    });
    if (mounted) {
      await _loadInitialDiaryEntries();
      setState(() {});
    }
  }

  DiaryEntry? _getDiaryEntryForDate(DateTime date) {
    final normalizedDate = DiaryEntry.normalizeDate(date);
    try {
      return _allDiaryEntries
          .firstWhere((e) => isSameDay(e.date, normalizedDate));
    } catch (e) {
      return null;
    }
  }

  void _showFabMenu(BuildContext context, AppLocalizations localizations) {
    _fabIconAnimationController.forward();
    _fabMenuOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFabMenu,
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),
            CompositedTransformFollower(
              link: _fabLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(-230 + 40, -176),
              child: _buildFabMenuContent(
                  context, localizations, Theme.of(context)),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_fabMenuOverlayEntry!);
    if (mounted) setState(() {});
  }

  void _closeFabMenu() {
    if (_fabMenuOverlayEntry != null) {
      _fabIconAnimationController.reverse();
      _fabMenuOverlayEntry!.remove();
      _fabMenuOverlayEntry = null;
      if (mounted) setState(() {});
    }
  }

  Widget _buildFabMenuContent(BuildContext buildContextForNavigation,
      AppLocalizations localizations, ThemeData theme) {
    final menuOptions = [
      {
        'icon': Icons.edit_calendar_outlined,
        'label': localizations.newDiaryEntryOption,
        'action': () {
          _closeFabMenu();
          final today = DiaryEntry.normalizeDate(DateTime.now());
          final entryForToday = _getDiaryEntryForDate(today);
          Navigator.of(buildContextForNavigation)
              .push(MaterialPageRoute(
            builder: (context) => DiaryScreen(
              currentDate: today,
              initialEntry: entryForToday,
              onSave: _addOrUpdateDiaryEntry,
              allDiaryEntries: _allDiaryEntries,
              getDiaryEntryForDate: _getDiaryEntryForDate,
            ),
          ))
              .then((_) {
            if (mounted) _loadInitialDiaryEntries();
          });
        }
      },
      {
        'icon': Icons.sticky_note_2_outlined,
        'label': localizations.newNoteOption,
        'action': () async {
          _closeFabMenu();
          final dynamic returnedValue =
              await Navigator.of(buildContextForNavigation).push(
            MaterialPageRoute(builder: (innerContext) => const NewNoteScreen()),
          );
          if (returnedValue is Note) {
            final Note newNote = returnedValue;
            Navigator.of(buildContextForNavigation).push(
              MaterialPageRoute(
                  builder: (notesScreenContext) =>
                      NotesScreen(newlyAddedNote: newNote)),
            );
          }
        }
      },
      {
        'icon': Icons.add_task_rounded,
        'label': localizations.newHabitOption,
        'action': () async {
          _closeFabMenu();
          final Habit? nH = await Navigator.of(buildContextForNavigation)
              .push<Habit>(
                  MaterialPageRoute(builder: (c) => const NewHabitScreen()));
          if (nH != null) {
            await _addHabit(nH);
          }
        }
      },
    ];
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(16.0),
      color: theme.colorScheme.surface,
      child: Container(
        width: 230,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: menuOptions
              .map((o) => _buildFabMenuButton(
                  context: buildContextForNavigation,
                  icon: o['icon'] as IconData,
                  label: o['label'] as String,
                  onPressed: o['action'] as FutureOr<void> Function(),
                  theme: theme))
              .toList(),
        )
            .animate()
            .fadeIn(duration: 120.ms)
            .scaleXY(begin: 0.9, end: 1.0, curve: Curves.decelerate),
      ),
    );
  }

  Widget _buildFabMenuButton(
      {required BuildContext context,
      required IconData icon,
      required String label,
      required FutureOr<void> Function() onPressed,
      required ThemeData theme}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.0),
      splashColor: theme.colorScheme.primary.withAlpha(20),
      highlightColor: theme.colorScheme.primary.withAlpha(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 16),
            Text(label,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final Color greetingIconColor = theme.iconTheme.color?.withOpacity(0.8) ??
        AppTheme.primaryAppColor.withOpacity(0.8);
    final Color noHabitsIconColor =
        theme.colorScheme.secondary.withOpacity(0.6);
    final Color noHabitsTextColor =
        theme.colorScheme.onBackground.withOpacity(0.7);
    final Color cardStripeColorCompleted = Colors.grey.shade400;
    final Color cardTextColorCompleted =
        theme.colorScheme.onSurface.withOpacity(0.55);
    final Color remainingTimePassedColor = Colors.red.shade400.withOpacity(0.8);
    final Color remainingTimeStartsNowColor =
        theme.colorScheme.secondary.withOpacity(0.9);
    final Color checkIconCompletedColor = Colors.green.shade500;
    final Color checkIconNotCompletedColor =
        theme.colorScheme.secondary.withOpacity(0.85);
    final Color topButtonSplashColor =
        theme.colorScheme.secondary.withOpacity(0.1);
    final Color topButtonHighlightColor =
        theme.colorScheme.primary.withOpacity(0.05);
    final Color topButtonTextColor =
        theme.colorScheme.onBackground.withOpacity(0.9);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_getGreetingIcon(), color: greetingIconColor, size: 28),
            const SizedBox(width: 10),
            Text(_getGreeting(context),
                style: theme.appBarTheme.titleTextStyle),
          ],
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: localizations.calendarTitle,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CalendarScreen(allHabits: _allHabits))),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(begin: 0.2),
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: localizations.timerScreenTitle,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const TimerScreen())),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: 0.2),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildTopButton(
                  context: context,
                  icon: Icons.checklist_rtl_rounded,
                  label: localizations.myHabits,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HabitsScreen(
                                allHabits: _allHabits,
                                onUpdateHabit: _updateHabit,
                                onDeleteHabit: _deleteHabit,
                                onAddHabit: _addHabit,
                              ))).then((_) {
                    if (mounted) {
                      _loadInitialDataFromIsar();
                    }
                  }),
                  splashColor: topButtonSplashColor,
                  highlightColor: topButtonHighlightColor,
                  textColor: topButtonTextColor,
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                _buildTopButton(
                  context: context,
                  icon: Icons.lightbulb_outline_rounded,
                  label: localizations.myNotes,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotesScreen())),
                  splashColor: topButtonSplashColor,
                  highlightColor: topButtonHighlightColor,
                  textColor: topButtonTextColor,
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                _buildTopButton(
                  context: context,
                  icon: Icons.import_contacts_outlined,
                  label: localizations.diary,
                  onTap: () {
                    final today = DiaryEntry.normalizeDate(DateTime.now());
                    final entryForToday = _getDiaryEntryForDate(today);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryScreen(
                            currentDate: today,
                            initialEntry: entryForToday,
                            onSave: _addOrUpdateDiaryEntry,
                            allDiaryEntries: _allDiaryEntries,
                            getDiaryEntryForDate: _getDiaryEntryForDate,
                          ),
                        )).then((_) {
                      if (mounted) _loadInitialDiaryEntries();
                    });
                  },
                  splashColor: topButtonSplashColor,
                  highlightColor: topButtonHighlightColor,
                  textColor: topButtonTextColor,
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Text(
              _currentDate,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground.withOpacity(0.9),
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
          ),
          Expanded(
            child: _dailyRoutineHabits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.space_dashboard_outlined,
                              size: 72, color: noHabitsIconColor),
                          const SizedBox(height: 24),
                          Text(
                            localizations.noHabitsToday,
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                color: noHabitsTextColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            localizations.tapPlusToAddHabit,
                            style: TextStyle(
                                fontSize: 15,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scaleXY(
                        begin: 0.9, end: 1.0, curve: Curves.elasticOut),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0)
                        .copyWith(bottom: 90.0, top: 4.0),
                    itemCount: _dailyRoutineHabits.length,
                    itemBuilder: (context, index) {
                      final habit = _dailyRoutineHabits[index];
                      final String formattedTime =
                          habit.startTime.format(context);

                      final now = DateTime.now();
                      final habitDateTimeToday = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          habit.startTime.hour,
                          habit.startTime.minute);
                      final Duration differenceToNow =
                          habitDateTimeToday.difference(now);
                      bool isPassed =
                          differenceToNow.isNegative && !habit.isCompleted;

                      final String remainingTimeText =
                          _getRemainingTime(habit.startTime, localizations);
                      bool startsNow =
                          remainingTimeText == localizations.startsNowStatus &&
                              !habit.isCompleted;

                      Color currentCardStripeColor;
                      Color currentCardTextColor = theme.colorScheme.onSurface;
                      TextDecoration cardTextDecoration = TextDecoration.none;
                      Color detailIconsColor =
                          theme.iconTheme.color?.withOpacity(0.7) ??
                              theme.colorScheme.onSurfaceVariant;

                      if (habit.isCompleted) {
                        currentCardStripeColor = cardStripeColorCompleted;
                        currentCardTextColor = cardTextColorCompleted;
                        cardTextDecoration = TextDecoration.lineThrough;
                        detailIconsColor =
                            currentCardTextColor.withOpacity(0.8);
                      } else {
                        currentCardStripeColor = habit.color;
                        if (isPassed) {
                          detailIconsColor =
                              theme.colorScheme.onSurface.withOpacity(0.75);
                        }
                      }

                      BorderRadius cardBorderRadius =
                          BorderRadius.circular(16.0);
                      final cardShape = theme.cardTheme.shape;
                      if (cardShape is RoundedRectangleBorder) {
                        final resolvedShape = cardShape.borderRadius
                            .resolve(Directionality.of(context));
                        if (resolvedShape is BorderRadius) {
                          cardBorderRadius = resolvedShape;
                        }
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 10.0,
                                decoration: BoxDecoration(
                                  color: currentCardStripeColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: cardBorderRadius.topLeft,
                                    bottomLeft: cardBorderRadius.bottomLeft,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        habit.name,
                                        style: TextStyle(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.w600,
                                          color: currentCardTextColor,
                                          decoration: cardTextDecoration,
                                          decorationColor: currentCardTextColor
                                              .withOpacity(0.8),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.schedule_rounded,
                                              size: 17,
                                              color: detailIconsColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${localizations.today} $formattedTime',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w500,
                                              color: currentCardTextColor
                                                  .withOpacity(0.9),
                                              decoration: cardTextDecoration,
                                              decorationColor:
                                                  currentCardTextColor
                                                      .withOpacity(0.8),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (!habit.isCompleted)
                                            Text(
                                              remainingTimeText,
                                              style: TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: isPassed
                                                      ? remainingTimePassedColor
                                                      : (startsNow
                                                          ? remainingTimeStartsNowColor
                                                          : Colors
                                                              .green.shade600)),
                                            ),
                                        ],
                                      ),
                                      if (habit.goalType != GoalType.yesNo &&
                                          habit.goalValue != null &&
                                          habit.goalValue! > 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 7.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                  habit.goalType ==
                                                          GoalType.time
                                                      ? Icons.timer_outlined
                                                      : Icons
                                                          .format_list_numbered_rounded,
                                                  size: 16,
                                                  color: detailIconsColor),
                                              const SizedBox(width: 6.0),
                                              Text(
                                                '${habit.goalType == GoalType.time ? localizations.goalTypeTime : localizations.goalTypeQuantity}: ${habit.goalValue?.toStringAsFixed(0) ?? ""}${habit.goalType == GoalType.time ? " ${localizations.minutesShort}" : ""}',
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontStyle: FontStyle.italic,
                                                  color: currentCardTextColor
                                                      .withOpacity(0.8),
                                                  decoration:
                                                      cardTextDecoration,
                                                  decorationColor:
                                                      currentCardTextColor
                                                          .withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (habit.goalType == GoalType.yesNo &&
                                  (!isPassed || habit.isCompleted))
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Tooltip(
                                    message: habit.isCompleted
                                        ? localizations.done
                                        : localizations.markAsDone,
                                    child: IconButton(
                                      icon: Icon(
                                        habit.isCompleted
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                .check_circle_outline_rounded,
                                        color: habit.isCompleted
                                            ? checkIconCompletedColor
                                            : checkIconNotCompletedColor,
                                        size: 28,
                                      ),
                                      onPressed: () async {
                                        final String habitNameForSnackbar =
                                            habit.name;
                                        final bool wasCompleted =
                                            habit.isCompleted;

                                        await _toggleHabitCompleted(habit);

                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                '$habitNameForSnackbar ${!wasCompleted ? localizations.markedAsDone : localizations.markedAsNotDone}'),
                                            backgroundColor: !wasCompleted
                                                ? Colors.green.shade600
                                                : theme.colorScheme.primary,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: const EdgeInsets.fromLTRB(
                                                15, 5, 15, 10),
                                          ));
                                        }
                                      },
                                      splashRadius: 24.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 350.ms, delay: (index * 70).ms)
                          .slideX(begin: 0.05, curve: Curves.easeOutCubic);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: CompositedTransformTarget(
        link: _fabLayerLink,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_fabMenuOverlayEntry == null) {
              final loc = AppLocalizations.of(context)!;
              _showFabMenu(context, loc);
            } else {
              _closeFabMenu();
            }
          },
          label: Text(AppLocalizations.of(context)!.newButtonLabel),
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _fabIconAnimationController,
          ),
        )
            .animate()
            .slideY(
                begin: 2,
                end: 0,
                duration: 500.ms,
                delay: 800.ms,
                curve: Curves.elasticOut)
            .fadeIn(delay: 800.ms),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTopButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color splashColor,
    required Color highlightColor,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 30.0, color: theme.colorScheme.primary),
              const SizedBox(height: 10.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: textColor),
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
