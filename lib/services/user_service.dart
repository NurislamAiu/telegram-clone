import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _usersRef = FirebaseFirestore.instance.collection('users');


  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }


  Future<List<UserModel>> getAllUsers(String currentUserId) async {
    try {
      final snapshot = await _usersRef
          .where('id', isNotEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }


  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _usersRef.doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user: $e');
    }
  }

  Future<List<UserModel>> getAllUsersExcept(String currentUserId) async {
    try {
      final snapshot = await _usersRef
          .where('id', isNotEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}