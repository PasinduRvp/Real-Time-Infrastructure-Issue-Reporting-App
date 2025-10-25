import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'status_update', 'assignment', 'general'
  final String reportId;
  final String userId;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.reportId,
    required this.userId,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      reportId: data['reportId'] ?? '',
      userId: data['userId'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'reportId': reportId,
      'userId': userId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (metadata != null) 'metadata': metadata,
    };
  }
}