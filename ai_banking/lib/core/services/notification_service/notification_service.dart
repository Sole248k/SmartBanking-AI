import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

abstract class NotificationService {
  Future<void> init();
  Future<void> showNotification(String title, String body);
  Future<String?> getToken();
}

class MockNotificationService implements NotificationService {
  @override
  Future<void> init() async {
    print('Notification Service Initialized');
  }

  @override
  Future<void> showNotification(String title, String body) async {
    print('Showing notification: $title - $body');
  }

  @override
  Future<String?> getToken() async {
    return 'mock-fcm-token';
  }
}

@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  return MockNotificationService();
}
