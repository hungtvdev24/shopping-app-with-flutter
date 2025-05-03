import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/api/auth_service.dart';
import '../../core/models/user.dart';
import '../../core/api/pusher_service.dart';
import '../../routes.dart'; // Thêm import routes.dart
import 'package:flutter/foundation.dart'; // For debugPrint

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key}); // Loại bỏ const nếu không cần thiết

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  String? _token;
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late PusherService _pusherService;
  late ChatProvider _chatProvider;
  int? _currentUserId;
  bool _isPusherInitialized = false;
  bool _isChatInitializing = true;
  final User _admin = User(
    id: 1, // Admin mặc định
    name: 'Admin',
    email: 'admin1@example.com',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authService = AuthService();
    authService.getToken().then((token) {
      if (token != null) {
        setState(() {
          _token = token;
        });
        // Tải thông báo
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(token);
        // Khởi tạo nhắn tin
        _initializeChat();
      }
    });
  }

  Future<void> _initializeChat() async {
    final authService = AuthService();
    try {
      if (_token == null) {
        if (!mounted) return;
        debugPrint('Không tìm thấy token');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy token. Vui lòng đăng nhập lại.")),
        );
        return;
      }

      final user = await authService.getUser();
      debugPrint('User data: $user');
      _currentUserId = user['id'];
      if (_currentUserId == null) {
        if (!mounted) return;
        debugPrint('Không thể lấy ID người dùng');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể lấy thông tin người dùng.")),
        );
        return;
      }
      debugPrint('Current User ID: $_currentUserId');

      _pusherService = PusherService();
      await _pusherService.initPusher(_currentUserId!, _chatProvider);
      _isPusherInitialized = true;
      _pusherService.subscribeToChannel(_currentUserId!);
      await _chatProvider.fetchMessages(_admin.id, _currentUserId!, context,
          receiverType: 'App\\Models\\Admin');
      await _markMessagesAsRead();
      _chatProvider.startPolling(context);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      debugPrint("Lỗi khởi tạo nhắn tin: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khởi tạo nhắn tin: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChatInitializing = false;
        });
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    for (var message in _chatProvider.messages) {
      if (!message.isRead && message.receiverId == _currentUserId) {
        await _chatProvider.markAsRead(message.id);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      debugPrint('Cuộn xuống cuối danh sách tin nhắn');
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      debugPrint('ScrollController chưa sẵn sàng, thử lại sau khi build');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          debugPrint('Cuộn xuống cuối danh sách tin nhắn sau khi build');
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      debugPrint('Gửi tin nhắn: $content');
      _chatProvider.sendMessage(_admin.id, content, _currentUserId!, context,
          receiverType: 'App\\Models\\Admin');
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      debugPrint('Tin nhắn rỗng, không gửi');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_isPusherInitialized) {
      debugPrint('Ngắt kết nối Pusher');
      _pusherService.unsubscribeFromChannel();
      _pusherService.disconnect();
    }
    _messageController.dispose();
    _scrollController.dispose();
    _chatProvider.stopPolling();
    _chatProvider.clearMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông báo & Nhắn tin",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Thông báo'),
            Tab(text: 'Nhắn tin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Danh sách thông báo
          _buildNotificationTab(context),
          // Tab 2: Nhắn tin với admin
          _buildChatTab(context),
        ],
      ),
    );
  }

  Widget _buildNotificationTab(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        debugPrint('Notifications in provider: ${provider.notifications}');
        debugPrint('Is loading: ${provider.isLoading}, Error: ${provider.error}');

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lỗi: ${provider.error}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => provider.refreshNotifications(_token!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Thử lại",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (provider.notifications.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có thông báo nào.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Roboto',
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.notifications.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
          itemBuilder: (context, index) {
            final notification = provider.notifications[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.white : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25), // Thay withOpacity bằng withAlpha
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey.shade300
                      : const Color(0xFFFCE4EC),
                  child: Icon(
                    Iconsax.notification,
                    color: notification.isRead ? Colors.grey : Colors.pink,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Iconsax.share,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.share,
                          arguments: {
                            'title': notification.title,
                            'content': notification.content,
                            'url': null,
                          },
                        );
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  if (!notification.isRead) {
                    await provider.markAsRead(notification.id, _token!);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatTab(BuildContext context) {
    if (_isChatInitializing) {
      debugPrint('Đang khởi tạo nhắn tin, hiển thị loading');
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentUserId == null) {
      debugPrint('CurrentUserId là null, hiển thị lỗi');
      return const Center(child: Text('Lỗi: Không thể tải thông tin người dùng'));
    }

    return Column(
      children: [
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, provider, child) {
              debugPrint(
                  'Consumer rebuild - isLoading: ${provider.isLoading}, messages: ${provider.messages.length}, error: ${provider.error}');

              if (provider.isLoading && provider.messages.isEmpty) {
                debugPrint('Hiển thị CircularProgressIndicator vì đang tải lần đầu');
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                debugPrint('Hiển thị lỗi: ${provider.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lỗi: ${provider.error}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('Nhấn nút Thử lại');
                          provider.refreshMessages(_admin.id, _currentUserId!, context,
                              receiverType: 'App\\Models\\Admin');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.black),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Thử lại",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (provider.messages.isEmpty) {
                debugPrint('Hiển thị thông báo "Chưa có tin nhắn nào"');
                return const Center(
                  child: Text(
                    'Chưa có tin nhắn nào.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                );
              }

              debugPrint('Hiển thị danh sách tin nhắn với số lượng: ${provider.messages.length}');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: provider.messages.length,
                itemBuilder: (context, index) {
                  final message = provider.messages[provider.messages.length - 1 - index];
                  final isSent =
                      message.senderId == _currentUserId && message.senderType == 'App\\Models\\User';
                  debugPrint('Hiển thị tin nhắn $index: ${message.content}, isSent: $isSent');
                  return Align(
                    alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSent ? const Color(0xFF0084FF) : const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (message.senderName != null)
                            Text(
                              message.senderName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSent ? Colors.white70 : Colors.grey.shade600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSent ? Colors.white : Colors.black,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.getFormattedTime(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSent ? Colors.white70 : Colors.grey.shade600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          if (isSent && message.isRead)
                            const Icon(
                              Icons.check_circle,
                              size: 12,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Iconsax.send_1, color: Color(0xFF0084FF)),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
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