import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['updatedAt'];
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants']),
      lastMessage: map['lastMessage'] ?? '',
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}