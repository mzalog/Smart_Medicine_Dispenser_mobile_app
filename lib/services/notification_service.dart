import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import './config.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> sendTokenToServer(String token, String deviceId) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/update_fcm_token/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'device_id': deviceId,
      }),
    );

    if (response.statusCode == 200) {
      print('Token updated successfully');
    } else {
      print('Failed to update token');
    }
  }

  Future<void> initializeDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String? deviceIdentifier = androidInfo.id;
    String? fcmToken = await getToken();
    if (deviceIdentifier != null && fcmToken != null) {
      await sendTokenToServer(fcmToken, deviceIdentifier);
    }
  }
}
