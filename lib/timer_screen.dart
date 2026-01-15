import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

enum TimerModeType { stopwatch, timer, intervals }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  TimerModeType _selectedMode = TimerModeType.stopwatch;
  late List<bool> _timerModeSelections;

  final FlutterRingtonePlayer _ringtonePlayer = FlutterRingtonePlayer();

  // Stopwatch State
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  String _stopwatchFormattedTime = "00:00:00.00";
  List<String> _laps = [];

  // Timer State
  Timer? _countdownTimerInstance;
  Duration _timerInitialDuration = const Duration(minutes: 5);
  Duration _timerRemainingDuration = const Duration(minutes: 5);
  bool _isTimerActive = false;
  bool _isTimerPaused = false;
  late AnimationController _timerProgressController;

  // Interval Timer State
  Timer? _intervalInstance;
  Duration _intervalWorkDuration = const Duration(minutes: 25);
  Duration _intervalBreakDuration = const Duration(minutes: 5);
  Duration _intervalLongBreakDuration = const Duration(minutes: 15);
  int _intervalCyclesBeforeLongBreak = 4;
  int _currentIntervalCycle = 0;
  bool _isIntervalWorkTime = true;
  bool _isIntervalTimerActive = false;
  bool _isIntervalTimerPaused = false;
  Duration _intervalCurrentSegmentRemainingDuration = const Duration(minutes: 25);
  Duration _intervalCurrentSegmentInitialDuration = const Duration(minutes: 25);
  late AnimationController _intervalProgressController;

  static const EdgeInsets _controlButtonRowPadding = EdgeInsets.symmetric(vertical: 22.0);


  @override
  void initState() {
    super.initState();
    _timerModeSelections = TimerModeType.values.map((mode) => mode == _selectedMode).toList();
    _updateStopwatchDisplay();

    _timerProgressController = AnimationController(
      vsync: this,
      duration: _timerInitialDuration,
    )..addListener(() {
      if (mounted) setState(() {});
    });
    _timerProgressController.value = _timerInitialDuration > Duration.zero ? 1.0 : 0.0;


    _intervalProgressController = AnimationController(
      vsync: this,
      duration: _intervalWorkDuration,
    )..addListener(() {
      if (mounted) setState(() {});
    });
    _intervalProgressController.value = _intervalWorkDuration > Duration.zero ? 1.0 : 0.0;
    _intervalCurrentSegmentRemainingDuration = _intervalWorkDuration;
    _intervalCurrentSegmentInitialDuration = _intervalWorkDuration;
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _stopwatch.stop();
    _countdownTimerInstance?.cancel();
    _timerProgressController.dispose();
    _intervalInstance?.cancel();
    _intervalProgressController.dispose();
    super.dispose();
  }

  void _onTimerModeSelected(int index) {
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() {
        for (int i = 0; i < _timerModeSelections.length; i++) {
          _timerModeSelections[i] = i == index;
        }
        _selectedMode = TimerModeType.values[index];
        _resetStopwatch();
        _resetTimer(resetInitialDuration: false);
        _resetIntervalTimer(resetConfig: false);
      });
    }
  }

  // --- LOGIC METHODS ---
  void _updateStopwatchDisplay() { if (mounted) { final ms = _stopwatch.elapsedMilliseconds; final hundreds = (ms % 1000) ~/ 10; final seconds = (ms ~/ 1000) % 60; final minutes = (ms ~/ (1000 * 60)) % 60; final hours = (ms ~/ (1000 * 60 * 60)); setState(() { _stopwatchFormattedTime = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}"; }); } }
  void _toggleStopwatch() { HapticFeedback.mediumImpact(); if (_stopwatch.isRunning) { _stopwatch.stop(); _stopwatchTimer?.cancel(); } else { _stopwatch.start(); _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) { _updateStopwatchDisplay(); }); } if (mounted) setState(() {}); }
  void _resetStopwatch() { HapticFeedback.lightImpact(); _stopwatch.stop(); _stopwatch.reset(); _stopwatchTimer?.cancel(); if (mounted) { setState(() { _laps.clear(); _updateStopwatchDisplay(); }); } }
  void _addLap() { if (!_stopwatch.isRunning && _stopwatch.elapsedMilliseconds == 0) return; HapticFeedback.lightImpact(); final localizations = AppLocalizations.of(context)!; if (mounted) { setState(() { _laps.insert(0, "${localizations.lapItem(_laps.length + 1)} $_stopwatchFormattedTime"); }); } }
  String _formatDuration(Duration d, {bool showHoursForce = false}) { String twoDigits(int n) => n.toString().padLeft(2, '0'); String hours = twoDigits(d.inHours); String minutes = twoDigits(d.inMinutes.remainder(60)); String seconds = twoDigits(d.inSeconds.remainder(60)); if (d.inHours > 0 || showHoursForce) return "$hours:$minutes:$seconds"; return "$minutes:$seconds"; }
  void _toggleTimer() { HapticFeedback.mediumImpact(); if (_timerInitialDuration == Duration.zero) return; if (_isTimerActive) { if (_isTimerPaused) { _isTimerPaused = false; _timerProgressController.forward(from: _timerProgressController.value); _startCountdown(); } else { _isTimerPaused = true; _countdownTimerInstance?.cancel(); _timerProgressController.stop(); } } else { _isTimerActive = true; _isTimerPaused = false; _timerRemainingDuration = _timerInitialDuration; _timerProgressController.duration = _timerInitialDuration; _timerProgressController.value = 1.0; _timerProgressController.reverse(from: 1.0); _startCountdown(); } if (mounted) setState(() {}); }
  void _startCountdown() { _countdownTimerInstance?.cancel(); _countdownTimerInstance = Timer.periodic(const Duration(seconds: 1), (timer) { if (_timerRemainingDuration.inSeconds > 0) { if (mounted) { setState(() { _timerRemainingDuration -= const Duration(seconds: 1); if (_timerInitialDuration.inMilliseconds > 0) { _timerProgressController.value = _timerRemainingDuration.inMilliseconds / _timerInitialDuration.inMilliseconds.clamp(1, double.infinity); } }); } } else { _timerFinished(); } }); }
  void _resetTimer({bool resetInitialDuration = true}) { HapticFeedback.lightImpact(); _countdownTimerInstance?.cancel(); _isTimerActive = false; _isTimerPaused = false; if (mounted) { setState(() { if (resetInitialDuration) { _timerInitialDuration = const Duration(minutes: 5); } _timerRemainingDuration = _timerInitialDuration; _timerProgressController.duration = _timerInitialDuration; _timerProgressController.value = _timerInitialDuration > Duration.zero ? 1.0 : 0.0; }); } }
  void _timerFinished() { _ringtonePlayer.playNotification(asAlarm: true); HapticFeedback.heavyImpact(); _countdownTimerInstance?.cancel(); _isTimerActive = false; _isTimerPaused = false; final localizations = AppLocalizations.of(context)!; final theme = Theme.of(context); if (mounted) { setState(() { _timerRemainingDuration = _timerInitialDuration; _timerProgressController.value = _timerInitialDuration > Duration.zero ? 1.0 : 0.0; }); showDialog( context: context, builder: (ctx) => AlertDialog( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), title: Text(localizations.timerFinishedTitle, style: theme.textTheme.headlineSmall), content: Text(localizations.timerFinishedMessage, style: theme.textTheme.bodyLarge), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(localizations.ok, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)))], ), ); } }
  Future<void> _selectTimerDurationDialog() async { HapticFeedback.lightImpact(); final localizations = AppLocalizations.of(context)!; final theme = Theme.of(context); Duration initialDialogDuration = _isTimerActive && !_isTimerPaused ? _timerRemainingDuration : _timerInitialDuration; if (initialDialogDuration == Duration.zero && !_isTimerActive) initialDialogDuration = const Duration(minutes: 5); int h = initialDialogDuration.inHours; int m = initialDialogDuration.inMinutes.remainder(60); int s = initialDialogDuration.inSeconds.remainder(60); await showDialog<void>( context: context, builder: (BuildContext context) { return AlertDialog( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), title: Text(localizations.setDurationPrompt, style: theme.textTheme.headlineSmall), contentPadding: const EdgeInsets.only(top: 20, bottom: 10, left: 8, right: 8), content: StatefulBuilder( builder: (context, setStateDialog) { return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[ _buildDurationPicker(localizations.hoursShort.toUpperCase(), h, 23, (val) => setStateDialog(() => h = val), theme, itemWidth: 60, itemHeight: 70), Text(":", style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.outline)), _buildDurationPicker(localizations.minutesShortForm.toUpperCase(), m, 59, (val) => setStateDialog(() => m = val), theme, itemWidth: 60, itemHeight: 70), Text(":", style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.outline)), _buildDurationPicker(localizations.secondsShort.toUpperCase(), s, 59, (val) => setStateDialog(() => s = val), theme, itemWidth: 60, itemHeight: 70), ], ); }, ), actionsAlignment: MainAxisAlignment.spaceBetween, actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), actions: <Widget>[ TextButton(child: Text(localizations.cancel, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)), onPressed: () => Navigator.of(context).pop()), TextButton( child: Text(localizations.doneButtonLabel, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)), onPressed: () { final newDuration = Duration(hours: h, minutes: m, seconds: s); if (newDuration == Duration.zero && _selectedMode == TimerModeType.timer) { Navigator.of(context).pop(); ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(localizations.timerDurationCannotBeZero), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.fromLTRB(15, 5, 15, 10), backgroundColor: theme.colorScheme.errorContainer, ) ); return; } if (mounted) { setState(() { _timerInitialDuration = newDuration; if (!_isTimerActive) { _timerRemainingDuration = newDuration; _timerProgressController.duration = newDuration; _timerProgressController.value = 1.0;} }); } Navigator.of(context).pop(); }, ), ], ); }, ); }
  void _toggleIntervalTimer() { HapticFeedback.mediumImpact(); if (_intervalWorkDuration == Duration.zero) return; if (_isIntervalTimerActive) { if (_isIntervalTimerPaused) { _isIntervalTimerPaused = false; _intervalProgressController.forward(from: _intervalProgressController.value); _startIntervalCountdown(); } else { _isIntervalTimerPaused = true; _intervalInstance?.cancel(); _intervalProgressController.stop(); } } else { _isIntervalTimerActive = true; _isIntervalTimerPaused = false; _currentIntervalCycle = 1; _isIntervalWorkTime = true; _intervalCurrentSegmentInitialDuration = _intervalWorkDuration; _intervalCurrentSegmentRemainingDuration = _intervalWorkDuration; _intervalProgressController.duration = _intervalCurrentSegmentInitialDuration; _intervalProgressController.value = 1.0; _intervalProgressController.reverse(from:1.0); _startIntervalCountdown(); } if (mounted) setState(() {}); }
  void _startIntervalCountdown() { _intervalInstance?.cancel(); _intervalInstance = Timer.periodic(const Duration(seconds: 1), (timer) { if (_intervalCurrentSegmentRemainingDuration.inSeconds > 0) { if (mounted) { setState(() { _intervalCurrentSegmentRemainingDuration -= const Duration(seconds: 1); if(_intervalCurrentSegmentInitialDuration.inMilliseconds > 0) { _intervalProgressController.value = _intervalCurrentSegmentRemainingDuration.inMilliseconds / _intervalCurrentSegmentInitialDuration.inMilliseconds.clamp(1, double.infinity); } }); } } else { _intervalSegmentFinished(); } }); }
  void _intervalSegmentFinished() { _ringtonePlayer.playNotification(asAlarm: true); HapticFeedback.heavyImpact(); final localizations = AppLocalizations.of(context)!; if (_isIntervalWorkTime) { _isIntervalWorkTime = false; if (_currentIntervalCycle >= _intervalCyclesBeforeLongBreak && _intervalLongBreakDuration > Duration.zero) { _intervalCurrentSegmentInitialDuration = _intervalLongBreakDuration; } else { _intervalCurrentSegmentInitialDuration = _intervalBreakDuration; } } else { bool wasLongBreak = _intervalCurrentSegmentInitialDuration == _intervalLongBreakDuration; _isIntervalWorkTime = true; if (wasLongBreak) { _currentIntervalCycle = 1; } else { _currentIntervalCycle++; } if (!wasLongBreak && _currentIntervalCycle > _intervalCyclesBeforeLongBreak && _intervalCyclesBeforeLongBreak > 0) { _resetIntervalTimer(resetConfig: false); showDialog( context: context, builder: (ctx) => AlertDialog( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), title: Text(localizations.intervalCyclesFinishedTitle, style: Theme.of(context).textTheme.headlineSmall), content: Text(localizations.intervalCyclesFinishedMessage, style: Theme.of(context).textTheme.bodyLarge), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(localizations.ok, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)))], ), ); if (mounted) setState(() {}); return; } _intervalCurrentSegmentInitialDuration = _intervalWorkDuration; } _intervalCurrentSegmentRemainingDuration = _intervalCurrentSegmentInitialDuration; if (_intervalCurrentSegmentInitialDuration > Duration.zero) { _intervalProgressController.duration = _intervalCurrentSegmentInitialDuration; _intervalProgressController.value = 1.0; _intervalProgressController.reverse(from:1.0); _startIntervalCountdown(); } else { _resetIntervalTimer(resetConfig: false); _intervalProgressController.value = 0.0; } if (mounted) setState(() {}); }
  void _resetIntervalTimer({bool resetConfig = true}) { HapticFeedback.lightImpact(); _intervalInstance?.cancel(); _isIntervalTimerActive = false; _isIntervalTimerPaused = false; _currentIntervalCycle = 0; if (mounted) { setState(() { if (resetConfig) { _intervalWorkDuration = const Duration(minutes: 25); _intervalBreakDuration = const Duration(minutes: 5); _intervalLongBreakDuration = const Duration(minutes: 15); _intervalCyclesBeforeLongBreak = 4; } _isIntervalWorkTime = true; _intervalCurrentSegmentInitialDuration = _intervalWorkDuration; _intervalCurrentSegmentRemainingDuration = _intervalWorkDuration; _intervalProgressController.duration = _intervalCurrentSegmentInitialDuration; _intervalProgressController.value = _intervalWorkDuration > Duration.zero ? 1.0 : 0.0; }); } }
  Future<void> _selectIntervalSettingsDialog() async { HapticFeedback.lightImpact(); final localizations = AppLocalizations.of(context)!; final theme = Theme.of(context); Duration tempWorkDuration = _intervalWorkDuration; Duration tempBreakDuration = _intervalBreakDuration; Duration tempLongBreakDuration = _intervalLongBreakDuration; int tempCycles = _intervalCyclesBeforeLongBreak; await showDialog<void>( context: context, builder: (BuildContext context) { return StatefulBuilder(builder: (context, setStateDialog) { return AlertDialog( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), title: Text(localizations.configurePomodoroTitle, style: theme.textTheme.headlineSmall), contentPadding: const EdgeInsets.only(top: 16, bottom: 0, left: 20, right: 20), content: SingleChildScrollView( child: Column( mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[ _buildIntervalDurationPickerRow( localizations.workDurationLabel, tempWorkDuration, (newDuration) => setStateDialog(() => tempWorkDuration = newDuration), theme, localizations ), const SizedBox(height: 16), _buildIntervalDurationPickerRow( localizations.shortBreakDurationLabel, tempBreakDuration, (newDuration) => setStateDialog(() => tempBreakDuration = newDuration), theme, localizations ), const SizedBox(height: 16), _buildIntervalDurationPickerRow( localizations.longBreakDurationLabel, tempLongBreakDuration, (newDuration) => setStateDialog(() => tempLongBreakDuration = newDuration), theme, localizations ), const SizedBox(height: 20), Text(localizations.cyclesBeforeLongBreakLabel, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)), const SizedBox(height: 10), Center( child: _buildSmallNumberPicker(tempCycles, 10, (val) => setStateDialog(() => tempCycles = val), theme) ), const SizedBox(height: 20), ], ), ), actionsAlignment: MainAxisAlignment.spaceBetween, actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), actions: <Widget>[ TextButton(child: Text(localizations.cancel, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)), onPressed: () => Navigator.of(context).pop()), TextButton( child: Text(localizations.doneButtonLabel, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)), onPressed: () { if (tempWorkDuration == Duration.zero && _selectedMode == TimerModeType.intervals) { Navigator.of(context).pop(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.timerDurationCannotBeZeroWork))); return; } if (mounted) { setState(() { _intervalWorkDuration = tempWorkDuration; _intervalBreakDuration = tempBreakDuration; _intervalLongBreakDuration = tempLongBreakDuration; _intervalCyclesBeforeLongBreak = tempCycles; if (!_isIntervalTimerActive) { _resetIntervalTimer(resetConfig: false); } }); } Navigator.of(context).pop(); }, ), ], ); }); }, ); }
  Widget _buildIntervalDurationPickerRow(String label, Duration currentDuration, ValueChanged<Duration> onDurationChanged, ThemeData theme, AppLocalizations localizations) { int h = currentDuration.inHours; int m = currentDuration.inMinutes.remainder(60); return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)), const SizedBox(height: 10), Row( children: <Widget>[ Expanded( child: _buildDurationPicker(localizations.hoursShort.toUpperCase(), h, 5, (val) => onDurationChanged(Duration(hours: val, minutes: m)), theme, itemWidth: 50, itemHeight: 65), ), Padding( padding: const EdgeInsets.symmetric(horizontal: 4.0), child: Text(":", style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.w300)), ), Expanded( child: _buildDurationPicker(localizations.minutesShortForm.toUpperCase(), m, 59, (val) => onDurationChanged(Duration(hours: h, minutes: val)), theme, itemWidth: 50, itemHeight: 65), ), ], ), ], ); }
  Widget _buildSmallNumberPicker(int currentValue, int maxValue, ValueChanged<int> onChanged, ThemeData theme) { return NumberPicker( value: currentValue, minValue: 1, maxValue: maxValue, step: 1, itemHeight: 35, itemWidth: 70, onChanged: onChanged, textStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 16, fontFamily: '.SF UI Text'), selectedTextStyle: TextStyle(color: theme.colorScheme.primary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: '.SF UI Text'), decoration: BoxDecoration( borderRadius: BorderRadius.circular(8), border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5), width: 1), ), ); }
  Widget _buildDurationPicker(String label, int currentValue, int maxValue, ValueChanged<int> onChanged, ThemeData theme, {double itemHeight = 40, double itemWidth = 50}) { return Column( mainAxisSize: MainAxisSize.min, children: <Widget>[ Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)), const SizedBox(height: 2), NumberPicker( value: currentValue, minValue: 0, maxValue: maxValue, step: 1, itemHeight: itemHeight, itemWidth: itemWidth, onChanged: onChanged, textStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 18, fontFamily: '.SF UI Text'), selectedTextStyle: TextStyle(color: theme.colorScheme.primary, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: '.SF UI Text'), decoration: BoxDecoration( borderRadius: BorderRadius.circular(8), border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5), width: 1), ), ), ], ); }


  // --- UI BUILDERS ---
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double totalHorizontalPadding = 16.0 * 2;
    final double toggleButtonBorderWidth = 1.5;
    final int numberOfToggleButtons = 3;
    final double availableWidthForToggleContent = screenWidth - totalHorizontalPadding - (toggleButtonBorderWidth * (numberOfToggleButtons -1) * 2) ;
    final double toggleButtonMinWidth = (availableWidthForToggleContent / numberOfToggleButtons).floorToDouble() - 8; // Ajustado


    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.timerScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              flex: 5, // Espacio para el display del tiempo
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.03),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentModeTimeDisplay(localizations, theme),
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
                  borderWidth: toggleButtonBorderWidth,
                  splashColor: theme.colorScheme.primary.withOpacity(0.12),
                  constraints: BoxConstraints(minHeight: 48.0, minWidth: toggleButtonMinWidth),
                  children: [
                    _buildToggleButtonChild(localizations.stopwatchMode, theme, _timerModeSelections[0]),
                    _buildToggleButtonChild(localizations.timerMode, theme, _timerModeSelections[1]),
                    _buildToggleButtonChild(localizations.intervalsMode, theme, _timerModeSelections[2]),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 4, // Espacio para controles y extras
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildCurrentModeControlsAndExtras(localizations, theme),
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtonChild(String text, ThemeData theme, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }

  Widget _buildCurrentModeTimeDisplay(AppLocalizations localizations, ThemeData theme) {
    switch (_selectedMode) {
      case TimerModeType.stopwatch: return _buildStopwatchTimeDisplay(localizations, theme, key: const ValueKey('stopwatch_display'));
      case TimerModeType.timer: return _buildTimerTimeDisplay(localizations, theme, key: const ValueKey('timer_display'));
      case TimerModeType.intervals: return _buildIntervalsTimeDisplay(localizations, theme, key: const ValueKey('intervals_display'));
    }
  }

  Widget _buildCurrentModeControlsAndExtras(AppLocalizations localizations, ThemeData theme) {
    switch (_selectedMode) {
      case TimerModeType.stopwatch: return _buildStopwatchControlsAndLaps(localizations, theme, key: const ValueKey('stopwatch_controls'));
      case TimerModeType.timer: return _buildTimerControls(localizations, theme, key: const ValueKey('timer_controls'));
      case TimerModeType.intervals: return _buildIntervalsControls(localizations, theme, key: const ValueKey('intervals_controls'));
    }
  }

  // --- MÉTODOS DE UI DESCOMPUESTOS ---

  // STOPWATCH
  Widget _buildStopwatchTimeDisplay(AppLocalizations localizations, ThemeData theme, {Key? key}) {
    // Estimación de la altura del texto de "Work Session" + SizedBox(8) + cycleText + SizedBox(6)
    // headlineSmall.fontSize (aprox 24) + 8 + titleMedium.fontSize (aprox 16) + 6 = ~54
    // Esto es para intentar alinear el número grande del cronómetro con los otros.
    const double topPlaceholderHeight = 54.0; // Ajustar según sea necesario
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: topPlaceholderHeight), // Placeholder de altura
        Text(
          _stopwatchFormattedTime,
          style: theme.textTheme.displayLarge?.copyWith(
            fontFamily: '.SF UI Display', fontWeight: FontWeight.w200, letterSpacing: 1.0,
            color: theme.colorScheme.primary, fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        // Placeholder inferior para que el bloque completo tenga una altura similar
        // al bloque de tiempo + círculo de los otros modos.
        // Altura del círculo (220) + SizedBox(24) que está antes en los otros.
        const SizedBox(height: (220 + 24) - topPlaceholderHeight),
      ],
    );
  }

  Widget _buildStopwatchControlsAndLaps(AppLocalizations localizations, ThemeData theme, {Key? key}) {
    return Column(
      key: key,
      children: <Widget>[
        Padding(
          padding: _controlButtonRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _TimerControlButton(icon: Icons.flag_outlined, label: localizations.lapLabel, onPressed: (_stopwatch.isRunning || _stopwatch.elapsedMilliseconds > 0) ? _addLap : null, theme: theme),
              _TimerControlButton(icon: _stopwatch.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, label: _stopwatch.isRunning ? localizations.pauseLabel : localizations.startLabel, onPressed: _toggleStopwatch, isPrimary: true, theme: theme),
              _TimerControlButton(icon: Icons.replay_rounded, label: localizations.resetLabel, onPressed: (_stopwatch.elapsedMilliseconds > 0 || _laps.isNotEmpty) ? _resetStopwatch : null, theme: theme),
            ],
          ),
        ),
        if (_laps.isNotEmpty) Padding( padding: const EdgeInsets.only(bottom: 8.0), child: Text(localizations.lapsHeader, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)), ),
        Expanded(
          child: _laps.isEmpty
              ? Center(child: Text(localizations.noDataAvailable, style: TextStyle(color: theme.colorScheme.outline, fontSize: 16)))
              : Scrollbar(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 0, bottom: 8.0),
              itemCount: _laps.length,
              separatorBuilder: (context, index) => Divider(height: 0.5, thickness: 0.5, color: theme.colorScheme.outlineVariant.withOpacity(0.3), indent: 60, endIndent: 20),
              itemBuilder: (context, index) {
                final lapData = _laps[index].split(' ');
                final lapNumberText = lapData.first;
                final lapTime = lapData.length > 1 ? lapData.sublist(1).join(' ') : "";
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  leading: Text(lapNumberText, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: '.SF UI Text')),
                  title: Text(lapTime, style: theme.textTheme.bodyLarge?.copyWith(fontFamily: '.SF UI Display', fontWeight: FontWeight.w400, letterSpacing: 0.5, fontFeatures: [FontFeature.tabularFigures()])),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // TIMER
  Widget _buildTimerTimeDisplay(AppLocalizations localizations, ThemeData theme, {Key? key}) {
    // Para alinear con Intervals:
    // Intervals tiene: Titulo (aprox 28) + SizedBox(8) + Tiempo + (Opcional CycleText + SizedBox(6)) + SizedBox(24) + Circulo
    // Timer no tiene título ni cycle text. Necesitamos un SizedBox arriba para compensar.
    // Si Intervals tiene cycleText, la altura adicional es aprox 16+6=22. Si no, es 0.
    final bool intervalHasCycleText = _intervalCyclesBeforeLongBreak > 0 && (_isIntervalTimerActive || _currentIntervalCycle > 0);
    final double topPaddingForTimer = (theme.textTheme.headlineSmall?.fontSize ?? 24.0) + 8.0 + (intervalHasCycleText ? (theme.textTheme.titleMedium?.fontSize ?? 16.0) + 6.0 : 0.0);


    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: topPaddingForTimer), // Espacio para alinear verticalmente
        GestureDetector(
          onTap: _isTimerActive && !_isTimerPaused ? null : _selectTimerDurationDialog,
          child: Text( _formatDuration(_isTimerActive ? _timerRemainingDuration : _timerInitialDuration, showHoursForce: _timerInitialDuration.inHours > 0), style: theme.textTheme.displayLarge?.copyWith( fontFamily: '.SF UI Display', fontWeight: FontWeight.w200, letterSpacing: 2.0, color: (_isTimerActive && _timerRemainingDuration > Duration.zero) || (!_isTimerActive && _timerInitialDuration > Duration.zero) ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5), fontFeatures: const [FontFeature.tabularFigures()], ), ),
        ),
        const SizedBox(height: 24), // Espacio entre el tiempo y el círculo (consistente con Intervals)
        SizedBox(
          width: 220, height: 220,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _timerProgressController,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _timerProgressController.value,
                    strokeWidth: 14,
                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
              Center(
                child: Icon( _isTimerActive && !_isTimerPaused ? Icons.hourglass_bottom_rounded : (_timerInitialDuration == Duration.zero ? Icons.timer_off_outlined : Icons.hourglass_top_rounded), size: 70, color: theme.colorScheme.primary.withOpacity( (_isTimerActive && _timerRemainingDuration > Duration.zero) || (!_isTimerActive && _timerInitialDuration > Duration.zero) ? 0.7 : 0.4 ), ),
              ),
            ],
          ),
        ),
        // Espacio inferior para mantener el bloque centrado en el flex
        SizedBox(height: topPaddingForTimer > 24 ? 0 : 24 - topPaddingForTimer),
      ],
    );
  }

  Widget _buildTimerControls(AppLocalizations localizations, ThemeData theme, {Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: _controlButtonRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Izquierda: Botón "Settings" (antes "Edit")
              _TimerControlButton(
                icon: Icons.tune_rounded, // Icono de Settings
                label: localizations.settingsLabel, // Etiqueta de Settings
                theme: theme,
                onPressed: (_isTimerActive && !_isTimerPaused) ? null : _selectTimerDurationDialog, // Sigue llamando a la función de duración
              ),
              _TimerControlButton( icon: _isTimerActive && !_isTimerPaused ? Icons.pause_rounded : Icons.play_arrow_rounded, label: _isTimerActive && !_isTimerPaused ? localizations.pauseLabel : (_isTimerPaused ? localizations.resumeLabel : localizations.startLabel), onPressed: _timerInitialDuration == Duration.zero ? null : _toggleTimer, isPrimary: true, theme: theme ),
              _TimerControlButton( icon: Icons.replay_rounded, label: localizations.resetLabel, theme: theme, onPressed: (_isTimerActive || _timerRemainingDuration != _timerInitialDuration) ? () => _resetTimer(resetInitialDuration: false) : null ),
            ],
          ),
        ),
      ],
    );
  }

  // INTERVALS
  Widget _buildIntervalsTimeDisplay(AppLocalizations localizations, ThemeData theme, {Key? key}) {
    String currentModeLabel = _isIntervalWorkTime ? localizations.pomodoroSessionWork : (_intervalCurrentSegmentInitialDuration == _intervalLongBreakDuration && _intervalLongBreakDuration > Duration.zero ? localizations.pomodoroSessionLongBreak : localizations.pomodoroSessionShortBreak);
    String cycleText = "";
    if (_intervalCyclesBeforeLongBreak > 0 && (_isIntervalTimerActive || _currentIntervalCycle > 0)) {
      int displayCycle = _currentIntervalCycle > 0 ? _currentIntervalCycle : 1;
      cycleText = localizations.pomodoroCycleInfo(displayCycle, _intervalCyclesBeforeLongBreak);
    }
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text( currentModeLabel, style: theme.textTheme.headlineSmall?.copyWith( color: _isIntervalWorkTime ? theme.colorScheme.primary : theme.colorScheme.secondary, fontWeight: FontWeight.w600 ),),
        const SizedBox(height: 8),
        Text( _formatDuration(_intervalCurrentSegmentRemainingDuration, showHoursForce: _intervalCurrentSegmentInitialDuration.inHours > 0), style: theme.textTheme.displayLarge?.copyWith( fontFamily: '.SF UI Display', fontWeight: FontWeight.w200, letterSpacing: 2.0, color: (_isIntervalTimerActive && _intervalCurrentSegmentRemainingDuration > Duration.zero) || (!_isIntervalTimerActive && _intervalWorkDuration > Duration.zero) ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5), fontFeatures: const [FontFeature.tabularFigures()], ),),
        if (cycleText.isNotEmpty) Padding( padding: const EdgeInsets.only(top: 6.0), child: Text( cycleText, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500), ),),
        const SizedBox(height: 24), // Espacio entre tiempo/ciclo y círculo
        SizedBox(
          width: 220, height: 220,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _intervalProgressController,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _intervalProgressController.value,
                    strokeWidth: 14,
                    backgroundColor: (_isIntervalWorkTime ? theme.colorScheme.primaryContainer : theme.colorScheme.secondaryContainer).withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(_isIntervalWorkTime ? theme.colorScheme.primary : theme.colorScheme.secondary),
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
              Center(
                child: Icon( _isIntervalTimerActive && !_isIntervalTimerPaused ? (_isIntervalWorkTime ? Icons.auto_stories_outlined : Icons.emoji_food_beverage_outlined) : (_intervalWorkDuration == Duration.zero ? Icons.settings_suggest_outlined : Icons.hourglass_top_rounded), size: 70, color: (_isIntervalWorkTime ? theme.colorScheme.primary : theme.colorScheme.secondary).withOpacity( (_isIntervalTimerActive && _intervalCurrentSegmentRemainingDuration > Duration.zero) || (!_isIntervalTimerActive && _intervalWorkDuration > Duration.zero) ? 0.7 : 0.4 ),),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalsControls(AppLocalizations localizations, ThemeData theme, {Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: _controlButtonRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _TimerControlButton(icon: Icons.tune_rounded, label: localizations.settingsLabel, theme: theme, onPressed: (_isIntervalTimerActive && !_isIntervalTimerPaused) ? null : _selectIntervalSettingsDialog),
              _TimerControlButton(icon: _isIntervalTimerActive && !_isIntervalTimerPaused ? Icons.pause_rounded : Icons.play_arrow_rounded, label: _isIntervalTimerActive && !_isIntervalTimerPaused ? localizations.pauseLabel : (_isIntervalTimerPaused ? localizations.resumeLabel : localizations.startLabel), onPressed: _intervalWorkDuration == Duration.zero ? null : _toggleIntervalTimer, isPrimary: true, theme: theme, primaryColorOverride: _isIntervalWorkTime ? null : theme.colorScheme.secondary),
              _TimerControlButton(icon: Icons.replay_rounded, label: localizations.resetLabel, theme: theme, onPressed: (_isIntervalTimerActive || _currentIntervalCycle != 0) ? () => _resetIntervalTimer(resetConfig: false) : null),
            ],
          ),
        ),
      ],
    );
  }
}

// _TimerControlButton (Sin cambios)
class _TimerControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final ThemeData theme;
  final Color? primaryColorOverride;

  const _TimerControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    required this.theme,
    this.primaryColorOverride,
    super.key
  });

  static const double buttonWidgetWidth = 72.0;

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor = primaryColorOverride ?? theme.colorScheme.primary;
    final Color foregroundColor = isPrimary ? theme.colorScheme.onPrimary : (onPressed != null ? effectivePrimaryColor : theme.colorScheme.onSurface.withOpacity(0.38));
    final Color backgroundColor = isPrimary ? effectivePrimaryColor : theme.colorScheme.surfaceVariant;
    final double iconSize = isPrimary ? 32.0 : 26.0;

    return SizedBox(
      width: buttonWidgetWidth,
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
                elevation: isPrimary ? 4.0 : 1.5,
                shadowColor: theme.colorScheme.shadow.withOpacity(isPrimary ? 0.3 : 0.15),
                disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.3),
              ).copyWith(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) { return (isPrimary ? theme.colorScheme.onPrimary : effectivePrimaryColor).withOpacity(0.12); }
                    if (states.contains(MaterialState.hovered)) { return (isPrimary ? theme.colorScheme.onPrimary : effectivePrimaryColor).withOpacity(0.08); }
                    return null;
                  },
                ),
              ),
              child: Icon(icon, size: iconSize),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onPressed != null ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}