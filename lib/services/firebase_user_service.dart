import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class FirebaseUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user document in Firestore
  Future<void> createUserDocument({
    required String userId,
    required String email,
    required String name,
    required String role,
  }) async {
    try {
      developer.log('Creating user document for: $email with role: $role', name: 'FirebaseUserService');
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log('User document created successfully for: $email', name: 'FirebaseUserService');
    } catch (e) {
      developer.log('Error creating user document: $e', name: 'FirebaseUserService');
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      developer.log('Getting user data for userId: $userId', name: 'FirebaseUserService');
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        developer.log('User document found for userId: $userId', name: 'FirebaseUserService');
        return userDoc.data() as Map<String, dynamic>;
      }
      developer.log('User document not found for userId: $userId', name: 'FirebaseUserService');
      return null;
    } catch (e) {
      developer.log('Error getting user data: $e', name: 'FirebaseUserService');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] == 'admin';
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check user role: $e');
    }
  }
}