import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/encryption_helper.dart';
import '../models/message_model.dart';


class ChatService {
  final _db = FirebaseFirestore.instance;
  final _encryption = EncryptionService();

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String plainText,
  }) async {
    final encryptedText = _encryption.encrypt(plainText);
    final message = MessageModel(
      senderId: senderId,
      receiverId: receiverId,
      encryptedText: encryptedText,
      timestamp: DateTime.now(),
    );
    await _db.collection('messages').add(message.toMap());
  }

  Stream<List<MessageModel>> getMessages(String currentUserId, String otherUserId) {
    return _db
        .collection('messages')
        .where('senderId', whereIn: [currentUserId, otherUserId])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).where((msg) =>
      (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
          (msg.senderId == otherUserId && msg.receiverId == currentUserId)
      ).toList();
    });
  }
}

