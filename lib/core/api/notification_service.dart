import 'package:testdatn/core/models/notification.dart';
import 'api_client.dart';

class NotificationService {
  // Lấy danh sách thông báo
  Future<List<AppNotification>> fetchNotifications(String token) async {
    final response = await ApiClient.getData('notifications', token: token);
    return (response as List).map((json) => AppNotification.fromJson(json)).toList();
  }

  // Đánh dấu thông báo là đã đọc
  Future<void> markAsRead(int notificationId, String token) async {
    await ApiClient.postData('notifications/$notificationId/mark-as-read', {}, token: token);
  }
}