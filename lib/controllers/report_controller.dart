import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uee_project/models/report_model.dart';
import 'package:uee_project/controllers/notification_controller.dart';
import 'dart:developer' as developer;

class ReportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationController _notificationController = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<ReportModel> userReports = <ReportModel>[].obs;
  final RxBool isLoadingUserReports = false.obs;

  // Stream of all reports for admin
  Stream<List<ReportModel>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .toList());
  }

  // Stream of user's reports
  Stream<List<ReportModel>> getUserReports(String userId) {
    developer.log('🔄 Getting reports for user ID: $userId', name: 'ReportController');
    
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final userReports = snapshot.docs
              .map((doc) => ReportModel.fromFirestore(doc))
              .toList();
          
          developer.log('📊 Found ${userReports.length} reports for user: $userId', name: 'ReportController');
          
          this.userReports.value = userReports;
          return userReports;
        })
        .handleError((error) {
          developer.log('❌ Error getting user reports: $error', name: 'ReportController');
          // Return empty list on error
          this.userReports.value = [];
          return <ReportModel>[];
        });
  }

  //  FIXED: Update report status with proper field validation
  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      developer.log('🔄 Updating report status: $reportId → $status', name: 'ReportController');
      
      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get report document first
      final reportDoc = await _firestore.collection('reports').doc(reportId).get();
      if (!reportDoc.exists) {
        throw Exception('Report not found');
      }

      final reportData = reportDoc.data()!;
      final oldStatus = reportData['status'] ?? 'pending';
      final reportTitle = reportData['title'] ?? 'Untitled Report';
      final userId = reportData['userId'] ?? '';
      
      developer.log('📊 Report data:', name: 'ReportController');
      developer.log('   Report Owner ID: $userId', name: 'ReportController');
      developer.log('   Current User ID: ${currentUser.uid}', name: 'ReportController');
      developer.log('   Title: $reportTitle', name: 'ReportController');
      developer.log('   Old Status: $oldStatus → New Status: $status', name: 'ReportController');
      
      final updatedBy = currentUser.email?.split('@').first ?? 'Admin';

      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      developer.log('✅ Report status updated in Firestore', name: 'ReportController');

      // Send notification if user is different from admin
      if (userId.isNotEmpty && userId != currentUser.uid) {
        try {
          developer.log('📨 Sending notification to user: $userId', name: 'ReportController');
          
          await _notificationController.createStatusUpdateNotification(
            reportId: reportId,
            userId: userId,
            reportTitle: reportTitle,
            oldStatus: oldStatus,
            newStatus: status,
            updatedBy: updatedBy,
          );
          
          developer.log('✅ Notification sent successfully', name: 'ReportController');
        } catch (notificationError) {
          developer.log('⚠️ Notification failed (status update succeeded): $notificationError', 
              name: 'ReportController');
        }
      }

    } catch (e, stackTrace) {
      developer.log('❌ Error updating report status: $e', name: 'ReportController');
      developer.log('❌ Stack trace: $stackTrace', name: 'ReportController');
      throw Exception('Failed to update report status: $e');
    }
  }

  //   Assign report with proper field validation
  Future<void> assignReport(String reportId, String assignedTo) async {
    try {
      developer.log('🔄 Assigning report: $reportId → $assignedTo', name: 'ReportController');
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final reportDoc = await _firestore.collection('reports').doc(reportId).get();
      if (!reportDoc.exists) {
        throw Exception('Report not found');
      }

      final reportData = reportDoc.data()!;
      final reportTitle = reportData['title'] ?? 'Untitled Report';
      final userId = reportData['userId'] ?? '';
      
      developer.log('📊 Report data:', name: 'ReportController');
      developer.log('   Report Owner ID: $userId', name: 'ReportController');
      developer.log('   Current User ID: ${currentUser.uid}', name: 'ReportController');
      developer.log('   Title: $reportTitle', name: 'ReportController');
      
      final assignedBy = currentUser.email?.split('@').first ?? 'Admin';

      //  CRITICAL: Only update assignedTo, status, and updatedAt - DO NOT include userId
      await _firestore.collection('reports').doc(reportId).update({
        'assignedTo': assignedTo,
        'status': 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      developer.log('✅ Report assigned in Firestore', name: 'ReportController');

      // Send notification
      if (userId.isNotEmpty && userId != currentUser.uid) {
        try {
          developer.log('📨 Sending assignment notification to user: $userId', name: 'ReportController');
          
          await _notificationController.createAssignmentNotification(
            reportId: reportId,
            userId: userId,
            reportTitle: reportTitle,
            assignedBy: assignedBy,
          );
          
          developer.log('✅ Assignment notification sent successfully', name: 'ReportController');
        } catch (notificationError) {
          developer.log('⚠️ Notification failed (assignment succeeded): $notificationError', 
              name: 'ReportController');
        }
      }

    } catch (e, stackTrace) {
      developer.log('❌ Error assigning report: $e', name: 'ReportController');
      developer.log('❌ Stack trace: $stackTrace', name: 'ReportController');
      throw Exception('Failed to assign report: $e');
    }
  }

  // Update report (for user edits)
  Future<void> updateReport(String reportId, ReportModel updatedReport) async {
    try {
      //  CRITICAL: Do not include userId in update to avoid permission errors
      final updateData = updatedReport.toMap();
      updateData.remove('userId'); // Remove userId from update
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('reports').doc(reportId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  // Create new report
  Future<void> createReport(ReportModel report) async {
    try {
      await _firestore.collection('reports').add(report.toMap());
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  // Get all reports once (for map screen)
  Future<List<ReportModel>> getAllReportsOnce() async {
    try {
      final querySnapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return ReportModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      developer.log('Error getting all reports once: $e', name: 'ReportController');
      throw Exception('Failed to load reports: $e');
    }
  }

  // Get reports with location data only (for map)
  Future<List<ReportModel>> getReportsWithLocation() async {
    try {
      final querySnapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();
      
      final allReports = querySnapshot.docs.map((doc) {
        return ReportModel.fromFirestore(doc);
      }).toList();

      return allReports.where((report) => report.hasLocation).toList();
    } catch (e) {
      developer.log('Error getting reports with location: $e', name: 'ReportController');
      throw Exception('Failed to load reports with location: $e');
    }
  }

  // Get user report statistics
  Future<Map<String, int>> getUserReportStatistics(String userId) async {
    try {
      developer.log('📊 Getting statistics for user: $userId', name: 'ReportController');
      
      final querySnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .get();
      
      final reports = querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();

      developer.log('📈 User statistics - Total: ${reports.length}', name: 'ReportController');
      
      return {
        'total': reports.length,
        'pending': reports.where((report) => report.status == 'pending').length,
        'in_progress': reports.where((report) => report.status == 'in_progress').length,
        'resolved': reports.where((report) => report.status == 'resolved').length,
      };
    } catch (e) {
      developer.log('Error getting user report statistics: $e', name: 'ReportController');
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'resolved': 0,
      };
    }
  }

  // Get report statistics
  Future<Map<String, int>> getReportStatistics() async {
    try {
      final querySnapshot = await _firestore.collection('reports').get();
      final reports = querySnapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();

      return {
        'total': reports.length,
        'pending': reports.where((report) => report.status == 'pending').length,
        'in_progress': reports.where((report) => report.status == 'in_progress').length,
        'resolved': reports.where((report) => report.status == 'resolved').length,
      };
    } catch (e) {
      developer.log('Error getting report statistics: $e', name: 'ReportController');
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'resolved': 0,
      };
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
      userReports.removeWhere((report) => report.id == reportId);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Get report by ID
  Future<ReportModel?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      if (doc.exists) {
        return ReportModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  // Refresh user reports
  Future<void> refreshUserReports(String userId) async {
    try {
      isLoadingUserReports.value = true;
      
      final querySnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final reports = querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
      
      userReports.value = reports;
    } catch (e) {
      developer.log('Error refreshing user reports: $e', name: 'ReportController');
    } finally {
      isLoadingUserReports.value = false;
    }
  }
}