// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';
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
import 'package:gabits/providers/habits_provider.dart';
import 'package:gabits/providers/diary_provider.dart';
import 'package:isar_community/isar.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with TickerProviderStateMixin {
  Timer? _updateTimer;
  String _currentDate = '';

  OverlayEntry? _fabMenuOverlayEntry;
  final LayerLink _fabLayerLink = LayerLink();
  late AnimationController _fabIconAnimationController;
  Id? _habitIdInRewardState;
  Timer? _rewardTimer;

  @override
  void initState() {
    super.initState();
    _fabIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCurrentDate();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _updateCurrentDate();
    }
  }

  @override
  void dispose() {
    _closeFabMenu();
    _updateTimer?.cancel();
    _rewardTimer?.cancel();
    _fabIconAnimationController.dispose();
    super.dispose();
  }

  void _updateCurrentDate() {
    final locale = Localizations.localeOf(context).toString();
    final newDateString = DateFormat.yMMMMd(locale).format(DateTime.now());
    if (_currentDate != newDateString) {
      setState(() {
        _currentDate = newDateString;
      });
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

  Future<void> _toggleHabitCompleted(Habit t) async {
    final updatedHabit = t.copyWith(isCompleted: !t.isCompleted);
    await ref.read(habitsNotifierProvider.notifier).updateHabit(updatedHabit);

    if (updatedHabit.isCompleted) {
      HapticFeedback.mediumImpact();
      _rewardTimer?.cancel();
      setState(() => _habitIdInRewardState = updatedHabit.id);
      _rewardTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() => _habitIdInRewardState = null);
        }
      });
    } else {
      HapticFeedback.lightImpact();
      if (_habitIdInRewardState == t.id) {
        _rewardTimer?.cancel();
        setState(() => _habitIdInRewardState = null);
      }
    }
  }

  DiaryEntry? _getDiaryEntryForDate(DateTime date, List<DiaryEntry> entries) {
    final normalizedDate = DiaryEntry.normalizeDate(date);
    try {
      return entries.firstWhere((e) => isSameDay(e.date, normalizedDate));
    } catch (e) {
      return null;
    }
  }

  void _showFabMenu(BuildContext context, AppLocalizations localizations,
      List<DiaryEntry> diaryEntries) {
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
                  context, localizations, Theme.of(context), diaryEntries),
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

  Widget _buildFabMenuContent(
      BuildContext buildContextForNavigation,
      AppLocalizations localizations,
      ThemeData theme,
      List<DiaryEntry> diaryEntries) {
    final menuOptions = [
      {
        'icon': Icons.edit_calendar_outlined,
        'label': localizations.newDiaryEntryOption,
        'action': () {
          _closeFabMenu();
          final today = DiaryEntry.normalizeDate(DateTime.now());
          final entryForToday = _getDiaryEntryForDate(today, diaryEntries);
          Navigator.of(buildContextForNavigation).push(MaterialPageRoute(
            builder: (context) => DiaryScreen(
              currentDate: today,
              initialEntry: entryForToday,
            ),
          ));
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
            await ref.read(habitsNotifierProvider.notifier).addHabit(nH);
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
    final habitsAsync = ref.watch(habitsNotifierProvider);
    final diaryAsync = ref.watch(diaryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_getGreetingIcon(),
                color: theme.colorScheme.primary.withOpacity(0.8), size: 28),
            const SizedBox(width: 10),
            Text(_getGreeting(context),
                style: theme.appBarTheme.titleTextStyle),
          ],
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: localizations.calendarTitle,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalendarScreen()));
            },
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
                          builder: (context) => const HabitsScreen())),
                  splashColor: theme.colorScheme.secondary.withOpacity(0.1),
                  highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                  textColor: theme.colorScheme.onSurface.withOpacity(0.9),
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
                  splashColor: theme.colorScheme.secondary.withOpacity(0.1),
                  highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                  textColor: theme.colorScheme.onSurface.withOpacity(0.9),
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
                    final entries = diaryAsync.maybeWhen(
                        data: (e) => e, orElse: () => <DiaryEntry>[]);
                    final entryForToday = _getDiaryEntryForDate(today, entries);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryScreen(
                            currentDate: today,
                            initialEntry: entryForToday,
                          ),
                        ));
                  },
                  splashColor: theme.colorScheme.secondary.withOpacity(0.1),
                  highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                  textColor: theme.colorScheme.onSurface.withOpacity(0.9),
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
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
          ),
          Expanded(
            child: habitsAsync.when(
              data: (allHabits) {
                final now = DateTime.now();
                final int dayIndexForSchedule =
                    now.weekday == 7 ? 0 : now.weekday;

                final dailyRoutineHabits = allHabits.where((h) {
                  return h.scheduleDays.contains(dayIndexForSchedule);
                }).toList()
                  ..sort((a, b) {
                    final aDT =
                        DateTime(0, 0, 0, a.startTime.hour, a.startTime.minute);
                    final bDT =
                        DateTime(0, 0, 0, b.startTime.hour, b.startTime.minute);
                    int comp = aDT.compareTo(bDT);
                    return comp != 0
                        ? comp
                        : a.name.toLowerCase().compareTo(b.name.toLowerCase());
                  });

                if (dailyRoutineHabits.isEmpty) {
                  return _buildEmptyState(localizations, theme);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0)
                      .copyWith(bottom: 90.0, top: 4.0),
                  itemCount: dailyRoutineHabits.length,
                  itemBuilder: (context, index) {
                    final habit = dailyRoutineHabits[index];
                    return _buildHabitCard(habit, localizations, theme, index);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
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
              final entries = diaryAsync.maybeWhen(
                  data: (e) => e, orElse: () => <DiaryEntry>[]);
              _showFabMenu(context, loc, entries);
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

  Widget _buildEmptyState(AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.space_dashboard_outlined,
                size: 72, color: theme.colorScheme.secondary.withOpacity(0.6)),
            const SizedBox(height: 24),
            Text(
              localizations.noHabitsToday,
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
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
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 500.ms)
          .scaleXY(begin: 0.9, end: 1.0, curve: Curves.elasticOut),
    );
  }

  Widget _buildHabitCard(
      Habit habit, AppLocalizations localizations, ThemeData theme, int index) {
    final String formattedTime = habit.startTime.format(context);
    final now = DateTime.now();
    final habitDateTimeToday = DateTime(now.year, now.month, now.day,
        habit.startTime.hour, habit.startTime.minute);
    final Duration differenceToNow = habitDateTimeToday.difference(now);
    bool isPassed = differenceToNow.isNegative && !habit.isCompleted;
    final String remainingTimeText =
        _getRemainingTime(habit.startTime, localizations);
    bool startsNow = remainingTimeText == localizations.startsNowStatus &&
        !habit.isCompleted;

    Color currentCardStripeColor =
        habit.isCompleted ? Colors.grey.shade400 : habit.color;
    Color currentCardTextColor = habit.isCompleted
        ? theme.colorScheme.onSurface.withOpacity(0.55)
        : theme.colorScheme.onSurface;
    TextDecoration cardTextDecoration =
        habit.isCompleted ? TextDecoration.lineThrough : TextDecoration.none;
    Color detailIconsColor = habit.isCompleted
        ? currentCardTextColor.withOpacity(0.8)
        : (isPassed
            ? theme.colorScheme.onSurface.withOpacity(0.75)
            : theme.colorScheme.onSurfaceVariant);

    BorderRadius cardBorderRadius = BorderRadius.circular(16.0);
    final cardShape = theme.cardTheme.shape;
    if (cardShape is RoundedRectangleBorder) {
      cardBorderRadius =
          cardShape.borderRadius.resolve(Directionality.of(context));
    }

    final bool isShowingReward = _habitIdInRewardState == habit.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                  scale:
                      Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                  child: child));
        },
        child: isShowingReward
            ? Container(
                key: const ValueKey('reward'),
                color: Colors.green.shade600,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded,
                            color: Colors.white, size: 32)
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .rotate(begin: -0.2, end: 0),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('¡Excelente trabajo!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text('${habit.name} ${localizations.markedAsDone}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : IntrinsicHeight(
                key: const ValueKey('content'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 10.0,
                      decoration: BoxDecoration(
                        color: currentCardStripeColor,
                        borderRadius: BorderRadius.only(
                            topLeft: cardBorderRadius.topLeft,
                            bottomLeft: cardBorderRadius.bottomLeft),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(habit.name,
                                style: TextStyle(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w600,
                                    color: currentCardTextColor,
                                    decoration: cardTextDecoration,
                                    decorationColor:
                                        currentCardTextColor.withOpacity(0.8)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 17, color: detailIconsColor),
                                const SizedBox(width: 6),
                                Text('${localizations.today} $formattedTime',
                                    style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: currentCardTextColor
                                            .withOpacity(0.9),
                                        decoration: cardTextDecoration,
                                        decorationColor: currentCardTextColor
                                            .withOpacity(0.8))),
                                const Spacer(),
                                if (!habit.isCompleted)
                                  Text(remainingTimeText,
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: isPassed
                                              ? Colors.red.shade400
                                                  .withOpacity(0.8)
                                              : (startsNow
                                                  ? theme.colorScheme.secondary
                                                      .withOpacity(0.9)
                                                  : Colors.green.shade600))),
                              ],
                            ),
                            if (habit.goalType != GoalType.yesNo &&
                                habit.goalValue != null &&
                                habit.goalValue! > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 7.0),
                                child: Row(
                                  children: [
                                    Icon(
                                        habit.goalType == GoalType.time
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
                                          decoration: cardTextDecoration,
                                          decorationColor: currentCardTextColor
                                              .withOpacity(0.8)),
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
                                  : Icons.check_circle_outline_rounded,
                              color: habit.isCompleted
                                  ? Colors.green.shade500
                                  : theme.colorScheme.secondary
                                      .withOpacity(0.85),
                              size: 28,
                            ),
                            onPressed: () => _toggleHabitCompleted(habit),
                            splashRadius: 24.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: (index * 70).ms)
        .slideX(begin: 0.05, curve: Curves.easeOutCubic);
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
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
