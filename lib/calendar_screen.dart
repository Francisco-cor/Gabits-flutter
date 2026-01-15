import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:gabits/providers/habits_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  Map<DateTime, List<Habit>> _groupHabitsByDay(List<Habit> habits) {
    Map<DateTime, List<Habit>> data = {};
    DateTime rangeStart = DateTime.now().subtract(const Duration(days: 365));
    DateTime rangeEnd = DateTime.now().add(const Duration(days: 365));

    for (var habit in habits) {
      for (DateTime date =
              DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
          date.isBefore(rangeEnd);
          date = date.add(const Duration(days: 1))) {
        final dayOnly = DateTime(date.year, date.month, date.day);
        final int currentWeekday = dayOnly.weekday == 7 ? 0 : dayOnly.weekday;

        if (habit.scheduleDays.contains(currentWeekday)) {
          if (data[dayOnly] == null) {
            data[dayOnly] = [];
          }
          if (!data[dayOnly]!.any((h) => h.id == habit.id)) {
            data[dayOnly]!.add(habit);
          }
        }
      }
    }

    data.forEach((date, habitList) {
      habitList.sort((a, b) {
        final aDateTime =
            DateTime(0, 0, 0, a.startTime.hour, a.startTime.minute);
        final bDateTime =
            DateTime(0, 0, 0, b.startTime.hour, b.startTime.minute);
        return aDateTime.compareTo(bDateTime);
      });
    });
    return data;
  }

  List<Habit> _getHabitsForDay(
      DateTime day, Map<DateTime, List<Habit>> events) {
    final dayOnly = DateTime(day.year, day.month, day.day);
    return events[dayOnly] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      setState(() {
        _selectedDay = normalizedSelectedDay;
        _focusedDay =
            DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
      });
    }
  }

  void _showHabitDetailsPopup(
      Habit habit, AppLocalizations localizations, ThemeData theme) {
    List<String> dayChars = habit.scheduleDays.map((dayIndex) {
      if (dayIndex == 0) return localizations.sundayShort;
      if (dayIndex == 1) return localizations.mondayShort;
      if (dayIndex == 2) return localizations.tuesdayShort;
      if (dayIndex == 3) return localizations.wednesdayShort;
      if (dayIndex == 4) return localizations.thursdayShort;
      if (dayIndex == 5) return localizations.fridayShort;
      if (dayIndex == 6) return localizations.saturdayShort;
      return '';
    }).toList();
    String scheduleString = dayChars.join(', ');
    if (habit.scheduleDays.length == 7) {
      scheduleString = localizations.everyDay;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 8.0),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(habit.name,
            style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Divider(color: habit.color, thickness: 3.5, height: 16),
                const SizedBox(height: 12),
                if (habit.description != null &&
                    habit.description!.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.description_outlined,
                    label: localizations.descriptionLabel,
                    value: habit.description!,
                    theme: theme,
                    valueStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                        height: 1.4),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildDetailRow(
                    icon: Icons.access_time_filled_rounded,
                    label: localizations.hourLabel,
                    value: habit.startTime.format(context),
                    theme: theme),
                if (scheduleString.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: localizations.scheduleLabel,
                      value: scheduleString,
                      theme: theme),
                ],
                if (habit.goalType != GoalType.yesNo &&
                    habit.goalValue != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      icon: habit.goalType == GoalType.time
                          ? Icons.timer_outlined
                          : Icons.format_list_numbered_rtl_rounded,
                      label: localizations.goalTypeLabel,
                      value:
                          '${habit.goalType == GoalType.time ? localizations.goalTypeTime : localizations.goalTypeQuantity}: ${habit.goalValue?.toStringAsFixed(0)}${habit.goalType == GoalType.time ? " ${localizations.minutesShort}" : ""}',
                      theme: theme),
                ],
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(localizations.ok.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon,
      required String label,
      required String value,
      required ThemeData theme,
      TextStyle? valueStyle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary.withOpacity(0.9)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.65)),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: valueStyle ??
                    theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.calendarTitle),
      ),
      body: habitsAsync.when(
        data: (habits) {
          final events = _groupHabitsByDay(habits);
          final selectedHabits =
              _getHabitsForDay(_selectedDay ?? _focusedDay, events);

          return Column(
            children: [
              Card(
                elevation: 2.0,
                margin: const EdgeInsets.all(12.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                clipBehavior: Clip.antiAlias,
                child: TableCalendar<Habit>(
                  locale: Localizations.localeOf(context).toString(),
                  firstDay: DateTime.utc(_focusedDay.year - 1, 1, 1),
                  lastDay: DateTime.utc(_focusedDay.year + 1, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(
                      _selectedDay, DateTime(day.year, day.month, day.day)),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getHabitsForDay(day, events),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    weekendTextStyle: TextStyle(
                        color: theme.colorScheme.primary.withOpacity(0.7)),
                    holidayTextStyle: TextStyle(color: theme.colorScheme.error),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    markerSize: 6.0,
                    markerMargin: const EdgeInsets.symmetric(
                        horizontal: 0.8, vertical: 4.0),
                    markersAlignment: Alignment.bottomCenter,
                    canMarkersOverflow: false,
                    markersMaxCount: 4,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonTextStyle: TextStyle(
                        color: theme.colorScheme.onPrimary, fontSize: 13),
                    formatButtonDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonShowsNext: false,
                    leftChevronIcon: Icon(Icons.chevron_left_rounded,
                        color: theme.colorScheme.primary, size: 28),
                    rightChevronIcon: Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.primary, size: 28),
                    titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500),
                    weekendStyle: TextStyle(
                        color: theme.colorScheme.primary.withOpacity(0.6),
                        fontWeight: FontWeight.w500),
                  ),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = DateTime(
                        focusedDay.year, focusedDay.month, focusedDay.day);
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, dayHabits) {
                      if (dayHabits.isNotEmpty) {
                        List<Widget> markers = dayHabits.take(4).map((habit) {
                          return Container(
                            width: 6.5,
                            height: 6.5,
                            margin: const EdgeInsets.symmetric(horizontal: 1.2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: habit.color.withOpacity(0.9),
                            ),
                          );
                        }).toList();

                        return Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: markers);
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDay != null
                            ? DateFormat.yMMMMd(
                                    Localizations.localeOf(context).toString())
                                .format(_selectedDay!)
                            : localizations.selectADay,
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selectedHabits.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          localizations.nHabits(selectedHabits.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: selectedHabits.isEmpty
                    ? _buildNoHabitsForSelectedDay(localizations, theme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        itemCount: selectedHabits.length,
                        itemBuilder: (context, index) {
                          final habit = selectedHabits[index];
                          return Card(
                            elevation: 1.5,
                            margin: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 4.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: InkWell(
                              onTap: () => _showHabitDetailsPopup(
                                  habit, localizations, theme),
                              borderRadius: BorderRadius.circular(12.0),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: 8.0,
                                      decoration: BoxDecoration(
                                        color: habit.color,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12.0),
                                          bottomLeft: Radius.circular(12.0),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14.0, horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              habit.name,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time_rounded,
                                                    size: 16,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant
                                                        .withOpacity(0.8)),
                                                const SizedBox(width: 6.0),
                                                Text(
                                                  habit.startTime
                                                      .format(context),
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant),
                                                ),
                                              ],
                                            ),
                                            if (habit.goalType !=
                                                    GoalType.yesNo &&
                                                habit.goalValue != null) ...[
                                              const SizedBox(height: 5.0),
                                              Row(
                                                children: [
                                                  Icon(
                                                      habit.goalType ==
                                                              GoalType.time
                                                          ? Icons.timer_outlined
                                                          : Icons
                                                              .format_list_numbered_rtl_rounded,
                                                      size: 16,
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant
                                                          .withOpacity(0.8)),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '${habit.goalType == GoalType.time ? localizations.goalTypeTime : localizations.goalTypeQuantity}: ${habit.goalValue?.toStringAsFixed(0)}${habit.goalType == GoalType.time ? " ${localizations.minutesShort}" : ""}',
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Icon(Icons.chevron_right_rounded,
                                          color: theme.colorScheme.outline),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }

  Widget _buildNoHabitsForSelectedDay(
      AppLocalizations localizations, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.noHabitsForThisDay,
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.selectAnotherDayOrAdd,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
