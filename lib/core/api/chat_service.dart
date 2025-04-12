import '../api/api_client.dart';
import '../models/message.dart';

class ChatService {
  Future<List<Message>> fetchMessages(
      int receiverId, {
        String receiverType = 'App\\Models\\User',
      }) async {
    print('ChatService: Bắt đầu lấy tin nhắn với receiverId=$receiverId, receiverType=$receiverType');
    try {
      final response = await ApiClient.getMessages(
        receiverId,
        receiverType: receiverType,
      );
      print('ChatService: Dữ liệu từ API: $response');
      final messages = response.map((json) {
        final message = Message.fromJson(json);
        print('ChatService: Parse tin nhắn: $message');
        return message;
      }).toList();
      print('ChatService: Danh sách tin nhắn sau khi parse: $messages');
      return messages;
    } catch (e) {
      print('ChatService: Lỗi khi lấy tin nhắn: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(
      int receiverId,
      String content, {
        String receiverType = 'App\\Models\\User',
      }) async {
    print('ChatService: Bắt đầu gửi tin nhắn: receiverId=$receiverId, content=$content, receiverType=$receiverType');
    try {
      await ApiClient.sendMessage(receiverId, content, receiverType: receiverType);
      print('ChatService: Gửi tin nhắn thành công');
    } catch (e) {
      print('ChatService: Lỗi khi gửi tin nhắn: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(int messageId) async {
    print('ChatService: Đánh dấu tin nhắn đã đọc: messageId=$messageId');
    try {
      await ApiClient.markMessageAsRead(messageId);
      print('ChatService: Đánh dấu tin nhắn đã đọc thành công');
    } catch (e) {
      print('ChatService: Lỗi khi đánh dấu tin nhắn đã đọc: $e');
      rethrow;
    }
  }
}