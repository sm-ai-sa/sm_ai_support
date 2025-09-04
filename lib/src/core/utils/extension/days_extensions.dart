import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

// import "package:timeago/timeago.dart" as time_ago;

extension DateExtension on DateTime {
  static final DateTime today = DateTime.now();

  TimeOfDay get toTimeOfDay {
    return TimeOfDay(hour: hour, minute: minute);
  }

  ///* Return ```true``` if provided date is today but after current time
  bool get isTodayAfterNow => today.isToday && isAfter(DateTime(today.hour, today.minute));

  ///* Return ```true``` if provided date is today
  bool get isToday => today.day == day && today.month == month && today.year == year;

  ///* Return ```true``` if provided date is Tomorrow
  bool get isTomorrow => today.day + 1 == day && today.month == month && today.year == year;

  ///* Return ```true``` if provided date is after Tomorrow
  bool get isAfterTomorrow => today.day + 2 == day && today.month == month && today.year == year;

  ///* Return ```true``` if provided date is After now Hours
  bool get isAfterNowHours =>
      (hour > DateTime.now().hour || (hour == DateTime.now().hour && minute > DateTime.now().minute));

  bool get isAfterNow {
    bool isTodayAfterNow = isAfterNowHours;
    return isToday ? isTodayAfterNow : isAfter(today);
  }

  bool get isInCurrentWeek => today.difference(this).inDays < 7;

  int get age => today.difference(this).inDays ~/ 365;

  int get daysLeft => difference(today).inDays;

  DateTime get dayBefore => subtract(const Duration(days: 1));

  DateTime get dayAfter => add(const Duration(days: 1));

  ///* Days left from today
  int get daysLeftFromToday => daysLeft.isNegative ? 0 : daysLeft;

  ///* Return ```true``` if provided date is in same month of the today
  bool get isSubExpired => today.compareTo(this) == 1;

  ///* Check difference between 2 dates
  int get daysDifference => today.difference(this).inDays;

  /// Check if the hours diff
  int get hoursDifference => difference(today).inHours;

  ///* Check difference between 2 dates
  int daysDifferenceInDates(DateTime date) {
    int days = difference(date).inDays;
    smPrint("Days difference ${date.dmyFormat} == $dmyFormat ---> $days");
    return days;
  }

  bool isSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  ///* Return Day Name From Date [Saturday]
  String get dayName => DateFormat('EEEE', SMText.languageCode).format(this);

  int get weekDayIndex => weekday - 1;

  ///* Return Formatted time as `String` [12:05 PM]
  String get timeFormat => DateFormat.jm(SMText.languageCode).format(this);

  String get localTimeFormat => DateFormat.jm(SMText.languageCode).format(this);

  ///* Get [AM or PM]
  String get amOrPm => DateFormat('a').format(this);

  ///* Return Formatted time as `String` [12:05]
  String get hourAndMuintes => DateFormat('hh:mm').format(this);

  ///* Return Formatted time as `String` [25 July]
  String get dateMonthFormat => DateFormat.MMMMd(SMText.languageCode).format(this);

  ///* Return Formatted Day, Month, Year name as `String` [Sunday, 19 July 2022]
  String get dayMonthYearFormat => DateFormat.yMMMEd(SMText.languageCode).format(this);

  ///* Return Formatted Day, Month, Year name as `String` [Sunday, 19 July]
  String get dayMonthFormat => DateFormat.yMMMd(SMText.languageCode).format(this);

  ///* Return Formatted Time ago [1 minute ago]
  // String get timeAgoFormat =>
  //     time_ago.format(this, locale: SMText.languageCode);

  ///* Return Formatted Day, Month, Year name as `String` [19 July 2022]
  String get dateDayMonthYearFormat => DateFormat.yMMMd(SMText.languageCode).format(this);

  ///* Return Formatted Day, Month, Year name as `String` [July 2022]
  String get dateMonthYearFormat => DateFormat.yMMM(SMText.languageCode).format(this);

  ///* Return Formatted time as `String` [25 Jul]
  String get dateMonthShortFormat => DateFormat.MMMd(SMText.languageCode).format(this);

  ///* Return Formatted Day, Month, Year name as `String` [12:00 PM, 19 July 2022]
  String get fullDateTimeFormat => DateFormat(null, SMText.languageCode).add_MMMEd().add_jm().format(this);
  String get fullDateTimeFormatEnglish => DateFormat(null).add_MMMEd().add_jm().format(this);

  ///* Return Formatted Month, Year name as `String` [12-2023]
  String get graphDateFormat => DateFormat('MM-y').format(this);

  ///* Return Formatted Month, Year name as `String` [10-12-2023]
  String get dmyFormat => DateFormat('y-MM-dd').format(this);

  ///* Return Formatted Month, Year name as `String` [12/02/2023]
  String get dmySlashFormat => DateFormat('dd/MM/y').format(this);

  ///* Return Formatted Day as `String` [saturday]
  String get weekDayName => DateFormat('EEEE', SMText.languageCode).format(this);

  ///* Return Formatted Day as `String` [sat , mon , sun]
  String get weekDayShortName => DateFormat('EEE', SMText.languageCode).format(this);

  ///* Return Formatted Month, Year name as `String` [12]
  String get monthDay => DateFormat('dd').format(this);

  ///* Return Formatted time as `String` [25/10]
  String get dayMonthSlashFormat => DateFormat('dd/MM').format(this);

  ///* get difference between date and today like this [1 day ago] [1 month ago]

  //* to Our local time
  DateTime get toOurLocal => toLocal().subtract(const Duration(hours: 3));

  // String get dateUploadedToApi => toUtc().toIso8601String();
  // String get dateUploadedToApi => toIso8601String();
  String get dateUploadedToApi => toLocal().toIso8601String();

  String get monthNameFromDate {
    return DateFormat('MMMM', SMText.languageCode).format(this);
  }

  // check if date is between 2 dates
  bool isBetween(DateTime startDate, DateTime endDate) {
    return isAfter(startDate) && isBefore(endDate);
  }

  ///* Return Formatted Day, Month, Year name as `String` [01-03-2022]
  String get shortDateMonthYearFormat => DateFormat(
        "d-MM-y",
      ).format(this);

  //* Get Month Name and day from DateTime [April 11]
  String get monthNameDay => DateFormat('MMMM d', SMText.languageCode).format(this);

  /// Get the UTC time into local time
  DateTime get toSaudiLocalTime {
    bool isUTCZero = timeZoneOffset.inHours == 0;
    return isUTCZero ? DateTime(year, month, day, hour, minute, second) : toLocal();
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} ${SMText.second}';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${SMText.minute}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${SMText.hour}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${SMText.day}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).round(); // Approximate months
      return '$months ${SMText.month}${months > 1 ? SMText.s : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${SMText.year}${years > 1 ? SMText.s : ''}';  
    }
  }
}

extension TimeExtension on TimeOfDay {
  // Convert Time of day to DateTime
  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // convert TimeOfDay to toIso8601String
  String get isoFormat {
    return DateTime(0, 0, 0, hour, minute).toIso8601String();
  }

  // Change time of day format to 10:00 Am
  String get timeFormat {
    return DateFormat.jm().format(DateTime(0, 0, 0, hour, minute));
  }

  /// Converts TimeOfDay to a total number of minutes since midnight.
  int toMinutes() => hour * 60 + minute;

  /// Checks if the current TimeOfDay is between two other times.
  bool isBetween(TimeOfDay startTime, TimeOfDay endTime) {
    final currentMinutes = toMinutes();
    final startMinutes = startTime.toMinutes();
    final endMinutes = endTime.toMinutes();

    if (startMinutes <= endMinutes) {
      // Normal range (e.g., 9:00 AM to 5:00 PM)
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight range (e.g., 10:00 PM to 6:00 AM)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}
