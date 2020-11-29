import 'dart:async';
import 'dart:core';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';

import 'config.dart' as CFG;
import 'preferences.dart';
import 'timer_states.dart';

class TimerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _TimerPageState();
  }
}

const AUDIO_FILE_SHORT_BEEP = 'short_beep.wav';
const AUDIO_FILE_LONG_BEEP = 'long_beep.wav';
const AUDIO_FILES = [
  AUDIO_FILE_SHORT_BEEP,
  AUDIO_FILE_LONG_BEEP,
];

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  static final _audio = new AudioCache()
    ..loadAll(AUDIO_FILES);

  AnimationController _timerAnimController;
  Animation<double> _timerAnim;
  double _timerPreviousValue;

  PreferencesValues _prefValues;

  TimerState _state;

  AnimationController _backgroundAnimController;
  Animation<double> _backgroundAnim;
  Color _backgroundColorStart;
  Color _backgroundColorEnd;
  Color _backgroundColor;

  int _nIntervals;

  @override
  void initState() {
    super.initState();

    _preventScreenFromSleeping();

    _state = getInitialTimerState();

    _nIntervals = 0;

    _backgroundColor = _state.getBackgroundColor();
    _backgroundAnimController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: CFG.timerBackgroundAnimationDurationInMilis),
    );
    _backgroundAnimController.addListener(_onBackgroundTick);
    _backgroundAnimController.addStatusListener(_onBackgroundAnimStatusChanged);
    _backgroundAnim = new Tween(begin: 0.0, end: 1.0).animate(_backgroundAnimController);
    _backgroundColorStart = null;
    _backgroundColorEnd = null;

    _timerAnimController = new AnimationController(vsync: this);
    _timerAnimController.addListener(_onTimerTick);
    _timerAnimController.addStatusListener(_onTimerAnimStatusChange);

    _loadPreferencesValuesAndSwitchToNextState();
  }

  @override
  void dispose() {
    _timerAnimController.dispose();
    _backgroundAnimController.dispose();

    _stopPreventingScreenFromSleeping();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new GestureDetector(
        onTap: _onTap,
        child: _buildScreen(),
      ),
    );
  }

  Widget _buildScreen() {
    if (_state.isInitial()) {
      return new Container(color: _backgroundColor);
    } else if (_state.isDone()) {
      return new DoneScreen(
        _backgroundColor,
        _state.getLabel(_prefValues, _nIntervals),
      );
    }
    return new TimerStateScreen(
      _backgroundColor,
      _timerAnim.value,
      _state.getLabel(_prefValues, _nIntervals),
      _state.isPaused(),
      _onResumeClicked,
      _onStopClicked,
    );
  }

  _onTimerTick() {
    int current = _timerAnim.value.floor();
    int previous = _timerPreviousValue.floor();

    if (current > previous) {
      int total = _state.getDurationInSeconds(_prefValues);
      int remaining = total - current;
      if (total > (CFG.numberOfSmallBeeps + 1) && remaining > 0 && remaining < (CFG.numberOfSmallBeeps + 1)) {
        _playShortBeep();
      }
    }

    _timerPreviousValue = _timerAnim.value;

    setState(() {
      // redraw
    });
  }

  void _playShortBeep() {
    _audio.play(AUDIO_FILE_SHORT_BEEP, volume: CFG.beepVolume);
  }

  void _playLongBeep() {
    _audio.play(AUDIO_FILE_LONG_BEEP, volume: CFG.beepVolume);
  }

  _onTimerAnimStatusChange(AnimationStatus newStatus) {
    if (newStatus == AnimationStatus.completed) {
      _switchToNextState();
    }
  }

  _switchToNextState() {
    _state = _state.nextState(_prefValues, _nIntervals);
    _nIntervals = _state.updateNumberOfIntervals(_nIntervals);
    _newBackground(_state.getBackgroundColor());

    if (_state.isLongBeepNeeded()) {
      _playLongBeep();
    }

    if (_state.isDone()) {
      new Timer(Duration(milliseconds: 1000), () {
        _playLongBeep();
      });
      new Timer(Duration(milliseconds: 2000), () {
        _playLongBeep();
      });
      return;
    }

    int seconds = _state.getDurationInSeconds(_prefValues);
    if (seconds > 0) {
      _initTimer(begin: 0.0, end: seconds * 1.0, durationInMilis: seconds * 1000);
    } else {
      _switchToNextState();
    }
  }

  _onBackgroundTick() {
    setState(() {
      _backgroundColor = Color.lerp(_backgroundColorStart, _backgroundColorEnd, _backgroundAnim.value);
    });
  }

  _onBackgroundAnimStatusChanged(AnimationStatus newStatus) {
    if (newStatus == AnimationStatus.completed) {
      _backgroundColor = _backgroundColorEnd;
      _backgroundColorStart = null;
      _backgroundColorEnd = null;
    }
  }

  _preventScreenFromSleeping() {
    Screen.keepOn(true);
  }

  _stopPreventingScreenFromSleeping() {
    Screen.keepOn(false);
  }

  _onTap() {
    if (_state.isDone() || _state.isInitial()) {
      _stop();
    } else if (!_state.isPaused()) {
      _pause();
    }
  }

  _onResumeClicked() {
    _resume();
  }

  _onStopClicked() {
    _stop();
  }

  _pause() {
    _timerAnimController.stop(canceled: false);
    _state = _state.pausedState();
    setState(() {
      // Just to redraw
    });
  }

  _resume() {
    _state = _state.resumedState();

    double total = _state.getDurationInSeconds(_prefValues) * 1.0;
    double current = _timerAnim.value;

    _initTimer(
      begin: _timerAnim.value,
      end: total,
      durationInMilis: ((total - current) * 1000).toInt(),
    );
  }

  _stop() {
    Navigator.of(context).pop();
  }

  _loadPreferencesValuesAndSwitchToNextState() async {
    _prefValues = await getPreferencesValuesWithDefaults();
    _switchToNextState();
  }

  _initTimer({double begin, double end, int durationInMilis}) {
    if (durationInMilis <= 0) {
      _switchToNextState();
      return;
    }

    _timerAnimController.duration = new Duration(milliseconds: durationInMilis);
    _timerAnim = new Tween(begin: begin, end: end).animate(_timerAnimController);
    _timerPreviousValue = begin;
    _timerAnimController.forward(from: 0.0);
  }

  _newBackground(Color newBackgroundColor) {
    _backgroundColorStart = _backgroundColor;
    _backgroundColorEnd = newBackgroundColor;
    _backgroundAnimController.forward(from: 0.0);
  }
}

const _secondsStyle = TextStyle(color: CFG.timerTextColor, fontSize: CFG.secondsFontSize);
const _milisecondsStyle = TextStyle(color: CFG.timerTextColor, fontSize: CFG.milisecondsFontSize);
const _infoLabelStyle = TextStyle(color: CFG.timerTextColor, fontSize: CFG.infoLabelFontSize);
const _pausedLabelStyle = TextStyle(color: CFG.timerTextColor, fontSize: CFG.pausedLabelFontSize);
const _pausedButtonStyle = TextStyle(
  color: CFG.timerTextColor,
  fontSize: CFG.pausedButtonsFontSize,
  fontWeight: FontWeight.normal,
);
const _doneLabelStyle = TextStyle(color: CFG.timerTextColor, fontSize: CFG.doneLabelFontSize);
const _doneIntervalsStyle = TextStyle(color: CFG.timerTextColor, fontSize: CFG.doneIntervalsFontSize);

typedef void TimerStateScreenCallback();

class TimerStateScreen extends StatelessWidget {
  final Color _backgroundColor;
  final double _timeLeft;
  final String _label;
  final bool _isPaused;
  final TimerStateScreenCallback _onResume;
  final TimerStateScreenCallback _onStop;

  TimerStateScreen(this._backgroundColor,
                   this._timeLeft,
                   this._label,
                   this._isPaused,
                   this._onResume,
                   this._onStop,) : super();

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: _backgroundColor,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          this._getPausedWidget(),
          new Text(_label, style: _infoLabelStyle),
          new Container(height: CFG.gapBetweenLabelAndTime),
          this._getTimeWidget(),
          new Container(height: CFG.pausedWidgetHeight + CFG.gapAfterTime),
        ],
      ),
    );
  }

  Widget _getTimeWidget() {
    var children = <Widget>[];

    var numbers = _currentText();
    for (var i = 0; i < numbers.length; ++i) {
      var isMilis = !(numbers.length - 1 - i < 3);

      TextStyle style;
      double width;
      if (isMilis) {
        style = _secondsStyle;
        width = CFG.timerSecondsLetterWidth;
      } else {
        style = _milisecondsStyle;
        width = CFG.timerMilisecondsLetterWidth;
      }

      if (numbers[i] == ':') {
        width *= 0.7;
      }

      children.add(new Container(
        alignment: Alignment.center,
        width: width,
        height: style.fontSize * 0.9,
        child: new Text(numbers[i], style: style),
      ));
    }

    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

  Widget _getPausedWidget() {
    if (!_isPaused) {
      return Container(
        height: CFG.pausedWidgetHeight,
      );
    }

    return new Container(
      height: CFG.pausedWidgetHeight,
      child: new Column(
        children: <Widget>[
          new Text(CFG.timerPausedText, style: _pausedLabelStyle),
          new Container(height: CFG.gapBetweenPausedAndButtons),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _button(Icons.play_arrow, CFG.timerResumeButtonText, _onResume),
              new Container(width: CFG.gapBetweenButtons),
              _button(Icons.stop, CFG.timerStopButtonText, _onStop),
              new Container(width: CFG.gapAtTheEndOfButtons),
            ],
          )
        ],
      ),
    );
  }

  Widget _button(IconData iconData, String buttonText, TimerStateScreenCallback onPressed) {
    return new FlatButton(
      child: new Row(
        children: <Widget>[
          new Icon(iconData, size: CFG.pausedButtonsIconSize),
          new Text(buttonText, style: _pausedButtonStyle),
        ],
      ),
      onPressed: onPressed,
      color: _backgroundColor,
      textColor: CFG.timerTextColor,
    );
  }

  String _currentText() {
    int minutes = (_timeLeft.toInt() ~/ 60);
    int seconds = (_timeLeft.toInt() % 60);
    int miliseconds = ((_timeLeft - _timeLeft.toInt()) * 100.0).toInt();

    var minutesStr = minutes.toString().padLeft(2, '0');
    var secondsStr = seconds.toString().padLeft(2, '0');
    var milisecondsStr = miliseconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr:$milisecondsStr';
  }
}

class DoneScreen extends StatelessWidget {
  final Color _backgroundColor;
  final String _label;

  DoneScreen(this._backgroundColor, this._label) : super();

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: _backgroundColor,

      child: new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(CFG.timerEndOfWorkoutText, style: _doneLabelStyle),
          new Container(height: CFG.gapBetweenDoneLabels),
          new Text(_label, style: _doneIntervalsStyle),
        ],
      ),
    );
  }
}
