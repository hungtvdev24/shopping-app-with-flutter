import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../core/api/auth_service.dart'; // Để lấy token



class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final tokenFuture = authService.getToken();

    return FutureBuilder<String?>(
      future: tokenFuture,
      builder: (context, tokenSnapshot) {
        if (tokenSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (tokenSnapshot.hasError || tokenSnapshot.data == null) {
          return const Center(child: Text('Lỗi: Không thể lấy token. Vui lòng đăng nhập lại.'));
        }

        final token = tokenSnapshot.data!;
        final notificationProvider = Provider.of<NotificationProvider>(context);

        // Lấy danh sách thông báo khi màn hình được hiển thị
        if (!notificationProvider.isLoading && notificationProvider.notifications.isEmpty) {
          notificationProvider.fetchNotifications(token);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              "Thông báo",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(child: Text('Lỗi: ${provider.error}'));
              }
              if (provider.notifications.isEmpty) {
                return const Center(child: Text('Chưa có thông báo nào.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.notifications.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification.isRead
                          ? Colors.grey.shade300
                          : Colors.blue.shade100,
                      child: Icon(
                        Iconsax.notification,
                        color: notification.isRead ? Colors.grey : Colors.blue,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      notification.content,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    onTap: () async {
                      if (!notification.isRead) {
                        await provider.markAsRead(notification.id, token);
                      }
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}