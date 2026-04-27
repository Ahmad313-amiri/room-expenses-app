import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    print('Permission status: ${settings.authorizationStatus}');
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
  }
}