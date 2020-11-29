import 'package:flutter/material.dart';

import 'config.dart' as CFG;
import 'settings_form.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(CFG.appTitle), backgroundColor: CFG.uiColor),
      body: new SettingsForm(),
      floatingActionButton: _buildStartButton(context),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return new RaisedButton(
      padding: CFG.startButtonPadding,
      onPressed: () => _onStartPressed(context),
      color: CFG.uiColor,
      textColor: Colors.white,
      shape: const StadiumBorder(),
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text(
            CFG.startButtonText,
            style: CFG.startButtonTextStyle,
          ),
          new Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  _onStartPressed(BuildContext context) {
    Navigator.pushNamed(context, '/timer');
  }
}
