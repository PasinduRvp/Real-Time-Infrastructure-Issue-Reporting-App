import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uee_project/services/cloudinary_service.dart';

class FirebaseReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new report with AI metadata - UPDATED FOR NOTIFICATIONS
  Future<String> createReport({
    required String title,
    required String description,
    required String category,
    required String priority,
    required Map<String, dynamic> location,
    required List<XFile> images,
    required String reportedBy,  // This is now userId (Firebase UID)
    bool aiDetected = false,
    double aiConfidence = 0.0,
  }) async {
    try {
      print('📝 Starting report creation process...');
      
      // Validate required fields
      if (title.isEmpty || description.isEmpty || category.isEmpty) {
        throw Exception('Required fields are missing');
      }

      // Get current user's email for display
      final currentUser = _auth.currentUser;
      final userEmail = currentUser?.email ?? 'unknown@example.com';

      // Upload images to Cloudinary
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        print('📤 Uploading ${images.length} images to Cloudinary...');
        imageUrls = await _cloudinaryService.uploadMultipleImages(
          images,
          reportedBy,
        );
        print('✅ All images uploaded successfully. URLs: $imageUrls');
      }

      // Create report document with AI metadata
      print('💾 Saving report to Firestore...');
      
      // ✅ UPDATED: Now includes both userId and reportedBy (email)
      final reportData = {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'status': 'pending',
        'location': location,
        'images': imageUrls,
        'userId': reportedBy,              // ← ADDED: Firebase Auth UID
        'reportedBy': userEmail,           // ← CHANGED: Now stores email for display
        'assignedTo': null,
        'aiDetected': aiDetected,
        'aiConfidence': aiConfidence,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('📋 Report data to save: $reportData');

      DocumentReference reportRef = await _firestore.collection('reports').add(reportData);

      print('✅ Report created successfully with ID: ${reportRef.id}');
      print('✅ User ID stored: $reportedBy');
      print('✅ User Email stored: $userEmail');
      
      // Verify the report was saved
      DocumentSnapshot snapshot = await reportRef.get();
      if (snapshot.exists) {
        print('✅ Report verified in database');
      } else {
        print('❌ Report was not saved to database');
        throw Exception('Report was not saved to database');
      }
      
      return reportRef.id;
    } catch (e) {
      print('❌ Failed to create report: $e');
      print('❌ Stack trace: ${e.toString()}');
      throw Exception('Failed to create report: $e');
    }
  }

  // Get all reports for a user - UPDATED to use userId
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserReports(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)  // ← CHANGED: Now uses userId instead of reportedBy
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get all reports (for admin)
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update report status
  Future<void> updateReportStatus(
    String reportId,
    String status, {
    String? assignedTo,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (assignedTo != null) {
        updates['assignedTo'] = assignedTo;
      }

      await _firestore.collection('reports').doc(reportId).update(updates);
      print('✅ Report status updated successfully');
    } catch (e) {
      print('❌ Failed to update report status: $e');
      throw Exception('Failed to update report status: $e');
    }
  }

  // Get reports by status
  Stream<QuerySnapshot<Map<String, dynamic>>> getReportsByStatus(String status) {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get report statistics
  Future<Map<String, int>> getReportStatistics() async {
    try {
      final pendingQuery = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .get();
      
      final inProgressQuery = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'in_progress')
          .get();
      
      final resolvedQuery = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'resolved')
          .get();

      return {
        'pending': pendingQuery.size,
        'in_progress': inProgressQuery.size,
        'resolved': resolvedQuery.size,
        'total': pendingQuery.size + inProgressQuery.size + resolvedQuery.size,
      };
    } catch (e) {
      throw Exception('Failed to get report statistics: $e');
    }
  }

  // Delete report (admin only)
  Future<void> deleteReport(String reportId) async {
    try {
      // Get report data to delete images from Cloudinary
      final reportDoc = await _firestore.collection('reports').doc(reportId).get();
      
      if (reportDoc.exists) {
        final data = reportDoc.data();
        final images = List<String>.from(data?['images'] ?? []);
        
        // Delete images from Cloudinary (optional - Cloudinary has auto-cleanup)
      }
      
      // Delete report document
      await _firestore.collection('reports').doc(reportId).delete();
      print('✅ Report deleted successfully');
    } catch (e) {
      print('❌ Failed to delete report: $e');
      throw Exception('Failed to delete report: $e');
    }
  }

  // Get single report by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getReportById(String reportId) async {
    return await _firestore.collection('reports').doc(reportId).get();
  }
}