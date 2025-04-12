import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api/chat_service.dart';
import '../core/models/message.dart';
import '../providers/auth_provider.dart';
import 'dart:async'; // Thêm để sử dụng Timer

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer; // Timer để polling tin nhắn
  int? _currentReceiverId; // Lưu receiverId của cuộc trò chuyện hiện tại
  String? _currentReceiverType; // Lưu receiverType của cuộc trò chuyện hiện tại
  int? _currentUserId; // Lưu currentUserId của cuộc trò chuyện hiện tại

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ChatService _chatService = ChatService();

  Future<void> fetchMessages(
      int receiverId,
      int currentUserId,
      BuildContext context, {
        String receiverType = 'App\\Models\\User',
      }) async {
    _isLoading = true;
    _error = null;
    _currentReceiverId = receiverId; // Lưu thông tin cuộc trò chuyện
    _currentReceiverType = receiverType;
    _currentUserId = currentUserId;
    print('Bắt đầu lấy tin nhắn: receiverId=$receiverId, currentUserId=$currentUserId, receiverType=$receiverType');
    notifyListeners();

    try {
      final messages = await _chatService.fetchMessages(
        receiverId,
        receiverType: receiverType,
      );
      print('Dữ liệu tin nhắn trước khi lọc: $messages');
      final filteredMessages = messages.where((msg) {
        final isMatch = (msg.senderId == currentUserId &&
            msg.senderType == 'App\\Models\\User' &&
            msg.receiverId == receiverId &&
            msg.receiverType == receiverType) ||
            (msg.senderId == receiverId &&
                msg.senderType == receiverType &&
                msg.receiverId == currentUserId &&
                msg.receiverType == 'App\\Models\\User');
        print(
            'Tin nhắn: ${msg.content}, Khớp: $isMatch, senderId: ${msg.senderId}, senderType: ${msg.senderType}, receiverId: ${msg.receiverId}, receiverType: ${msg.receiverType}');
        return isMatch;
      }).toList();

      _messages = filteredMessages;
      print('Dữ liệu tin nhắn sau khi lọc: $_messages');
    } catch (e) {
      _error = e.toString();
      print('Lỗi khi lấy tin nhắn: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(
      int receiverId,
      String content,
      int currentUserId, // Nhận currentUserId trực tiếp
      BuildContext context, {
        String receiverType = 'App\\Models\\User',
      }) async {
    print('Bắt đầu gửi tin nhắn: receiverId=$receiverId, content=$content, receiverType=$receiverType');
    try {
      if (currentUserId == 0) {
        throw Exception("Không thể lấy ID người dùng hiện tại. Vui lòng đăng nhập lại.");
      }

      await _chatService.sendMessage(receiverId, content, receiverType: receiverType);
      print('Gửi tin nhắn thành công');
      await fetchMessages(receiverId, currentUserId, context, receiverType: receiverType);
    } catch (e) {
      _error = e.toString();
      print('Lỗi khi gửi tin nhắn: $e');
      notifyListeners();
      if (e.toString().contains("Không thể lấy ID người dùng hiện tại")) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      await _chatService.markAsRead(messageId);
      final message = _messages.firstWhere((msg) => msg.id == messageId);
      message.isRead = true;
      notifyListeners();
    } catch (e) {
      print('Lỗi khi đánh dấu tin nhắn đã đọc: $e');
    }
  }

  void addMessage(Message message) {
    // Kiểm tra xem tin nhắn mới có thuộc cuộc trò chuyện hiện tại không
    if (_currentReceiverId == null || _currentUserId == null || _currentReceiverType == null) {
      print('Không thể thêm tin nhắn: Thông tin cuộc trò chuyện chưa được thiết lập');
      return;
    }

    final isMatch = (message.senderId == _currentUserId &&
        message.senderType == 'App\\Models\\User' &&
        message.receiverId == _currentReceiverId &&
        message.receiverType == _currentReceiverType) ||
        (message.senderId == _currentReceiverId &&
            message.senderType == _currentReceiverType &&
            message.receiverId == _currentUserId &&
            message.receiverType == 'App\\Models\\User');

    if (isMatch) {
      print('Thêm tin nhắn mới: ${message.content}');
      _messages.add(message);
      notifyListeners();
    } else {
      print('Tin nhắn không thuộc cuộc trò chuyện hiện tại: ${message.content}');
    }
  }

  Future<void> refreshMessages(
      int receiverId,
      int currentUserId,
      BuildContext context, {
        String receiverType = 'App\\Models\\User',
      }) async {
    print('Làm mới tin nhắn: receiverId=$receiverId, currentUserId=$currentUserId');
    await fetchMessages(receiverId, currentUserId, context, receiverType: receiverType);
  }

  void startPolling(BuildContext context) {
    // Dừng timer cũ nếu có
    stopPolling();

    // Bắt đầu polling mỗi 10 giây
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_currentReceiverId != null && _currentUserId != null && _currentReceiverType != null) {
        print('Polling tin nhắn mới...');
        fetchMessages(_currentReceiverId!, _currentUserId!, context, receiverType: _currentReceiverType!);
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void clearMessages() {
    print('Xóa tất cả tin nhắn');
    _messages = [];
    _error = null;
    _isLoading = false;
    _currentReceiverId = null;
    _currentReceiverType = null;
    _currentUserId = null;
    stopPolling();
    notifyListeners();
  }
}