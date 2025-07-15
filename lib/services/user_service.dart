import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<UserModel?> searchByUsername(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return UserModel.fromJson(query.docs.first.data());
  }
}