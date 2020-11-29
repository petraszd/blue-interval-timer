import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart' as CFG;
import 'preferences.dart';

class SettingsForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _SettingsFormState();
  }
}

class _SettingsFormState extends State<SettingsForm> {
  TextEditingController _warmUpController;
  TextEditingController _intervalController;
  TextEditingController _restController;
  TextEditingController _repeatController;

  @override
  void initState() {
    _warmUpController = new TextEditingController();
    _warmUpController.addListener(_onWarmUpChanged);

    _intervalController = new TextEditingController();
    _intervalController.addListener(_onIntervalChanged);

    _restController = new TextEditingController();
    _restController.addListener(_onRestChanged);

    _repeatController = new TextEditingController();
    _repeatController.addListener(_onRepeatChanged);

    super.initState();

    _initCurrentValuesFromPrefs();
  }

  @override
  void dispose() {
    _warmUpController.dispose();
    _intervalController.dispose();
    _restController.dispose();
    _repeatController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Form(
      child: new ListView(
        padding: const EdgeInsets.all(CFG.formPadding),
        children: <Widget>[
          _makeFieldDefault(CFG.formWarmUpText, _warmUpController),
          _makeFieldDefault(CFG.formIntervalText, _intervalController),
          _makeFieldDefault(CFG.formRestText, _restController),
          _makeRepeatField(_repeatController),
        ],
      ),
    );
  }

  _initCurrentValuesFromPrefs() async {
    final values = await getPreferencesValues();

    _warmUpController.text = _getInitialPref(values.warmUp);
    _intervalController.text = _getInitialPref(values.interval);
    _restController.text = _getInitialPref(values.rest);
    _repeatController.text = _getInitialPref(values.repeat);
  }

  _onWarmUpChanged() {
    _onValueChanged(CFG.warmUpKey, _warmUpController.text);
  }

  _onIntervalChanged() {
    _onValueChanged(CFG.intervalKey, _intervalController.text);
  }

  _onRestChanged() {
    _onValueChanged(CFG.restKey, _restController.text);
  }

  _onRepeatChanged() {
    _onValueChanged(CFG.repeatKey, _repeatController.text);
  }

  _onValueChanged(String key, String inputValue) async {
    int value = UNKNOWN_VALUE;
    if (inputValue.isNotEmpty) {
      value = int.parse(inputValue);
    }

    savePreference(key, value);
  }
}

String _getInitialPref(int val) {
  if (val != UNKNOWN_VALUE) {
    return val.toString();
  }
  return '';
}

TextEditingValue _fmtNumber(TextEditingValue oldVal, TextEditingValue newVal) {
  if (newVal.text.isEmpty) {
    return newVal;
  }

  String cleared = _clearNotNumeric(newVal.text);
  if (cleared.length == newVal.text.length) {
    return newVal;
  }

  return newVal.copyWith(text: cleared, selection: oldVal.selection);
}

String _clearNotNumeric(String str) {
  StringBuffer buffer = new StringBuffer();
  for (var c in str.runes) {
    if (c >= 48 && c <= 57) {
      // 0 .. 9
      buffer.write(String.fromCharCode(c));
    }
  }

  return buffer.toString();
}

final _numberFormatters = [TextInputFormatter.withFunction(_fmtNumber)];

TextFormField _makeField(InputDecoration decoration, TextEditingController controller) {
  return new TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: decoration,
    inputFormatters: _numberFormatters,
  );
}

TextFormField _makeFieldDefault(String label, TextEditingController controller) {
  return _makeField(new InputDecoration(labelText: label), controller);
}

TextFormField _makeRepeatField(TextEditingController controller) {
  return _makeField(
    new InputDecoration(labelText: CFG.formRepeatText, suffixText: CFG.formRestSuffix),
    controller,
  );
}
