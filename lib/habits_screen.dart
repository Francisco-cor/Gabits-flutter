// lib/habits_screen.dart
import 'package:flutter/material.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:gabits/new_habit_screen.dart';
import 'package:gabits/models/habit_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:isar_community/isar.dart'; // Necesario para el tipo Id

class HabitsScreen extends StatefulWidget {
  final List<Habit> allHabits; // Esta lista es la que se pasa desde main.dart
  final Future<void> Function(Habit updatedHabit, Habit oldHabit) onUpdateHabit;
  final Future<void> Function(Habit habitToDelete) onDeleteHabit;
  final Future<void> Function(Habit newHabit) onAddHabit;

  const HabitsScreen({
    super.key,
    required this.allHabits,
    required this.onUpdateHabit,
    required this.onDeleteHabit,
    required this.onAddHabit,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {
  Id? _habitIdWithOptionsOpen;
  late AnimationController _screenEntryAnimationController;

  // Lista de estado local para manejar los hábitos dentro de esta pantalla
  late List<Habit> _currentHabits;

  @override
  void initState() {
    super.initState();
    // Inicializa la lista local con una copia de los hábitos pasados
    _currentHabits = List.from(widget.allHabits);

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
      MaterialPageRoute(builder: (context) => NewHabitScreen(habitToEdit: habitToEdit)),
    );
    if (updatedHabit != null && mounted) {
      // Llama al callback de MyHomePage para actualizar en Isar y en la lista _allHabits de MyHomePage
      await widget.onUpdateHabit(updatedHabit, habitToEdit);

      // Actualiza la lista local _currentHabits en HabitsScreen
      final index = _currentHabits.indexWhere((h) => h.id == habitToEdit.id);
      if (index != -1 && mounted) {
        setState(() {
          _currentHabits[index] = updatedHabit; // Actualiza el hábito en la lista local
          if (_habitIdWithOptionsOpen == habitToEdit.id) {
            _habitIdWithOptionsOpen = null;
          }
        });
      }
    }
  }

  void _confirmDeleteHabit(Habit habitToDelete, AppLocalizations localizations) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.confirmDeleteTitle),
        content: Text(localizations.confirmDeleteMessage.replaceAll('%s', habitToDelete.name)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
              Navigator.of(ctx).pop(); // Cerrar el diálogo primero
              // Llama al callback de MyHomePage
              await widget.onDeleteHabit(habitToDelete);
              // Actualiza la lista local _currentHabits en HabitsScreen
              if (mounted) {
                setState(() {
                  _currentHabits.removeWhere((h) => h.id == habitToDelete.id);
                  if (_habitIdWithOptionsOpen == habitToDelete.id) {
                    _habitIdWithOptionsOpen = null;
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showHabitDetailsPopup(Habit habit, AppLocalizations localizations, ThemeData theme) {
    List<String> dayChars = habit.scheduleDays.map((dayIndex) {
      switch (dayIndex) {
        case 0: return localizations.sundayShort;
        case 1: return localizations.mondayShort;
        case 2: return localizations.tuesdayShort;
        case 3: return localizations.wednesdayShort;
        case 4: return localizations.thursdayShort;
        case 5: return localizations.fridayShort;
        case 6: return localizations.saturdayShort;
        default: return '';
      }
    }).toList();
    String scheduleString = dayChars.join(', ');
    if (habit.scheduleDays.length == 7) {
      scheduleString = localizations.everyDay;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        titlePadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Container(
              width: 10, height: 20,
              decoration: BoxDecoration(
                  color: habit.color,
                  borderRadius: BorderRadius.circular(4)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(habit.name, style: theme.dialogTheme.titleTextStyle)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                if (habit.description != null && habit.description!.isNotEmpty) ...[
                  Text(
                    habit.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.75), height: 1.4),
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
                if (habit.goalType != GoalType.yesNo && habit.goalValue != null && habit.goalValue! > 0) ...[
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    theme,
                    icon: habit.goalType == GoalType.time ? Icons.timer_outlined : Icons.format_list_numbered_rtl_rounded,
                    text: '${habit.goalType == GoalType.time ? localizations.goalTypeTime : localizations.goalTypeQuantity}: ${habit.goalValue?.toStringAsFixed(0)}${habit.goalType == GoalType.time ? " ${localizations.minutesShort}" : ""}',
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

  Widget _buildDetailRow(ThemeData theme, {required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.9)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Ordena la lista local _currentHabits para la UI
    final List<Habit> sortedHabits = List.from(_currentHabits);
    sortedHabits.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    Widget bodyContent;
    if (sortedHabits.isEmpty) {
      bodyContent = _buildEmptyState(localizations, theme);
    } else {
      // Pasa la lista ordenada (que viene de _currentHabits)
      bodyContent = _buildHabitsList(sortedHabits, localizations, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myHabits),
      ),
      body: bodyContent
          .animate(controller: _screenEntryAnimationController)
          .slideX(begin: -0.25, end: 0, curve: Curves.easeOutCubic, duration: _screenEntryAnimationController.duration)
          .fadeIn(duration: _screenEntryAnimationController.duration! * 0.8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final Habit? newHabit = await Navigator.push<Habit>(
            context,
            MaterialPageRoute(builder: (context) => const NewHabitScreen()),
          );
          if (newHabit != null && mounted) {
            // Llama al callback de MyHomePage.
            // Isar asignará un ID a newHabit si es autoIncrement.
            await widget.onAddHabit(newHabit);

            // Actualiza la lista local _currentHabits en HabitsScreen
            // y reconstruye la UI.
            if (mounted) {
              setState(() {
                _currentHabits.add(newHabit);
              });
            }
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

  // Este método ahora recibe la lista 'habits' (que será 'sortedHabits' desde el build)
  Widget _buildHabitsList(List<Habit> habits, AppLocalizations localizations, ThemeData theme) {
    final cardBaseBorderRadius = (theme.cardTheme.shape as RoundedRectangleBorder?)
        ?.borderRadius
        ?.resolve(Directionality.of(context)) ??
        BorderRadius.circular(16.0);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 80.0, left: 8.0, right: 8.0),
      itemCount: habits.length, // Usa la lista 'habits' que se le pasa
      itemBuilder: (context, index) {
        final habit = habits[index]; // Obtiene el hábito de la lista pasada
        final bool showInlineOptions = _habitIdWithOptionsOpen == habit.id;

        String scheduleString = habit.scheduleDays.map((dayIndex) {
          switch (dayIndex) {
            case 0: return localizations.sundayShort;
            case 1: return localizations.mondayShort;
            case 2: return localizations.tuesdayShort;
            case 3: return localizations.wednesdayShort;
            case 4: return localizations.thursdayShort;
            case 5: return localizations.fridayShort;
            case 6: return localizations.saturdayShort;
            default: return '';
          }
        }).toList().join(', ');

        if (habit.scheduleDays.length == 7) {
          scheduleString = localizations.everyDay;
        }

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 10.0,
                        decoration: BoxDecoration(
                          color: habit.color,
                          borderRadius: BorderRadius.only(
                            topLeft: cardBaseBorderRadius.topLeft,
                            bottomLeft: showInlineOptions ? Radius.zero : cardBaseBorderRadius.bottomLeft,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                habit.name,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text(
                                    habit.startTime.format(context),
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              if (scheduleString.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 15, color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        scheduleString,
                                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (habit.goalType != GoalType.yesNo && habit.goalValue != null && habit.goalValue! > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                        habit.goalType == GoalType.time ? Icons.timer_outlined : Icons.format_list_numbered_rtl_rounded,
                                        size: 16, color: theme.colorScheme.onSurfaceVariant
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${habit.goalType == GoalType.time ? localizations.goalTypeTime : localizations.goalTypeQuantity}: ${habit.goalValue?.toStringAsFixed(0)}${habit.goalType == GoalType.time ? " ${localizations.minutesShort}" : ""}',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    );
                  },
                  child: showInlineOptions
                      ? Container(
                    key: ValueKey<Id>(habit.id),
                    decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest ?? theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                          bottomLeft: cardBaseBorderRadius.bottomLeft,
                          bottomRight: cardBaseBorderRadius.bottomRight,
                        )
                    ),
                    child: Row(
                      children: [
                        _buildInlineOptionButton(
                          theme,
                          icon: Icons.edit_outlined,
                          label: localizations.editButtonLabel,
                          color: theme.colorScheme.primary,
                          onTap: () {
                            _navigateToEditHabit(habit);
                          },
                        ),
                        _buildInlineOptionButton(
                          theme,
                          icon: Icons.delete_outline_rounded,
                          label: localizations.deleteButtonLabel,
                          color: theme.colorScheme.error,
                          onTap: () {
                            _confirmDeleteHabit(habit, localizations);
                          },
                        ),
                      ],
                    ),
                  )
                      : SizedBox.shrink(key: ValueKey<String>("shrink_${habit.id}")),
                ),
              ],
            ),
          ),
        )
            .animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.05, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildInlineOptionButton(ThemeData theme, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
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
                style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w500),
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