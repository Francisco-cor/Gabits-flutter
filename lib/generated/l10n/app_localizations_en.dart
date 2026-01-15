// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeScreenTitle => 'Routine Manager';

  @override
  String get myHabits => 'My Habits';

  @override
  String get myNotes => 'My Notes';

  @override
  String get diary => 'Diary';

  @override
  String get routineSectionTitle => 'Daily Routine';

  @override
  String get today => 'Today';

  @override
  String get startsIn => 'Starts in';

  @override
  String get newButtonLabel => 'New';

  @override
  String get newHabitOption => 'New Habit';

  @override
  String get newNoteOption => 'New Note';

  @override
  String get newDiaryEntryOption => 'New Diary Entry';

  @override
  String get newHabitTitle => 'New Habit';

  @override
  String get newNoteTitle => 'New Note';

  @override
  String get newDiaryEntryTitle => 'New Diary Entry';

  @override
  String get habitNameLabel => 'Habit name';

  @override
  String get habitNameHint => 'Enter habit name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => '(optional)';

  @override
  String get goalTypeLabel => 'Type of goal';

  @override
  String get goalTypeYesNo => 'Yes or No';

  @override
  String get goalTypeTime => 'Time';

  @override
  String get goalTypeQuantity => 'Quantity';

  @override
  String get timeLabel => 'Time';

  @override
  String get timeHint => 'Enter time (e.g., 60 for minutes)';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get quantityHint => 'Enter quantity (e.g., 10 for pages)';

  @override
  String get colorLabel => 'Color';

  @override
  String get scheduleLabel => 'Schedule';

  @override
  String get sundayShort => 'S';

  @override
  String get mondayShort => 'M';

  @override
  String get tuesdayShort => 'T';

  @override
  String get wednesdayShort => 'W';

  @override
  String get thursdayShort => 'T';

  @override
  String get fridayShort => 'F';

  @override
  String get saturdayShort => 'S';

  @override
  String get hourLabel => 'Hour';

  @override
  String get selectColor => 'Select Color';

  @override
  String get done => 'Done';

  @override
  String get selectTime => 'Select Time';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get habitNameRequired => 'Habit name is required.';

  @override
  String get habitGoalValueRequired =>
      'Goal value is required for Time/Quantity goals.';

  @override
  String get habitGoalValueInvalid => 'Goal value must be a valid number.';

  @override
  String get habitScheduleRequired =>
      'At least one day must be selected for the schedule.';

  @override
  String get passedStatus => 'Passed';

  @override
  String get noHabitsToday => 'Nothing here for today!';

  @override
  String get startsNowStatus => 'Starts now!';

  @override
  String get tapPlusToAddHabit => 'Tap \'+\' to add a new habit for today.';

  @override
  String get editButtonLabel => 'Edit';

  @override
  String get deleteButtonLabel => 'Delete';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete \'%s\'? This action cannot be undone.';

  @override
  String get noHabitsYet => 'No habits created yet.';

  @override
  String get tapPlusToCreateOne => 'Tap \'+\' to create your first habit!';

  @override
  String get everyDay => 'Every day';

  @override
  String get doneButtonLabel => 'Done';

  @override
  String get noteTitleLabel => 'Title';

  @override
  String get noteTitleHint => 'Enter note title';

  @override
  String get noteContentLabel => 'Content';

  @override
  String get noteContentHint => 'Start writing your note...';

  @override
  String get saveButtonLabel => 'Done';

  @override
  String get noteTitleRequired => 'Note title cannot be empty';

  @override
  String get noteContentRequired => 'Note content cannot be empty';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get tapPlusToCreateOneNote => 'Tap \'+\' to create your first note';

  @override
  String get addBulletedList => 'Bulleted List';

  @override
  String get addNumberedList => 'Numbered List';

  @override
  String get addCheckboxList => 'Checkbox List';

  @override
  String get changeTextColor => 'Text Color';

  @override
  String get insertTable => 'Insert Table (Basic)';

  @override
  String get textFormattingTooltip => 'Text Formatting';

  @override
  String get boldLabel => 'Bold';

  @override
  String get italicLabel => 'Italic';

  @override
  String get underlineLabel => 'Underline';

  @override
  String get strikethroughLabel => 'Strikethrough';

  @override
  String get listAndBlockStylesTooltip => 'List & Block Styles';

  @override
  String get headerStylesLabel => 'Header Styles';

  @override
  String get normalTextLabel => 'Normal Text';

  @override
  String get heading1Label => 'Heading 1';

  @override
  String get heading2Label => 'Heading 2';

  @override
  String get heading3Label => 'Heading 3';

  @override
  String get blockquoteLabel => 'Blockquote';

  @override
  String get codeBlockLabel => 'Code Block';

  @override
  String get indentIncreaseLabel => 'Increase Indent';

  @override
  String get indentDecreaseLabel => 'Decrease Indent';

  @override
  String get colorAndClearTooltip => 'Color & Clear';

  @override
  String get clearFormattingLabel => 'Clear Formatting';

  @override
  String get timerScreenTitle => 'Time Management';

  @override
  String get stopwatchMode => 'Stopwatch';

  @override
  String get timerMode => 'Timer';

  @override
  String get intervalsMode => 'Intervals';

  @override
  String get startLabel => 'Start';

  @override
  String get pauseLabel => 'Pause';

  @override
  String get resumeLabel => 'Resume';

  @override
  String get resetLabel => 'Reset';

  @override
  String get lapLabel => 'Lap';

  @override
  String get lapsHeader => 'Laps';

  @override
  String lapItem(int number) {
    return 'Lap $number';
  }

  @override
  String get setDurationPrompt => 'Set Duration';

  @override
  String get editDurationPrompt => 'Edit';

  @override
  String get hoursShort => 'H';

  @override
  String get minutesShortForm => 'M';

  @override
  String get secondsShort => 'S';

  @override
  String get timerFinishedTitle => 'Time\'s Up!';

  @override
  String get timerFinishedMessage => 'Your timer has finished.';

  @override
  String get timerDurationCannotBeZero => 'Timer duration cannot be zero.';

  @override
  String get timerDurationCannotBeZeroWork => 'Work duration cannot be zero.';

  @override
  String get configurePomodoroTitle => 'Configure Intervals';

  @override
  String get workDurationLabel => 'Work (min)';

  @override
  String get shortBreakDurationLabel => 'Short Break (min)';

  @override
  String get longBreakDurationLabel => 'Long Break (min)';

  @override
  String get cyclesBeforeLongBreakLabel => 'Cycles before Long Break';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get pomodoroSessionWork => 'Work Session';

  @override
  String get pomodoroSessionShortBreak => 'Short Break';

  @override
  String get pomodoroSessionLongBreak => 'Long Break';

  @override
  String get skipIntervalLabel => 'Skip';

  @override
  String pomodoroCycleInfo(int currentCycle, int totalCycles) {
    return 'Cycle $currentCycle of $totalCycles';
  }

  @override
  String get intervalCyclesFinishedTitle => 'Intervals Finished!';

  @override
  String get intervalCyclesFinishedMessage =>
      'All interval cycles are complete!';

  @override
  String pomodoroNextUp(String intervalName) {
    return 'Next: $intervalName';
  }

  @override
  String get comingSoon => 'Coming Soon!';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get minutesShort => 'min';

  @override
  String get selectADay => 'Select a day';

  @override
  String get noHabitsForThisDay => 'No habits scheduled for this day.';

  @override
  String get selectAnotherDayOrAdd => 'Select another day or add new habits.';

  @override
  String nHabits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits',
      one: '1 habit',
      zero: 'No habits',
    );
    return '$_temp0';
  }

  @override
  String get noDataAvailable => 'No laps yet.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String passedDaysAgo(int days) {
    return 'Passed ${days}d ago';
  }

  @override
  String passedHoursAgo(int hours) {
    return 'Passed ${hours}h ago';
  }

  @override
  String get markedAsDone => 'marked as done';

  @override
  String get markedAsNotDone => 'marked as not done';

  @override
  String get markAsDone => 'Mark as done';

  @override
  String get created => 'Created';

  @override
  String get updated => 'Updated';

  @override
  String get viewMyDiary => 'View My Diary';

  @override
  String diaryEntryForDate(String date) {
    return 'Entry for $date';
  }

  @override
  String get noDiaryEntryForThisDay => 'No diary entry for this day.';

  @override
  String get selectAnotherDayOrViewDiary =>
      'Select another day or view your diary history in the calendar.';

  @override
  String get diarySaved => 'Diary entry saved.';

  @override
  String diaryFor(String date) {
    return 'Diary for $date';
  }

  @override
  String get emptyDiaryEntryPlaceholder =>
      'Start writing your diary for today...';
}
