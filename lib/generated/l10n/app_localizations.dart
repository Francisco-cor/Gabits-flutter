import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine Manager'**
  String get homeScreenTitle;

  /// No description provided for @myHabits.
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get myHabits;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// No description provided for @routineSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get routineSectionTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'Starts in'**
  String get startsIn;

  /// No description provided for @newButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newButtonLabel;

  /// No description provided for @newHabitOption.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabitOption;

  /// No description provided for @newNoteOption.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNoteOption;

  /// No description provided for @newDiaryEntryOption.
  ///
  /// In en, this message translates to:
  /// **'New Diary Entry'**
  String get newDiaryEntryOption;

  /// No description provided for @newHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabitTitle;

  /// No description provided for @newNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNoteTitle;

  /// No description provided for @newDiaryEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Diary Entry'**
  String get newDiaryEntryTitle;

  /// No description provided for @habitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitNameLabel;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter habit name'**
  String get habitNameHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get descriptionHint;

  /// No description provided for @goalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type of goal'**
  String get goalTypeLabel;

  /// No description provided for @goalTypeYesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes or No'**
  String get goalTypeYesNo;

  /// No description provided for @goalTypeTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get goalTypeTime;

  /// No description provided for @goalTypeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get goalTypeQuantity;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @timeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter time (e.g., 60 for minutes)'**
  String get timeHint;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity (e.g., 10 for pages)'**
  String get quantityHint;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleLabel;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sundayShort;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturdayShort;

  /// No description provided for @hourLabel.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hourLabel;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @habitNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Habit name is required.'**
  String get habitNameRequired;

  /// No description provided for @habitGoalValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Goal value is required for Time/Quantity goals.'**
  String get habitGoalValueRequired;

  /// No description provided for @habitGoalValueInvalid.
  ///
  /// In en, this message translates to:
  /// **'Goal value must be a valid number.'**
  String get habitGoalValueInvalid;

  /// No description provided for @habitScheduleRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one day must be selected for the schedule.'**
  String get habitScheduleRequired;

  /// No description provided for @passedStatus.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passedStatus;

  /// No description provided for @noHabitsToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing here for today!'**
  String get noHabitsToday;

  /// No description provided for @startsNowStatus.
  ///
  /// In en, this message translates to:
  /// **'Starts now!'**
  String get startsNowStatus;

  /// No description provided for @tapPlusToAddHabit.
  ///
  /// In en, this message translates to:
  /// **'Tap \'+\' to add a new habit for today.'**
  String get tapPlusToAddHabit;

  /// No description provided for @editButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButtonLabel;

  /// No description provided for @deleteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonLabel;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'%s\'? This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits created yet.'**
  String get noHabitsYet;

  /// No description provided for @tapPlusToCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Tap \'+\' to create your first habit!'**
  String get tapPlusToCreateOne;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @doneButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButtonLabel;

  /// No description provided for @noteTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleLabel;

  /// No description provided for @noteTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note title'**
  String get noteTitleHint;

  /// No description provided for @noteContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get noteContentLabel;

  /// No description provided for @noteContentHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing your note...'**
  String get noteContentHint;

  /// No description provided for @saveButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get saveButtonLabel;

  /// No description provided for @noteTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Note title cannot be empty'**
  String get noteTitleRequired;

  /// No description provided for @noteContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Note content cannot be empty'**
  String get noteContentRequired;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// No description provided for @tapPlusToCreateOneNote.
  ///
  /// In en, this message translates to:
  /// **'Tap \'+\' to create your first note'**
  String get tapPlusToCreateOneNote;

  /// No description provided for @addBulletedList.
  ///
  /// In en, this message translates to:
  /// **'Bulleted List'**
  String get addBulletedList;

  /// No description provided for @addNumberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get addNumberedList;

  /// No description provided for @addCheckboxList.
  ///
  /// In en, this message translates to:
  /// **'Checkbox List'**
  String get addCheckboxList;

  /// No description provided for @changeTextColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get changeTextColor;

  /// No description provided for @insertTable.
  ///
  /// In en, this message translates to:
  /// **'Insert Table (Basic)'**
  String get insertTable;

  /// No description provided for @textFormattingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text Formatting'**
  String get textFormattingTooltip;

  /// No description provided for @boldLabel.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get boldLabel;

  /// No description provided for @italicLabel.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italicLabel;

  /// No description provided for @underlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underlineLabel;

  /// No description provided for @strikethroughLabel.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get strikethroughLabel;

  /// No description provided for @listAndBlockStylesTooltip.
  ///
  /// In en, this message translates to:
  /// **'List & Block Styles'**
  String get listAndBlockStylesTooltip;

  /// No description provided for @headerStylesLabel.
  ///
  /// In en, this message translates to:
  /// **'Header Styles'**
  String get headerStylesLabel;

  /// No description provided for @normalTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Normal Text'**
  String get normalTextLabel;

  /// No description provided for @heading1Label.
  ///
  /// In en, this message translates to:
  /// **'Heading 1'**
  String get heading1Label;

  /// No description provided for @heading2Label.
  ///
  /// In en, this message translates to:
  /// **'Heading 2'**
  String get heading2Label;

  /// No description provided for @heading3Label.
  ///
  /// In en, this message translates to:
  /// **'Heading 3'**
  String get heading3Label;

  /// No description provided for @blockquoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Blockquote'**
  String get blockquoteLabel;

  /// No description provided for @codeBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Code Block'**
  String get codeBlockLabel;

  /// No description provided for @indentIncreaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Increase Indent'**
  String get indentIncreaseLabel;

  /// No description provided for @indentDecreaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Decrease Indent'**
  String get indentDecreaseLabel;

  /// No description provided for @colorAndClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Color & Clear'**
  String get colorAndClearTooltip;

  /// No description provided for @clearFormattingLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Formatting'**
  String get clearFormattingLabel;

  /// No description provided for @timerScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Management'**
  String get timerScreenTitle;

  /// No description provided for @stopwatchMode.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get stopwatchMode;

  /// No description provided for @timerMode.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerMode;

  /// No description provided for @intervalsMode.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get intervalsMode;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @pauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseLabel;

  /// No description provided for @resumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeLabel;

  /// No description provided for @resetLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLabel;

  /// No description provided for @lapLabel.
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get lapLabel;

  /// No description provided for @lapsHeader.
  ///
  /// In en, this message translates to:
  /// **'Laps'**
  String get lapsHeader;

  /// Label for a lap number
  ///
  /// In en, this message translates to:
  /// **'Lap {number}'**
  String lapItem(int number);

  /// No description provided for @setDurationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set Duration'**
  String get setDurationPrompt;

  /// No description provided for @editDurationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editDurationPrompt;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get hoursShort;

  /// No description provided for @minutesShortForm.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get minutesShortForm;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get secondsShort;

  /// No description provided for @timerFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get timerFinishedTitle;

  /// No description provided for @timerFinishedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your timer has finished.'**
  String get timerFinishedMessage;

  /// No description provided for @timerDurationCannotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Timer duration cannot be zero.'**
  String get timerDurationCannotBeZero;

  /// No description provided for @timerDurationCannotBeZeroWork.
  ///
  /// In en, this message translates to:
  /// **'Work duration cannot be zero.'**
  String get timerDurationCannotBeZeroWork;

  /// No description provided for @configurePomodoroTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Intervals'**
  String get configurePomodoroTitle;

  /// No description provided for @workDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Work (min)'**
  String get workDurationLabel;

  /// No description provided for @shortBreakDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Break (min)'**
  String get shortBreakDurationLabel;

  /// No description provided for @longBreakDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Long Break (min)'**
  String get longBreakDurationLabel;

  /// No description provided for @cyclesBeforeLongBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycles before Long Break'**
  String get cyclesBeforeLongBreakLabel;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @pomodoroSessionWork.
  ///
  /// In en, this message translates to:
  /// **'Work Session'**
  String get pomodoroSessionWork;

  /// No description provided for @pomodoroSessionShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get pomodoroSessionShortBreak;

  /// No description provided for @pomodoroSessionLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get pomodoroSessionLongBreak;

  /// No description provided for @skipIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipIntervalLabel;

  /// Current Pomodoro cycle information
  ///
  /// In en, this message translates to:
  /// **'Cycle {currentCycle} of {totalCycles}'**
  String pomodoroCycleInfo(int currentCycle, int totalCycles);

  /// No description provided for @intervalCyclesFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervals Finished!'**
  String get intervalCyclesFinishedTitle;

  /// No description provided for @intervalCyclesFinishedMessage.
  ///
  /// In en, this message translates to:
  /// **'All interval cycles are complete!'**
  String get intervalCyclesFinishedMessage;

  /// Label for the next Pomodoro interval
  ///
  /// In en, this message translates to:
  /// **'Next: {intervalName}'**
  String pomodoroNextUp(String intervalName);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!'**
  String get comingSoon;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @selectADay.
  ///
  /// In en, this message translates to:
  /// **'Select a day'**
  String get selectADay;

  /// No description provided for @noHabitsForThisDay.
  ///
  /// In en, this message translates to:
  /// **'No habits scheduled for this day.'**
  String get noHabitsForThisDay;

  /// No description provided for @selectAnotherDayOrAdd.
  ///
  /// In en, this message translates to:
  /// **'Select another day or add new habits.'**
  String get selectAnotherDayOrAdd;

  /// Number of habits for a selected day
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No habits} =1{1 habit} other{{count} habits}}'**
  String nHabits(int count);

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No laps yet.'**
  String get noDataAvailable;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Indicates how many days ago a habit passed
  ///
  /// In en, this message translates to:
  /// **'Passed {days}d ago'**
  String passedDaysAgo(int days);

  /// Indicates how many hours ago a habit passed
  ///
  /// In en, this message translates to:
  /// **'Passed {hours}h ago'**
  String passedHoursAgo(int hours);

  /// No description provided for @markedAsDone.
  ///
  /// In en, this message translates to:
  /// **'marked as done'**
  String get markedAsDone;

  /// No description provided for @markedAsNotDone.
  ///
  /// In en, this message translates to:
  /// **'marked as not done'**
  String get markedAsNotDone;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markAsDone;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @viewMyDiary.
  ///
  /// In en, this message translates to:
  /// **'View My Diary'**
  String get viewMyDiary;

  /// Title for a diary entry popup, showing the date
  ///
  /// In en, this message translates to:
  /// **'Entry for {date}'**
  String diaryEntryForDate(String date);

  /// No description provided for @noDiaryEntryForThisDay.
  ///
  /// In en, this message translates to:
  /// **'No diary entry for this day.'**
  String get noDiaryEntryForThisDay;

  /// No description provided for @selectAnotherDayOrViewDiary.
  ///
  /// In en, this message translates to:
  /// **'Select another day or view your diary history in the calendar.'**
  String get selectAnotherDayOrViewDiary;

  /// No description provided for @diarySaved.
  ///
  /// In en, this message translates to:
  /// **'Diary entry saved.'**
  String get diarySaved;

  /// Title for the diary screen, showing the current date
  ///
  /// In en, this message translates to:
  /// **'Diary for {date}'**
  String diaryFor(String date);

  /// No description provided for @emptyDiaryEntryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Start writing your diary for today...'**
  String get emptyDiaryEntryPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
