import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:gabits/providers/timer_provider.dart';

enum TimerModeType { stopwatch, timer, intervals }

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with TickerProviderStateMixin {
  late List<bool> _timerModeSelections;
  final FlutterRingtonePlayer _ringtonePlayer = FlutterRingtonePlayer();
  late AnimationController _timerProgressController;
  late AnimationController _intervalProgressController;

  static const EdgeInsets _controlButtonRowPadding =
      EdgeInsets.symmetric(vertical: 22.0);

  @override
  void initState() {
    super.initState();
    final timerState = ref.read(timerNotifierProvider);
    _timerModeSelections = TimerModeType.values
        .map((mode) => mode == timerState.selectedMode)
        .toList();

    _timerProgressController = AnimationController(
      vsync: this,
      duration: timerState.timerInitialDuration,
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _intervalProgressController = AnimationController(
      vsync: this,
      duration: timerState.intervalWorkDuration,
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _timerProgressController.dispose();
    _intervalProgressController.dispose();
    super.dispose();
  }

  void _onTimerModeSelected(int index) {
    HapticFeedback.lightImpact();
    ref
        .read(timerNotifierProvider.notifier)
        .setMode(TimerModeType.values[index]);
    setState(() {
      for (int i = 0; i < _timerModeSelections.length; i++) {
        _timerModeSelections[i] = i == index;
      }
    });
  }

  // --- UI Helpers ---
  String _formatDuration(Duration d, {bool showHoursForce = false}) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0 || showHoursForce) return "$hours:$minutes:$seconds";
    return "$minutes:$seconds";
  }

  void _onTimerFinished() {
    _ringtonePlayer.playNotification(asAlarm: true);
    HapticFeedback.heavyImpact();
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(localizations.timerFinishedTitle,
            style: theme.textTheme.headlineSmall),
        content: Text(localizations.timerFinishedMessage,
            style: theme.textTheme.bodyLarge),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(localizations.ok,
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  void _onIntervalSegmentFinished() {
    _ringtonePlayer.playNotification(asAlarm: true);
    HapticFeedback.heavyImpact();
  }

  void _onIntervalAllFinished() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(localizations.intervalCyclesFinishedTitle,
            style: Theme.of(context).textTheme.headlineSmall),
        content: Text(localizations.intervalCyclesFinishedMessage,
            style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(localizations.ok,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  Future<void> _selectTimerDurationDialog() async {
    HapticFeedback.lightImpact();
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final timerState = ref.read(timerNotifierProvider);
    Duration initialDialogDuration =
        timerState.isTimerActive && !timerState.isTimerPaused
            ? timerState.timerRemainingDuration
            : timerState.timerInitialDuration;
    if (initialDialogDuration == Duration.zero && !timerState.isTimerActive)
      initialDialogDuration = const Duration(minutes: 5);
    int h = initialDialogDuration.inHours;
    int m = initialDialogDuration.inMinutes.remainder(60);
    int s = initialDialogDuration.inSeconds.remainder(60);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(localizations.setDurationPrompt,
              style: theme.textTheme.headlineSmall),
          contentPadding:
              const EdgeInsets.only(top: 20, bottom: 10, left: 8, right: 8),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildDurationPicker(localizations.hoursShort.toUpperCase(),
                      h, 23, (val) => setStateDialog(() => h = val), theme,
                      itemWidth: 60, itemHeight: 70),
                  Text(":",
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: theme.colorScheme.outline)),
                  _buildDurationPicker(
                      localizations.minutesShortForm.toUpperCase(),
                      m,
                      59,
                      (val) => setStateDialog(() => m = val),
                      theme,
                      itemWidth: 60,
                      itemHeight: 70),
                  Text(":",
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: theme.colorScheme.outline)),
                  _buildDurationPicker(localizations.secondsShort.toUpperCase(),
                      s, 59, (val) => setStateDialog(() => s = val), theme,
                      itemWidth: 60, itemHeight: 70),
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: <Widget>[
            TextButton(
                child: Text(localizations.cancel,
                    style:
                        TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text(localizations.doneButtonLabel,
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                final newDuration = Duration(hours: h, minutes: m, seconds: s);
                if (newDuration == Duration.zero) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(localizations.timerDurationCannotBeZero)));
                  return;
                }
                ref
                    .read(timerNotifierProvider.notifier)
                    .setTimerDuration(newDuration);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectIntervalSettingsDialog() async {
    HapticFeedback.lightImpact();
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final timerState = ref.read(timerNotifierProvider);
    Duration tempWorkDuration = timerState.intervalWorkDuration;
    Duration tempBreakDuration = timerState.intervalBreakDuration;
    Duration tempLongBreakDuration = timerState.intervalLongBreakDuration;
    int tempCycles = timerState.intervalCyclesBeforeLongBreak;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(localizations.configurePomodoroTitle,
                style: theme.textTheme.headlineSmall),
            contentPadding:
                const EdgeInsets.only(top: 16, bottom: 0, left: 20, right: 20),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildIntervalDurationPickerRow(
                      localizations.workDurationLabel,
                      tempWorkDuration,
                      (newDuration) =>
                          setStateDialog(() => tempWorkDuration = newDuration),
                      theme,
                      localizations),
                  const SizedBox(height: 16),
                  _buildIntervalDurationPickerRow(
                      localizations.shortBreakDurationLabel,
                      tempBreakDuration,
                      (newDuration) =>
                          setStateDialog(() => tempBreakDuration = newDuration),
                      theme,
                      localizations),
                  const SizedBox(height: 16),
                  _buildIntervalDurationPickerRow(
                      localizations.longBreakDurationLabel,
                      tempLongBreakDuration,
                      (newDuration) => setStateDialog(
                          () => tempLongBreakDuration = newDuration),
                      theme,
                      localizations),
                  const SizedBox(height: 20),
                  Text(localizations.cyclesBeforeLongBreakLabel,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Center(
                      child: _buildSmallNumberPicker(
                          tempCycles,
                          10,
                          (val) => setStateDialog(() => tempCycles = val),
                          theme)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: <Widget>[
              TextButton(
                  child: Text(localizations.cancel,
                      style:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  onPressed: () => Navigator.of(context).pop()),
              TextButton(
                child: Text(localizations.doneButtonLabel,
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (tempWorkDuration == Duration.zero) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(localizations.timerDurationCannotBeZeroWork)));
                    return;
                  }
                  ref.read(timerNotifierProvider.notifier).setIntervalConfig(
                        work: tempWorkDuration,
                        breakDuration: tempBreakDuration,
                        longBreak: tempLongBreakDuration,
                        cycles: tempCycles,
                      );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  // --- UI BUILDERS ---
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final timerState = ref.watch(timerNotifierProvider);

    // Sync progress controllers
    if (timerState.isTimerActive && !timerState.isTimerPaused) {
      _timerProgressController.duration = timerState.timerInitialDuration;
      if (timerState.timerInitialDuration.inMilliseconds > 0) {
        _timerProgressController.value =
            timerState.timerRemainingDuration.inMilliseconds /
                timerState.timerInitialDuration.inMilliseconds;
        if (!_timerProgressController.isAnimating)
          _timerProgressController.reverse();
      }
    } else {
      _timerProgressController.stop();
      if (timerState.timerInitialDuration.inMilliseconds > 0) {
        _timerProgressController.value =
            timerState.timerRemainingDuration.inMilliseconds /
                timerState.timerInitialDuration.inMilliseconds;
      }
    }

    if (timerState.isIntervalTimerActive && !timerState.isIntervalTimerPaused) {
      _intervalProgressController.duration =
          timerState.intervalCurrentSegmentInitialDuration;
      if (timerState.intervalCurrentSegmentInitialDuration.inMilliseconds > 0) {
        _intervalProgressController.value =
            timerState.intervalCurrentSegmentRemainingDuration.inMilliseconds /
                timerState.intervalCurrentSegmentInitialDuration.inMilliseconds;
        if (!_intervalProgressController.isAnimating)
          _intervalProgressController.reverse();
      }
    } else {
      _intervalProgressController.stop();
      if (timerState.intervalCurrentSegmentInitialDuration.inMilliseconds > 0) {
        _intervalProgressController.value =
            timerState.intervalCurrentSegmentRemainingDuration.inMilliseconds /
                timerState.intervalCurrentSegmentInitialDuration.inMilliseconds;
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final toggleButtonMinWidth = (screenWidth - 32 - (1.5 * 2 * 2)) / 3 - 8;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.timerScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.03),
                                  end: Offset.zero)
                              .animate(animation),
                          child: child));
                },
                child: _buildCurrentModeTimeDisplay(
                    localizations, theme, timerState),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ToggleButtons(
                  isSelected: _timerModeSelections,
                  onPressed: _onTimerModeSelected,
                  borderRadius: BorderRadius.circular(12.0),
                  selectedColor: theme.colorScheme.onPrimary,
                  fillColor: theme.colorScheme.primary,
                  borderColor: theme.colorScheme.outlineVariant,
                  selectedBorderColor: theme.colorScheme.primary,
                  borderWidth: 1.5,
                  constraints: BoxConstraints(
                      minHeight: 48.0, minWidth: toggleButtonMinWidth),
                  children: [
                    _buildToggleButtonChild(localizations.stopwatchMode, theme,
                        _timerModeSelections[0]),
                    _buildToggleButtonChild(localizations.timerMode, theme,
                        _timerModeSelections[1]),
                    _buildToggleButtonChild(localizations.intervalsMode, theme,
                        _timerModeSelections[2]),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: _buildCurrentModeControlsAndExtras(
                      localizations, theme, timerState),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtonChild(
      String text, ThemeData theme, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(text,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary),
          overflow: TextOverflow.fade,
          softWrap: false,
          maxLines: 1),
    );
  }

  Widget _buildCurrentModeTimeDisplay(
      AppLocalizations localizations, ThemeData theme, TimerState state) {
    switch (state.selectedMode) {
      case TimerModeType.stopwatch:
        return _buildStopwatchTimeDisplay(localizations, theme, state,
            key: const ValueKey('stopwatch_display'));
      case TimerModeType.timer:
        return _buildTimerTimeDisplay(localizations, theme, state,
            key: const ValueKey('timer_display'));
      case TimerModeType.intervals:
        return _buildIntervalsTimeDisplay(localizations, theme, state,
            key: const ValueKey('intervals_display'));
    }
  }

  Widget _buildCurrentModeControlsAndExtras(
      AppLocalizations localizations, ThemeData theme, TimerState state) {
    switch (state.selectedMode) {
      case TimerModeType.stopwatch:
        return _buildStopwatchControlsAndLaps(localizations, theme, state,
            key: const ValueKey('stopwatch_controls'));
      case TimerModeType.timer:
        return _buildTimerControls(localizations, theme, state,
            key: const ValueKey('timer_controls'));
      case TimerModeType.intervals:
        return _buildIntervalsControls(localizations, theme, state,
            key: const ValueKey('intervals_controls'));
    }
  }

  // --- Mode UI Builders ---
  Widget _buildStopwatchTimeDisplay(
      AppLocalizations localizations, ThemeData theme, TimerState state,
      {Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 54.0),
        Text(state.stopwatchFormattedTime,
            style: theme.textTheme.displayLarge?.copyWith(
                fontFamily: '.SF UI Display',
                fontWeight: FontWeight.w200,
                color: theme.colorScheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()])),
        const SizedBox(height: 220 + 24 - 54.0),
      ],
    );
  }

  Widget _buildStopwatchControlsAndLaps(
      AppLocalizations localizations, ThemeData theme, TimerState state,
      {Key? key}) {
    final notifier = ref.read(timerNotifierProvider.notifier);
    return Column(
      key: key,
      children: <Widget>[
        Padding(
          padding: _controlButtonRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _TimerControlButton(
                  icon: Icons.flag_outlined,
                  label: localizations.lapLabel,
                  onPressed: (state.stopwatchFormattedTime != "00:00:00.00")
                      ? () {
                          HapticFeedback.lightImpact();
                          notifier.addLap(
                              "${localizations.lapItem(state.laps.length + 1)} ${state.stopwatchFormattedTime}");
                        }
                      : null,
                  theme: theme),
              _TimerControlButton(
                  icon: (state.stopwatchFormattedTime != "00:00:00.00" &&
                          !state.stopwatchFormattedTime.endsWith(".00"))
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: localizations.startLabel,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    notifier.toggleStopwatch();
                  },
                  isPrimary: true,
                  theme: theme),
              _TimerControlButton(
                  icon: Icons.replay_rounded,
                  label: localizations.resetLabel,
                  onPressed: (state.stopwatchFormattedTime != "00:00:00.00" ||
                          state.laps.isNotEmpty)
                      ? () {
                          HapticFeedback.lightImpact();
                          notifier.resetStopwatch();
                        }
                      : null,
                  theme: theme),
            ],
          ),
        ),
        if (state.laps.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(localizations.lapsHeader,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600))),
        Expanded(
          child: state.laps.isEmpty
              ? Center(
                  child: Text(localizations.noDataAvailable,
                      style: TextStyle(
                          color: theme.colorScheme.outline, fontSize: 16)))
              : Scrollbar(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 0, bottom: 8.0),
                    itemCount: state.laps.length,
                    separatorBuilder: (context, index) => Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.3),
                        indent: 60,
                        endIndent: 20),
                    itemBuilder: (context, index) {
                      final lapData = state.laps[index].split(' ');
                      final lapNumberText = lapData.first;
                      final lapTime = lapData.length > 1
                          ? lapData.sublist(1).join(' ')
                          : "";
                      return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 2),
                          leading: Text(lapNumberText,
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          title: Text(lapTime,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: '.SF UI Display',
                                  fontFeatures: [
                                    FontFeature.tabularFigures()
                                  ])));
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTimerTimeDisplay(
      AppLocalizations localizations, ThemeData theme, TimerState state,
      {Key? key}) {
    final bool intervalHasCycleText = state.intervalCyclesBeforeLongBreak > 0 &&
        (state.isIntervalTimerActive || state.currentIntervalCycle > 0);
    final double topPadding =
        24.0 + 8.0 + (intervalHasCycleText ? 16.0 + 6.0 : 0.0);
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: topPadding),
        GestureDetector(
          onTap: state.isTimerActive && !state.isTimerPaused
              ? null
              : _selectTimerDurationDialog,
          child: Text(
              _formatDuration(
                  state.isTimerActive
                      ? state.timerRemainingDuration
                      : state.timerInitialDuration,
                  showHoursForce: state.timerInitialDuration.inHours > 0),
              style: theme.textTheme.displayLarge?.copyWith(
                  fontFamily: '.SF UI Display',
                  fontWeight: FontWeight.w200,
                  color: (state.isTimerActive ||
                          state.timerInitialDuration > Duration.zero)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                  value: _timerProgressController.value,
                  strokeWidth: 14,
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  strokeCap: StrokeCap.round),
              Center(
                  child: Icon(
                      state.isTimerActive && !state.isTimerPaused
                          ? Icons.hourglass_bottom_rounded
                          : (state.timerInitialDuration == Duration.zero
                              ? Icons.timer_off_outlined
                              : Icons.hourglass_top_rounded),
                      size: 70,
                      color: theme.colorScheme.primary.withOpacity(
                          (state.isTimerActive ||
                                  state.timerInitialDuration > Duration.zero)
                              ? 0.7
                              : 0.4))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerControls(
      AppLocalizations localizations, ThemeData theme, TimerState state,
      {Key? key}) {
    final notifier = ref.read(timerNotifierProvider.notifier);
    return Column(
      key: key,
      children: [
        Padding(
          padding: _controlButtonRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimerControlButton(
                  icon: Icons.tune_rounded,
                  label: localizations.settingsLabel,
                  theme: theme,
                  onPressed: (state.isTimerActive && !state.isTimerPaused)
                      ? null
                      : _selectTimerDurationDialog),
              _TimerControlButton(
                  icon: state.isTimerActive && !state.isTimerPaused
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: state.isTimerActive && !state.isTimerPaused
                      ? localizations.pauseLabel
                      : (state.isTimerPaused
                          ? localizations.resumeLabel
                          : localizations.startLabel),
                  onPressed: state.timerInitialDuration == Duration.zero
                      ? null
                      : () => notifier.toggleTimer(_onTimerFinished),
                  isPrimary: true,
                  theme: theme),
              _TimerControlButton(
                  icon: Icons.replay_rounded,
                  label: localizations.resetLabel,
                  theme: theme,
                  onPressed: (state.isTimerActive ||
                          state.timerRemainingDuration !=
                              state.timerInitialDuration)
                      ? () => notifier.resetTimer(resetInitialDuration: false)
                      : null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalsTimeDisplay(
      AppLocalizations localizations, ThemeData theme, TimerState state,
      {Key? key}) {
    String currentModeLabel = state.isIntervalWorkTime
        ? localizations.pomodoroSessionWork
        : (state.intervalCurrentSegmentInitialDuration ==
                    state.intervalLongBreakDuration &&
                state.intervalLongBreakDuration > Duration.zero
            ? localizations.pomodoroSessionLongBreak
            : localizations.pomodoroSessionShortBreak);
    String cycleText = (state.intervalCyclesBeforeLongBreak > 0 &&
            (state.isIntervalTimerActive || state.currentIntervalCycle > 0))
        ? localizations.pomodoroCycleInfo(
            state.currentIntervalCycle > 0 ? state.currentIntervalCycle : 1,
            state.intervalCyclesBeforeLongBreak)
        : "";
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(currentModeLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
                color: state.isIntervalWorkTime
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
            _formatDuration(state.intervalCurrentSegmentRemainingDuration,
                showHoursForce:
                    state.intervalCurrentSegmentInitialDuration.inHours > 0),
            style: theme.textTheme.displayLarge?.copyWith(
                fontFamily: '.SF UI Display',
                fontWeight: FontWeight.w200,
                color: (state.isIntervalTimerActive ||
                        state.intervalWorkDuration > Duration.zero)
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                fontFeatures: const [FontFeature.tabularFigures()])),
        if (cycleText.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(cycleText,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500))),
        const SizedBox(height: 24),
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                  value: _intervalProgressController.value,
                  strokeWidth: 14,
                  backgroundColor: (state.isIntervalWorkTime
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.secondaryContainer)
                      .withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      state.isIntervalWorkTime
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary),
                  strokeCap: StrokeCap.round),
              Center(
                  child: Icon(
                      state.isIntervalTimerActive &&
                              !state.isIntervalTimerPaused
                          ? (state.isIntervalWorkTime
                              ? Icons.auto_stories_outlined
                              : Icons.emoji_food_beverage_outlined)
                          : (state.intervalWorkDuration == Duration.zero
                              ? Icons.settings_suggest_outlined
                              : Icons.hourglass_top_rounded),
                      size: 70,
                      color: (state.isIntervalWorkTime
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary)
                          .withOpacity((state.isIntervalTimerActive ||
                                  state.intervalWorkDuration > Duration.zero)
                              ? 0.7
                              : 0.4))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalsControls(
      AppLocalizations localizations, ThemeData theme, TimerState state,
      {Key? key}) {
    final notifier = ref.read(timerNotifierProvider.notifier);
    return Column(
      key: key,
      children: [
        Padding(
          padding: _controlButtonRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimerControlButton(
                  icon: Icons.tune_rounded,
                  label: localizations.settingsLabel,
                  theme: theme,
                  onPressed: (state.isIntervalTimerActive &&
                          !state.isIntervalTimerPaused)
                      ? null
                      : _selectIntervalSettingsDialog),
              _TimerControlButton(
                  icon: state.isIntervalTimerActive &&
                          !state.isIntervalTimerPaused
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: state.isIntervalTimerActive &&
                          !state.isIntervalTimerPaused
                      ? localizations.pauseLabel
                      : (state.isIntervalTimerPaused
                          ? localizations.resumeLabel
                          : localizations.startLabel),
                  onPressed: state.intervalWorkDuration == Duration.zero
                      ? null
                      : () => notifier.toggleIntervalTimer(
                          _onIntervalSegmentFinished, _onIntervalAllFinished),
                  isPrimary: true,
                  theme: theme,
                  primaryColorOverride: state.isIntervalWorkTime
                      ? null
                      : theme.colorScheme.secondary),
              _TimerControlButton(
                  icon: Icons.replay_rounded,
                  label: localizations.resetLabel,
                  theme: theme,
                  onPressed: (state.isIntervalTimerActive ||
                          state.currentIntervalCycle != 0)
                      ? () => notifier.resetIntervalTimer(resetConfig: false)
                      : null),
            ],
          ),
        ),
      ],
    );
  }

  // --- Common Components ---
  Widget _buildIntervalDurationPickerRow(
      String label,
      Duration currentDuration,
      ValueChanged<Duration> onDurationChanged,
      ThemeData theme,
      AppLocalizations localizations) {
    int h = currentDuration.inHours;
    int m = currentDuration.inMinutes.remainder(60);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
                child: _buildDurationPicker(
                    localizations.hoursShort.toUpperCase(),
                    h,
                    5,
                    (val) =>
                        onDurationChanged(Duration(hours: val, minutes: m)),
                    theme,
                    itemWidth: 50,
                    itemHeight: 65)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(":",
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w300))),
            Expanded(
                child: _buildDurationPicker(
                    localizations.minutesShortForm.toUpperCase(),
                    m,
                    59,
                    (val) =>
                        onDurationChanged(Duration(hours: h, minutes: val)),
                    theme,
                    itemWidth: 50,
                    itemHeight: 65)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallNumberPicker(int currentValue, int maxValue,
      ValueChanged<int> onChanged, ThemeData theme) {
    return NumberPicker(
        value: currentValue,
        minValue: 1,
        maxValue: maxValue,
        step: 1,
        itemHeight: 35,
        itemWidth: 70,
        onChanged: onChanged,
        textStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
        selectedTextStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5))));
  }

  Widget _buildDurationPicker(String label, int currentValue, int maxValue,
      ValueChanged<int> onChanged, ThemeData theme,
      {double itemHeight = 40, double itemWidth = 50}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        NumberPicker(
            value: currentValue,
            minValue: 0,
            maxValue: maxValue,
            step: 1,
            itemHeight: itemHeight,
            itemWidth: itemWidth,
            onChanged: onChanged,
            textStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 18),
            selectedTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5)))),
      ],
    );
  }
}

class _TimerControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final ThemeData theme;
  final Color? primaryColorOverride;

  const _TimerControlButton(
      {required this.icon,
      required this.label,
      required this.onPressed,
      this.isPrimary = false,
      required this.theme,
      this.primaryColorOverride});

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor =
        primaryColorOverride ?? theme.colorScheme.primary;
    final Color foregroundColor = isPrimary
        ? theme.colorScheme.onPrimary
        : (onPressed != null
            ? effectivePrimaryColor
            : theme.colorScheme.onSurface.withOpacity(0.38));
    final Color backgroundColor =
        isPrimary ? effectivePrimaryColor : theme.colorScheme.surfaceVariant;
    return SizedBox(
      width: 72.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: isPrimary ? 72.0 : 60.0,
            height: isPrimary ? 72.0 : 60.0,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  elevation: isPrimary ? 4.0 : 1.5),
              child: Icon(icon, size: isPrimary ? 32.0 : 26.0),
            ),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: onPressed != null
                      ? theme.colorScheme.onSurface.withOpacity(0.9)
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
