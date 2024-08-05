import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Background Service Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              FlutterBackgroundService().invoke("stopService");
            },
            child: Text('Stop Service'),
          ),
        ),
      ),
    );
  }
}