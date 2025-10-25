import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final ReportLocation? location;
  final List<String> images;
  final String userId;        // Firebase Auth UID
  final String reportedBy;    // Email for display
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool aiDetected;
  final double aiConfidence;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.location,
    required this.images,
    required this.userId,        // Required field
    required this.reportedBy,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.aiDetected = false,
    this.aiConfidence = 0.0,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    
    // Handle location data
    ReportLocation? locationData;
    if (data['location'] != null) {
      locationData = ReportLocation.fromMap(Map<String, dynamic>.from(data['location']));
    }

    // Handle timestamps
    Timestamp? createdAtTimestamp = data['createdAt'];
    Timestamp? updatedAtTimestamp = data['updatedAt'];
    
    DateTime createdAt = createdAtTimestamp != null 
        ? createdAtTimestamp.toDate() 
        : DateTime.now();
    
    DateTime updatedAt = updatedAtTimestamp != null 
        ? updatedAtTimestamp.toDate() 
        : DateTime.now();

    return ReportModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'pending',
      location: locationData,
      images: List<String>.from(data['images'] ?? []),
      // Handle both new userId and old reportedBy for backward compatibility
      userId: data['userId'] ?? data['reportedBy'] ?? '',  
      reportedBy: data['reportedBy'] ?? '',
      assignedTo: data['assignedTo'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      aiDetected: data['aiDetected'] ?? false,
      aiConfidence: (data['aiConfidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'location': location?.toMap(),
      'images': images,
      'userId': userId,          // Include userId
      'reportedBy': reportedBy,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'aiDetected': aiDetected,
      'aiConfidence': aiConfidence,
    };
  }

  // Helper method to check if report has valid location
  bool get hasLocation => location != null && location!.latitude != 0.0 && location!.longitude != 0.0;

  // Helper method to get status color
  String get statusText {
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

  // Helper method to get priority color
  String get priorityText {
    return priority.toUpperCase();
  }
}

class ReportLocation {
  final double latitude;
  final double longitude;
  final String address;

  ReportLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory ReportLocation.fromMap(Map<String, dynamic> map) {
    return ReportLocation(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}