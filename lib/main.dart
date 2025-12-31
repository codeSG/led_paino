import 'package:flutter/material.dart';
import 'package:led_bluetooth/screens/scan_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Terminal',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DeviceListScreen(),
    );
  }
}
