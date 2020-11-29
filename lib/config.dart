import 'package:flutter/material.dart';

// BASE
const String appTitle = 'Blue Interval Timer';
ThemeData theme = new ThemeData(
  primarySwatch: Colors.blue,
);

Color uiColor = Colors.blue[800];

// PREFS
const String warmUpKey = 'warm_up';
const String intervalKey = 'interval';
const String restKey = 'rest';
const String repeatKey = 'repeat';

const int intervalDefault = 20;
const int warmUpDefault = 5;
const int restDefault = 10;
const int repeatDefault = 3;

// START
const String startButtonText = 'Start';
const EdgeInsetsGeometry startButtonPadding = const EdgeInsets.symmetric(
  horizontal: 40.0,
  vertical: 20.0,
);
const TextStyle startButtonTextStyle = const TextStyle(
  fontSize: 24.0,
  wordSpacing: 10.0,
);

// SETTINGS FORM
const formPadding = 16.0;
const String formRepeatText = 'Repeat';
const String formWarmUpText = 'Warm Up (s.)';
const String formIntervalText = 'Interval (s.)';
const String formRestText = 'Rest (s.)';
const String formRestSuffix = 'X Times';

// TIMER
Color warmUpBackground = Colors.blueGrey[400];
Color restBackground = Colors.blueGrey[400];
Color intervalBackground = Colors.blue[800];
Color doneBackground = Colors.green[700];
const Color timerTextColor = Colors.white;

const numberOfSmallBeeps = 3;
const beepVolume = 1.75;

const secondsFontSize = 64.0;
const milisecondsFontSize = 32.0;
const infoLabelFontSize = 32.0;
const pausedLabelFontSize = 14.0;
const doneIntervalsFontSize = 14.0;
const doneLabelFontSize = 38.0;
const pausedButtonsFontSize = 20.0;
const pausedButtonsIconSize = 32.0;

const timerSecondsLetterWidth = 40.0;
const timerMilisecondsLetterWidth = 20.0;

const gapBetweenLabelAndTime = 10.0;
const gapAfterTime = 20.0;

const gapBetweenDoneLabels = 20.0;

const pausedWidgetHeight = 100.0;
const gapBetweenPausedAndButtons = 16.0;
const gapBetweenButtons = 40.0;
const gapAtTheEndOfButtons = 20.0; // For padding

const String timerWarmUpText = 'Get Ready';
const String timerIntervalText = 'Train!';
const String timerRestText = 'Rest';
const String timerPausedText = 'Paused';
const String timerResumeButtonText = 'Resume';
const String timerStopButtonText = 'Stop';
const String timerEndOfWorkoutText = 'End of Workout';

const int timerBackgroundAnimationDurationInMilis = 200;