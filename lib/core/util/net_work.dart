import 'package:get/get.dart';
import 'dart:io';

import 'app_logger.dart';


/// Network status monitoring service
/// Provides real-time updates on connection changes
class NetworkService extends GetxService {
  var isConnected = true.obs;
  var connectionType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  /// Initialize connectivity check
  Future<void> _initConnectivity() async {
    try {
      AppLogger.i('Initializing network service');
      final hasConnection = await hasInternetConnection();

      if (hasConnection) {
        isConnected.value = true;
        connectionType.value = 'Connected';
        AppLogger.i('Internet connection available');
      } else {
        isConnected.value = false;
        connectionType.value = 'Offline';
        AppLogger.w('No internet connection');
      }
    } catch (e) {
      AppLogger.error('Error initializing connectivity', e);
      isConnected.value = false;
    }
  }

  /// Check if device has internet connection
  /// Uses Google DNS to verify actual internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        AppLogger.d('Internet connectivity verified');
        return true;
      }
      return false;
    } on SocketException catch (e) {
      AppLogger.w('No internet connection: $e');
      return false;
    } catch (e) {
      AppLogger.error('Error checking internet', e);
      return false;
    }
  }

  /// Retry internet check with timeout
  Future<bool> checkConnectionWithRetry({int attempts = 3}) async {
    for (int i = 0; i < attempts; i++) {
      try {
        if (await hasInternetConnection()) {
          isConnected.value = true;
          connectionType.value = 'Connected';
          return true;
        }
      } catch (e) {
        AppLogger.w('Retry $i failed: $e');
      }

      if (i < attempts - 1) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    isConnected.value = false;
    connectionType.value = 'Offline';
    return false;
  }

  /// Get connection status string
  String getConnectionStatus() {
    if (!isConnected.value) {
      return 'No Connection';
    }
    return connectionType.value;
  }

  /// Check if currently online
  bool get isOnline => isConnected.value;

  /// Check if currently offline
  bool get isOffline => !isConnected.value;
}