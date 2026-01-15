import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gabits/timer_screen.dart';

part 'timer_provider.g.dart';

class TimerState {
  final TimerModeType selectedMode;
  final String stopwatchFormattedTime;
  final List<String> laps;
  final Duration timerInitialDuration;
  final Duration timerRemainingDuration;
  final bool isTimerActive;
  final bool isTimerPaused;
  final Duration intervalWorkDuration;
  final Duration intervalBreakDuration;
  final Duration intervalLongBreakDuration;
  final int intervalCyclesBeforeLongBreak;
  final int currentIntervalCycle;
  final bool isIntervalWorkTime;
  final bool isIntervalTimerActive;
  final bool isIntervalTimerPaused;
  final Duration intervalCurrentSegmentRemainingDuration;
  final Duration intervalCurrentSegmentInitialDuration;

  TimerState({
    this.selectedMode = TimerModeType.stopwatch,
    this.stopwatchFormattedTime = "00:00:00.00",
    this.laps = const [],
    this.timerInitialDuration = const Duration(minutes: 5),
    this.timerRemainingDuration = const Duration(minutes: 5),
    this.isTimerActive = false,
    this.isTimerPaused = false,
    this.intervalWorkDuration = const Duration(minutes: 25),
    this.intervalBreakDuration = const Duration(minutes: 5),
    this.intervalLongBreakDuration = const Duration(minutes: 15),
    this.intervalCyclesBeforeLongBreak = 4,
    this.currentIntervalCycle = 0,
    this.isIntervalWorkTime = true,
    this.isIntervalTimerActive = false,
    this.isIntervalTimerPaused = false,
    this.intervalCurrentSegmentRemainingDuration = const Duration(minutes: 25),
    this.intervalCurrentSegmentInitialDuration = const Duration(minutes: 25),
  });

  TimerState copyWith({
    TimerModeType? selectedMode,
    String? stopwatchFormattedTime,
    List<String>? laps,
    Duration? timerInitialDuration,
    Duration? timerRemainingDuration,
    bool? isTimerActive,
    bool? isTimerPaused,
    Duration? intervalWorkDuration,
    Duration? intervalBreakDuration,
    Duration? intervalLongBreakDuration,
    int? intervalCyclesBeforeLongBreak,
    int? currentIntervalCycle,
    bool? isIntervalWorkTime,
    bool? isIntervalTimerActive,
    bool? isIntervalTimerPaused,
    Duration? intervalCurrentSegmentRemainingDuration,
    Duration? intervalCurrentSegmentInitialDuration,
  }) {
    return TimerState(
      selectedMode: selectedMode ?? this.selectedMode,
      stopwatchFormattedTime:
          stopwatchFormattedTime ?? this.stopwatchFormattedTime,
      laps: laps ?? this.laps,
      timerInitialDuration: timerInitialDuration ?? this.timerInitialDuration,
      timerRemainingDuration:
          timerRemainingDuration ?? this.timerRemainingDuration,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      isTimerPaused: isTimerPaused ?? this.isTimerPaused,
      intervalWorkDuration: intervalWorkDuration ?? this.intervalWorkDuration,
      intervalBreakDuration:
          intervalBreakDuration ?? this.intervalBreakDuration,
      intervalLongBreakDuration:
          intervalLongBreakDuration ?? this.intervalLongBreakDuration,
      intervalCyclesBeforeLongBreak:
          intervalCyclesBeforeLongBreak ?? this.intervalCyclesBeforeLongBreak,
      currentIntervalCycle: currentIntervalCycle ?? this.currentIntervalCycle,
      isIntervalWorkTime: isIntervalWorkTime ?? this.isIntervalWorkTime,
      isIntervalTimerActive:
          isIntervalTimerActive ?? this.isIntervalTimerActive,
      isIntervalTimerPaused:
          isIntervalTimerPaused ?? this.isIntervalTimerPaused,
      intervalCurrentSegmentRemainingDuration:
          intervalCurrentSegmentRemainingDuration ??
              this.intervalCurrentSegmentRemainingDuration,
      intervalCurrentSegmentInitialDuration:
          intervalCurrentSegmentInitialDuration ??
              this.intervalCurrentSegmentInitialDuration,
    );
  }
}

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _stopwatchTimer;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _countdownTimerInstance;
  Timer? _intervalInstance;

  @override
  TimerState build() {
    ref.onDispose(() {
      _stopwatchTimer?.cancel();
      _countdownTimerInstance?.cancel();
      _intervalInstance?.cancel();
    });
    return TimerState();
  }

  void setMode(TimerModeType mode) {
    resetStopwatch();
    resetTimer(resetInitialDuration: false);
    resetIntervalTimer(resetConfig: false);
    state = state.copyWith(selectedMode: mode);
  }

  // Stopwatch Logic
  void toggleStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _stopwatchTimer?.cancel();
    } else {
      _stopwatch.start();
      _stopwatchTimer =
          Timer.periodic(const Duration(milliseconds: 33), (timer) {
        _updateStopwatchDisplay();
      });
    }
    state = state.copyWith(); // Trigger rebuild for isRunning status if needed
  }

  void _updateStopwatchDisplay() {
    final ms = _stopwatch.elapsedMilliseconds;
    final hundreds = (ms % 1000) ~/ 10;
    final seconds = (ms ~/ 1000) % 60;
    final minutes = (ms ~/ (1000 * 60)) % 60;
    final hours = (ms ~/ (1000 * 60 * 60));
    state = state.copyWith(
      stopwatchFormattedTime:
          "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}",
    );
  }

  void resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
    _stopwatchTimer?.cancel();
    state = state.copyWith(
      laps: [],
      stopwatchFormattedTime: "00:00:00.00",
    );
  }

  void addLap(String lapText) {
    state = state.copyWith(laps: [lapText, ...state.laps]);
  }

  // Timer Logic
  void setTimerDuration(Duration duration) {
    state = state.copyWith(
      timerInitialDuration: duration,
      timerRemainingDuration: duration,
    );
  }

  void toggleTimer(void Function() onFinished) {
    if (state.timerInitialDuration == Duration.zero) return;
    if (state.isTimerActive) {
      if (state.isTimerPaused) {
        state = state.copyWith(isTimerPaused: false);
        _startCountdown(onFinished);
      } else {
        state = state.copyWith(isTimerPaused: true);
        _countdownTimerInstance?.cancel();
      }
    } else {
      state = state.copyWith(
        isTimerActive: true,
        isTimerPaused: false,
        timerRemainingDuration: state.timerInitialDuration,
      );
      _startCountdown(onFinished);
    }
  }

  void _startCountdown(void Function() onFinished) {
    _countdownTimerInstance?.cancel();
    _countdownTimerInstance =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerRemainingDuration.inSeconds > 0) {
        state = state.copyWith(
          timerRemainingDuration:
              state.timerRemainingDuration - const Duration(seconds: 1),
        );
      } else {
        _timerFinished(onFinished);
      }
    });
  }

  void _timerFinished(void Function() onFinished) {
    _countdownTimerInstance?.cancel();
    state = state.copyWith(
      isTimerActive: false,
      isTimerPaused: false,
      timerRemainingDuration: state.timerInitialDuration,
    );
    onFinished();
  }

  void resetTimer({bool resetInitialDuration = true}) {
    _countdownTimerInstance?.cancel();
    state = state.copyWith(
      isTimerActive: false,
      isTimerPaused: false,
      timerInitialDuration: resetInitialDuration
          ? const Duration(minutes: 5)
          : state.timerInitialDuration,
      timerRemainingDuration: resetInitialDuration
          ? const Duration(minutes: 5)
          : state.timerInitialDuration,
    );
  }

  // Interval Logic
  void setIntervalConfig(
      {Duration? work,
      Duration? breakDuration,
      Duration? longBreak,
      int? cycles}) {
    state = state.copyWith(
      intervalWorkDuration: work,
      intervalBreakDuration: breakDuration,
      intervalLongBreakDuration: longBreak,
      intervalCyclesBeforeLongBreak: cycles,
      intervalCurrentSegmentRemainingDuration:
          work ?? state.intervalWorkDuration,
      intervalCurrentSegmentInitialDuration: work ?? state.intervalWorkDuration,
    );
  }

  void toggleIntervalTimer(
      void Function() onSegmentFinished, void Function() onAllFinished) {
    if (state.intervalWorkDuration == Duration.zero) return;
    if (state.isIntervalTimerActive) {
      if (state.isIntervalTimerPaused) {
        state = state.copyWith(isIntervalTimerPaused: false);
        _startIntervalCountdown(onSegmentFinished, onAllFinished);
      } else {
        state = state.copyWith(isIntervalTimerPaused: true);
        _intervalInstance?.cancel();
      }
    } else {
      state = state.copyWith(
        isIntervalTimerActive: true,
        isIntervalTimerPaused: false,
        currentIntervalCycle: 1,
        isIntervalWorkTime: true,
        intervalCurrentSegmentInitialDuration: state.intervalWorkDuration,
        intervalCurrentSegmentRemainingDuration: state.intervalWorkDuration,
      );
      _startIntervalCountdown(onSegmentFinished, onAllFinished);
    }
  }

  void _startIntervalCountdown(
      void Function() onSegmentFinished, void Function() onAllFinished) {
    _intervalInstance?.cancel();
    _intervalInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.intervalCurrentSegmentRemainingDuration.inSeconds > 0) {
        state = state.copyWith(
          intervalCurrentSegmentRemainingDuration:
              state.intervalCurrentSegmentRemainingDuration -
                  const Duration(seconds: 1),
        );
      } else {
        _intervalSegmentFinished(onSegmentFinished, onAllFinished);
      }
    });
  }

  void _intervalSegmentFinished(
      void Function() onSegmentFinished, void Function() onAllFinished) {
    onSegmentFinished();

    if (state.isIntervalWorkTime) {
      final isLongBreak =
          state.currentIntervalCycle >= state.intervalCyclesBeforeLongBreak &&
              state.intervalLongBreakDuration > Duration.zero;
      state = state.copyWith(
        isIntervalWorkTime: false,
        intervalCurrentSegmentInitialDuration: isLongBreak
            ? state.intervalLongBreakDuration
            : state.intervalBreakDuration,
        intervalCurrentSegmentRemainingDuration: isLongBreak
            ? state.intervalLongBreakDuration
            : state.intervalBreakDuration,
      );
    } else {
      bool wasLongBreak = state.intervalCurrentSegmentInitialDuration ==
          state.intervalLongBreakDuration;
      if (wasLongBreak) {
        state = state.copyWith(
          isIntervalWorkTime: true,
          currentIntervalCycle: 1,
          intervalCurrentSegmentInitialDuration: state.intervalWorkDuration,
          intervalCurrentSegmentRemainingDuration: state.intervalWorkDuration,
        );
      } else {
        final newCycle = state.currentIntervalCycle + 1;
        if (newCycle > state.intervalCyclesBeforeLongBreak) {
          resetIntervalTimer(resetConfig: false);
          onAllFinished();
          return;
        }
        state = state.copyWith(
          isIntervalWorkTime: true,
          currentIntervalCycle: newCycle,
          intervalCurrentSegmentInitialDuration: state.intervalWorkDuration,
          intervalCurrentSegmentRemainingDuration: state.intervalWorkDuration,
        );
      }
    }

    if (state.intervalCurrentSegmentInitialDuration > Duration.zero) {
      _startIntervalCountdown(onSegmentFinished, onAllFinished);
    } else {
      resetIntervalTimer(resetConfig: false);
    }
  }

  void resetIntervalTimer({bool resetConfig = true}) {
    _intervalInstance?.cancel();
    state = state.copyWith(
      isIntervalTimerActive: false,
      isIntervalTimerPaused: false,
      currentIntervalCycle: 0,
      isIntervalWorkTime: true,
      intervalWorkDuration: resetConfig
          ? const Duration(minutes: 25)
          : state.intervalWorkDuration,
      intervalBreakDuration: resetConfig
          ? const Duration(minutes: 5)
          : state.intervalBreakDuration,
      intervalLongBreakDuration: resetConfig
          ? const Duration(minutes: 15)
          : state.intervalLongBreakDuration,
      intervalCyclesBeforeLongBreak:
          resetConfig ? 4 : state.intervalCyclesBeforeLongBreak,
      intervalCurrentSegmentRemainingDuration: resetConfig
          ? const Duration(minutes: 25)
          : state.intervalWorkDuration,
      intervalCurrentSegmentInitialDuration: resetConfig
          ? const Duration(minutes: 25)
          : state.intervalWorkDuration,
    );
  }
}
