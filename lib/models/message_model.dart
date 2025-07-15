import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/encryption_helper.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String encryptedText;
  final DateTime timestamp;
  String? decryptedText;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.encryptedText,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'encryptedText': encryptedText,
      'timestamp': timestamp,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      encryptedText: map['encryptedText'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  // 🔐 Метод для расшифровки текста
  void decrypt(EncryptionService encryption) {
    decryptedText = encryption.decrypt(encryptedText);
  }
}