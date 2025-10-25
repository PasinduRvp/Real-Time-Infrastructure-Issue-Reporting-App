// services/firestore_test_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test if we can write to Firestore
  Future<bool> testFirestoreConnection() async {
    try {
      print('Testing Firestore connection...');
      
      // Try to write a test document
      await _firestore.collection('test').doc('connection_test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });
      
      print('Firestore write test successful');
      
      // Try to read the document back
      DocumentSnapshot doc = await _firestore.collection('test').doc('connection_test').get();
      
      if (doc.exists) {
        print('Firestore read test successful');
        
        // Clean up test document
        await _firestore.collection('test').doc('connection_test').delete();
        print('Test document cleaned up');
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Firestore test failed: $e');
      return false;
    }
  }

  // Test user collection access
  Future<bool> testUserCollectionAccess() async {
    try {
      print('Testing user collection access...');
      
      // Try to read from users collection (this will test read permissions)
      QuerySnapshot users = await _firestore.collection('users').limit(1).get();
      
      print('User collection read test successful');
      return true;
    } catch (e) {
      print('User collection test failed: $e');
      return false;
    }
  }
}

