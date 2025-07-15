import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/encryption_helper.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _encryption = EncryptionService();

  static String generateChatId(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  Future<void> createChatIfNotExists(
    String user1Username,
    String user2Username,
  ) async {
    final chatId = generateChatId(user1Username, user2Username);
    final chatRef = _db.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        'participants': [user1Username, user2Username],
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<ChatModel>> getUserChats(String username) async {
    final query =
        await _db
            .collection('chats')
            .where('participants', arrayContains: username)
            .get();


    return query.docs
        .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MessageModel.fromMap(data)..decrypt(_encryption);
          }).toList();
        });
  }

  Future<void> sendMessage({
    required String chatId,
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

    await _db
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _db.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': plainText,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
