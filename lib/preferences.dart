import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart' as CFG;

const UNKNOWN_VALUE = -1;

class PreferencesValues {
  int warmUp;
  int interval;
  int rest;
  int repeat;

  PreferencesValues({this.warmUp, this.interval, this.rest, this.repeat});
}

Future<PreferencesValues> getPreferencesValues() async {
  final prefs = await SharedPreferences.getInstance();

  return new PreferencesValues(
    warmUp: prefs.getInt(CFG.warmUpKey) ?? UNKNOWN_VALUE,
    interval: prefs.getInt(CFG.intervalKey) ?? UNKNOWN_VALUE,
    rest: prefs.getInt(CFG.restKey) ?? UNKNOWN_VALUE,
    repeat: prefs.getInt(CFG.repeatKey) ?? UNKNOWN_VALUE,
  );
}

Future<PreferencesValues> getPreferencesValuesWithDefaults() async {
  PreferencesValues values = await getPreferencesValues();

  if (values.warmUp == UNKNOWN_VALUE) {
    values.warmUp = CFG.warmUpDefault;
  }
  if (values.interval == UNKNOWN_VALUE) {
    values.interval = CFG.intervalDefault;
  }
  if (values.rest == UNKNOWN_VALUE) {
    values.rest = CFG.restDefault;
  }
  if (values.repeat == UNKNOWN_VALUE) {
    values.repeat = CFG.repeatDefault;
  }
  return values;
}

void savePreference(String key, int value) async {
  final prefs = await SharedPreferences.getInstance();

  if (value == UNKNOWN_VALUE) {
    prefs.remove(key);
  } else {
    prefs.setInt(key, value);
  }
}
