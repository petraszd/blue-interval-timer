import 'package:flutter/material.dart';

import 'config.dart' as CFG;
import 'settings_page.dart';
import 'timer_page.dart';

void main() {
  runApp(new App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
//      showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
      title: CFG.appTitle,
      theme: CFG.theme,
      home: new SettingsPage(),
      routes: <String, WidgetBuilder>{
        '/timer': (BuildContext context) => new TimerPage(),
      },
    );
  }
}
