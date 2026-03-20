import 'package:gabits/generated/l10n/app_localizations.dart';

/// Returns a human-readable schedule string for a given list of day indexes.
/// Day indexes: 0 = Sunday, 1 = Monday, ..., 6 = Saturday.
String formatScheduleString(
    List<int> scheduleDays, AppLocalizations localizations) {
  if (scheduleDays.length == 7) return localizations.everyDay;

  final dayNames = scheduleDays.map((dayIndex) {
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
  });

  return dayNames.where((s) => s.isNotEmpty).join(', ');
}
