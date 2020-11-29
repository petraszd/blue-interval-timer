import 'dart:core';

import 'package:flutter/material.dart';

import 'config.dart' as CFG;
import 'preferences.dart';

TimerState getInitialTimerState() {
  return _initial;
}

const _initial = InitialTimerState();
const _warmUp = WarmUpTimerState();
const _warmUpPaused = WarmUpPausedTimerState();
const _interval = IntervalTimerState();
const _intervalPaused = IntervalPausedTimerState();
const _rest = RestTimerState();
const _restPaused = RestPausedTimerState();
const _done = DoneTimerState();

abstract class TimerState {
  const TimerState();

  bool isInitial() {
    return false;
  }

  bool isDone() {
    return false;
  }

  bool isPaused() {
    return false;
  }

  bool isLongBeepNeeded() {
    return false;
  }

  String getLabel(PreferencesValues values, int nIntervals) {
    return "";
  }

  int getDurationInSeconds(PreferencesValues values) {
    return 0;
  }

  int updateNumberOfIntervals(int nIntervals) {
    return nIntervals;
  }

  TimerState pausedState() {
    assert(false, "This TimerState has no paused state");
    return this;
  }

  TimerState resumedState() {
    assert(false, "This TimerState has no resumed state");
    return this;
  }

  TimerState nextState(PreferencesValues values, int nIntervals);

  Color getBackgroundColor();
}

class InitialTimerState extends TimerState {
  const InitialTimerState();

  @override
  bool isInitial() {
    return true;
  }

  @override
  TimerState nextState(PreferencesValues values, int nIntervals) {
    return _warmUp;
  }

  @override
  Color getBackgroundColor() {
    return CFG.warmUpBackground;
  }
}

class WarmUpTimerState extends TimerState {
  const WarmUpTimerState();

  @override
  TimerState nextState(PreferencesValues values, int nIntervals) {
    return _interval;
  }

  @override
  int getDurationInSeconds(PreferencesValues values) {
    return values.warmUp;
  }

  @override
  Color getBackgroundColor() {
    return CFG.warmUpBackground;
  }

  @override
  String getLabel(PreferencesValues values, int nIntervals) {
    return CFG.timerWarmUpText;
  }

  @override
  TimerState pausedState() {
    return _warmUpPaused;
  }
}

class WarmUpPausedTimerState extends WarmUpTimerState {
  const WarmUpPausedTimerState();

  @override
  bool isPaused() {
    return true;
  }

  @override
  TimerState resumedState() {
    return _warmUp;
  }
}

class IntervalTimerState extends TimerState {
  const IntervalTimerState();

  @override
  TimerState nextState(PreferencesValues values, int nIntervals) {
    if (nIntervals >= values.repeat) {
      return _done;
    }
    return _rest;
  }

  @override
  bool isLongBeepNeeded() {
    return true;
  }

  @override
  int updateNumberOfIntervals(int nIntervals) {
    return nIntervals + 1;
  }

  @override
  int getDurationInSeconds(PreferencesValues values) {
    return values.interval;
  }

  @override
  Color getBackgroundColor() {
    return CFG.intervalBackground;
  }

  @override
  String getLabel(PreferencesValues values, int nIntervals) {
    return '${CFG.timerIntervalText} $nIntervals of ${values.repeat}'; // TODO: to CFG?
  }

  @override
  TimerState pausedState() {
    return _intervalPaused;
  }
}

class IntervalPausedTimerState extends IntervalTimerState {
  const IntervalPausedTimerState();

  @override
  bool isPaused() {
    return true;
  }

  @override
  TimerState resumedState() {
    return _interval;
  }
}

class RestTimerState extends TimerState {
  const RestTimerState();

  @override
  bool isLongBeepNeeded() {
    return true;
  }

  @override
  TimerState nextState(PreferencesValues values, int nIntervals) {
    return _interval;
  }

  @override
  int getDurationInSeconds(PreferencesValues values) {
    return values.rest;
  }

  @override
  Color getBackgroundColor() {
    return CFG.restBackground;
  }

  @override
  String getLabel(PreferencesValues values, int nIntervals) {
    return '${CFG.timerRestText}. ${values.repeat - nIntervals} to go'; // TODO: to CFG?;
  }

  @override
  TimerState pausedState() {
    return _restPaused;
  }
}

class RestPausedTimerState extends RestTimerState {
  const RestPausedTimerState();

  @override
  bool isPaused() {
    return true;
  }

  @override
  TimerState resumedState() {
    return _rest;
  }
}

class DoneTimerState extends TimerState {
  const DoneTimerState();

  @override
  bool isLongBeepNeeded() {
    // TODO: different sound FX
    return true;
  }

  @override
  TimerState nextState(PreferencesValues values, int nIntervals) {
    assert(false, "There should be no new state after DONE");
    return null;
  }

  @override
  Color getBackgroundColor() {
    return CFG.doneBackground;
  }

  @override
  String getLabel(PreferencesValues values, int nIntervals) {
    return "$nIntervals of ${values.repeat} done";
  }

  @override
  bool isDone() {
    return true;
  }
}
