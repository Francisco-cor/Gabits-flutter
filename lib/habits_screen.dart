// lib/habits_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:gabits/new_habit_screen.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gabits/providers/habits_provider.dart';
import 'package:isar_community/isar.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen>
    with SingleTickerProviderStateMixin {
  Id? _habitIdWithOptionsOpen;
  late AnimationController _screenEntryAnimationController;

  @override
  void initState() {
    super.initState();
    _screenEntryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _screenEntryAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _screenEntryAnimationController.dispose();
    super.dispose();
  }

  void _navigateToEditHabit(Habit habitToEdit) async {
    final Habit? updatedHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
          builder: (context) => NewHabitScreen(habitToEdit: habitToEdit)),
    );
    if (updatedHabit != null && mounted) {
      await ref.read(habitsNotifierProvider.notifier).updateHabit(updatedHabit);
      if (_habitIdWithOptionsOpen == habitToEdit.id) {
        setState(() {
          _habitIdWithOptionsOpen = null;
        });
      }
    }
  }

  void _confirmDeleteHabit(
      Habit habitToDelete, AppLocalizations localizations) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.confirmDeleteTitle),
        content: Text(localizations.confirmDeleteMessage
            .replaceAll('%s', habitToDelete.name)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: <Widget>[
          TextButton(
            child: Text(localizations.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(localizations.deleteButtonLabel),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(habitsNotifierProvider.notifier)
                  .deleteHabit(habitToDelete.id);
              if (_habitIdWithOptionsOpen == habitToDelete.id) {
                setState(() {
                  _habitIdWithOptionsOpen = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showHabitDetailsPopup(
      Habit habit, AppLocalizations localizations, ThemeData theme) {
    List<String> dayChars = habit.scheduleDays.map((dayIndex) {
      switch (dayIndex) {
        case 0:
          return localizations.sundayShort;
        case 1:
          return localizations.mondayShort;
        case 2:
          return localizations.tuesdayShort;
        case 3:
          return localizations.wednesdayShort;
        case 4:
          return localizations.thursdayShort;
        case 5:
          return localizations.fridayShort;
        case 6:
          return localizations.saturdayShort;
        default:
          return '';
      }
    }).toList();
    String scheduleString = dayChars.join(', ');
    if (habit.scheduleDays.length == 7) {
      scheduleString = localizations.everyDay;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        titlePadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Container(
              width: 10,
              height: 20,
              decoration: BoxDecoration(
                  color: habit.color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(habit.name, style: theme.dialogTheme.titleTextStyle)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                if (habit.description != null &&
                    habit.description!.isNotEmpty) ...[
                  Text(
                    habit.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                        height: 1.4),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildDetailRow(
                  theme,
                  icon: Icons.access_time_filled_rounded,
                  text: habit.startTime.format(context),
                ),
                if (scheduleString.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    theme,
                    icon: Icons.calendar_today_rounded,
                    text: scheduleString,
                  ),
                ],
                if (habit.goalType != GoalType.yesNo &&
                    habit.goalValue != null &&
                    habit.goalValue! > 0) ...[
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    theme,
                    icon: habit.goalType == GoalType.time
                        ? Icons.timer_outlined
                        : Icons.format_list_numbered_rtl_rounded,
                    text:
                        '${habit.goalType == GoalType.time ? localizations.goalTypeTime : localizations.goalTypeQuantity}: ${habit.goalValue?.toStringAsFixed(0)}${habit.goalType == GoalType.time ? " ${localizations.minutesShort}" : ""}',
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(localizations.ok),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme,
      {required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.9)),
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
        title: Text(localizations.myHabits),
      ),
      body: habitsAsync.when(
        data: (habits) {
          final sortedHabits = List<Habit>.from(habits)
            ..sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          if (sortedHabits.isEmpty) {
            return _buildEmptyState(localizations, theme)
                .animate(controller: _screenEntryAnimationController)
                .slideX(begin: -0.25, end: 0, curve: Curves.easeOutCubic)
                .fadeIn();
          }

          return _buildHabitsList(sortedHabits, localizations, theme)
              .animate(controller: _screenEntryAnimationController)
              .slideX(begin: -0.25, end: 0, curve: Curves.easeOutCubic)
              .fadeIn();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final Habit? newHabit = await Navigator.push<Habit>(
            context,
            MaterialPageRoute(builder: (context) => const NewHabitScreen()),
          );
          if (newHabit != null && mounted) {
            await ref.read(habitsNotifierProvider.notifier).addHabit(newHabit);
          }
        },
        label: Text(localizations.newHabitOption),
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
              Icons.format_list_bulleted_rounded,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.noHabitsYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.tapPlusToCreateOne,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsList(
      List<Habit> habits, AppLocalizations localizations, ThemeData theme) {
    final cardBaseBorderRadius =
        (theme.cardTheme.shape as RoundedRectangleBorder?)
                ?.borderRadius
                .resolve(Directionality.of(context)) ??
            BorderRadius.circular(16.0);

    return ListView.builder(
      padding:
          const EdgeInsets.only(top: 8.0, bottom: 80.0, left: 8.0, right: 8.0),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final bool showInlineOptions = _habitIdWithOptionsOpen == habit.id;

        String scheduleString = habit.scheduleDays.map((dayIndex) {
          switch (dayIndex) {
            case 0:
              return localizations.sundayShort;
            case 1:
              return localizations.mondayShort;
            case 2:
              return localizations.tuesdayShort;
            case 3:
              return localizations.wednesdayShort;
            case 4:
              return localizations.thursdayShort;
            case 5:
              return localizations.fridayShort;
            case 6:
              return localizations.saturdayShort;
            default:
              return '';
          }
        }).join(', ');

        if (habit.scheduleDays.length == 7) {
          scheduleString = localizations.everyDay;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(borderRadius: cardBaseBorderRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (showInlineOptions) {
                setState(() => _habitIdWithOptionsOpen = null);
              } else {
                _showHabitDetailsPopup(habit, localizations, theme);
              }
            },
            onLongPress: () {
              setState(() {
                _habitIdWithOptionsOpen = showInlineOptions ? null : habit.id;
              });
            },
            borderRadius: cardBaseBorderRadius,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                );
              },
              child: showInlineOptions
                  ? Container(
                      key: const ValueKey('actions'),
                      height: 100,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _navigateToEditHabit(habit),
                              child: Container(
                                color: theme.colorScheme.primaryContainer
                                    .withOpacity(0.4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_rounded,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(height: 4),
                                    Text(
                                      localizations.editButtonLabel,
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: 1,
                              color: theme.dividerColor.withOpacity(0.1)),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _confirmDeleteHabit(habit, localizations),
                              child: Container(
                                color: theme.colorScheme.errorContainer
                                    .withOpacity(0.4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outline_rounded,
                                        color: theme.colorScheme.error),
                                    const SizedBox(height: 4),
                                    Text(
                                      localizations.deleteButtonLabel,
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : IntrinsicHeight(
                      key: const ValueKey('info'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                              width: 10.0,
                              decoration: BoxDecoration(color: habit.color)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(habit.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 16,
                                          color: theme
                                              .colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 6),
                                      Text(habit.startTime.format(context),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant)),
                                    ],
                                  ),
                                  if (scheduleString.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined,
                                            size: 15,
                                            color: theme
                                                .colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 6),
                                        Expanded(
                                            child: Text(scheduleString,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                        color: theme.colorScheme
                                                            .onSurfaceVariant),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1)),
                                      ],
                                    ),
                                  ],
                                  if (habit.goalType != GoalType.yesNo &&
                                      habit.goalValue != null &&
                                      habit.goalValue! > 0) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                            habit.goalType == GoalType.time
                                                ? Icons.timer_outlined
                                                : Icons
                                                    .format_list_numbered_rtl_rounded,
                                            size: 16,
                                            color: theme
                                                .colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${habit.goalType == GoalType.time ? localizations.goalTypeTime : localizations.goalTypeQuantity}: ${habit.goalValue?.toStringAsFixed(0)}${habit.goalType == GoalType.time ? " ${localizations.minutesShort}" : ""}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideX(begin: 0.05, curve: Curves.easeOutCubic);
      },
    );
  }
}
