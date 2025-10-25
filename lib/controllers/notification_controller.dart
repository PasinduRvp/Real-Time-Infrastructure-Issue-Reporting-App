import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uee_project/models/notification_model.dart';
import 'dart:developer' as developer;

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  //  FIXED: Stream of user notifications - Client-side sorting (no index needed)
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    developer.log('🔄 Getting notifications for user: $userId', name: 'NotificationController');
    
    if (userId.isEmpty) {
      developer.log('⚠️ Empty userId provided', name: 'NotificationController');
      return Stream.value([]);
    }
    
    //  Simple query without orderBy - no index required!
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notificationsList = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
          
          //  Sort client-side by createdAt (newest first)
          notificationsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          developer.log('📧 Loaded ${notificationsList.length} notifications', name: 'NotificationController');
          this.notifications.value = notificationsList;
          return notificationsList;
        })
        .handleError((error) {
          developer.log('❌ Error in notification stream: $error', name: 'NotificationController');
          // Return empty list on error
          this.notifications.value = [];
          return <NotificationModel>[];
        });
  }

  // ✅ IMPROVED: Create status update notification with retry logic
  Future<void> createStatusUpdateNotification({
    required String reportId,
    required String userId,
    required String reportTitle,
    required String oldStatus,
    required String newStatus,
    required String updatedBy,
  }) async {
    int retries = 0;
    const maxRetries = 3;
    
    while (retries < maxRetries) {
      try {
        developer.log('📨 Creating status update notification (attempt ${retries + 1})', name: 'NotificationController');
        developer.log('   Report ID: $reportId', name: 'NotificationController');
        developer.log('   User ID: $userId', name: 'NotificationController');
        developer.log('   Title: $reportTitle', name: 'NotificationController');
        developer.log('   Status: $oldStatus → $newStatus', name: 'NotificationController');
        
        if (userId.isEmpty) {
          throw Exception('User ID cannot be empty');
        }
        
        if (reportId.isEmpty) {
          throw Exception('Report ID cannot be empty');
        }
        
        final oldStatusText = _formatStatusText(oldStatus);
        final newStatusText = _formatStatusText(newStatus);
        
        final notificationData = {
          'userId': userId,
          'title': 'Report Status Updated',
          'message': 'Your report "$reportTitle" status changed from $oldStatusText to $newStatusText by $updatedBy',
          'type': 'status_update',
          'reportId': reportId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        developer.log('📋 Notification data: $notificationData', name: 'NotificationController');
        
        await _firestore.collection('notifications').add(notificationData);
        
        developer.log('✅ Status update notification created successfully', name: 'NotificationController');
        return; // Success, exit the retry loop
      } catch (e) {
        retries++;
        developer.log('❌ Error creating status update notification (attempt $retries): $e', name: 'NotificationController');
        
        if (retries >= maxRetries) {
          developer.log('❌ Max retries reached. Stack trace: ${StackTrace.current}', name: 'NotificationController');
          rethrow;
        }
        
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 500 * retries));
      }
    }
  }

  // ✅ IMPROVED: Create assignment notification with retry logic
  Future<void> createAssignmentNotification({
    required String reportId,
    required String userId,
    required String reportTitle,
    required String assignedBy,
  }) async {
    int retries = 0;
    const maxRetries = 3;
    
    while (retries < maxRetries) {
      try {
        developer.log('📨 Creating assignment notification (attempt ${retries + 1})', name: 'NotificationController');
        developer.log('   Report ID: $reportId', name: 'NotificationController');
        developer.log('   User ID: $userId', name: 'NotificationController');
        
        if (userId.isEmpty) {
          throw Exception('User ID cannot be empty');
        }
        
        if (reportId.isEmpty) {
          throw Exception('Report ID cannot be empty');
        }
        
        final notificationData = {
          'userId': userId,
          'title': 'Report Assigned',
          'message': 'Your report "$reportTitle" has been assigned to a team member by $assignedBy',
          'type': 'assignment',
          'reportId': reportId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        developer.log('📋 Notification data: $notificationData', name: 'NotificationController');
        
        await _firestore.collection('notifications').add(notificationData);
        
        developer.log('✅ Assignment notification created successfully', name: 'NotificationController');
        return; // Success, exit the retry loop
      } catch (e) {
        retries++;
        developer.log('❌ Error creating assignment notification (attempt $retries): $e', name: 'NotificationController');
        
        if (retries >= maxRetries) {
          developer.log('❌ Max retries reached. Stack trace: ${StackTrace.current}', name: 'NotificationController');
          rethrow;
        }
        
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 500 * retries));
      }
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      developer.log('✅ Notification marked as read: $notificationId', name: 'NotificationController');
    } catch (e) {
      developer.log('❌ Error marking notification as read: $e', name: 'NotificationController');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        developer.log('ℹ️ No unread notifications to mark', name: 'NotificationController');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      developer.log('✅ Marked ${querySnapshot.docs.length} notifications as read', name: 'NotificationController');
    } catch (e) {
      developer.log('❌ Error marking all notifications as read: $e', name: 'NotificationController');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      developer.log('✅ Notification deleted: $notificationId', name: 'NotificationController');
    } catch (e) {
      developer.log('❌ Error deleting notification: $e', name: 'NotificationController');
      rethrow;
    }
  }

  // Get unread notifications count
  Stream<int> getUnreadCount(String userId) {
    if (userId.isEmpty) {
      return Stream.value(0);
    }
    
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size)
        .handleError((error) {
          developer.log('❌ Error getting unread count: $error', name: 'NotificationController');
          return 0;
        });
  }

  // Helper method to format status text
  String _formatStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }
}