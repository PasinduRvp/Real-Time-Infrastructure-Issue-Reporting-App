// controllers/user_management_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uee_project/models/user_model.dart';
import 'dart:developer' as developer;

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final _users = <UserModel>[].obs;
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;
  final _selectedRole = 'all'.obs;
  
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedRole => _selectedRole.value;
  
  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }
  
  // Fetch all users
  void fetchUsers() async {
    try {
      _isLoading.value = true;
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      _users.value = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      developer.log('Error fetching users: $e', name: 'UserManagementController');
      Get.snackbar('Error', 'Failed to load users');
    }
  }
  
  // Get filtered users
  List<UserModel> get filteredUsers {
    var filtered = _users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
                           user.email.toLowerCase().contains(_searchQuery.value.toLowerCase());
      final matchesRole = _selectedRole.value == 'all' || user.role == _selectedRole.value;
      return matchesSearch && matchesRole;
    }).toList();
    
    // Sort by createdAt descending (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }
  
  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }
  
  // Update role filter
  void updateRoleFilter(String role) {
    _selectedRole.value = role;
  }
  
  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final reportsSnapshot = await _firestore.collection('reports').get();
      
      final totalUsers = usersSnapshot.docs.length;
      final adminCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'admin').length;
      final userCount = usersSnapshot.docs.where((doc) => doc.data()['role'] == 'user').length;
      
      // Calculate monthly active users (users created in last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final monthlyActiveUsers = usersSnapshot.docs.where((doc) {
        final createdAt = (doc.data()['createdAt'] as Timestamp?)?.toDate();
        return createdAt != null && createdAt.isAfter(thirtyDaysAgo);
      }).length;
      
      // Get reports per user statistics
      final reportsByUser = <String, int>{};
      for (var report in reportsSnapshot.docs) {
        final userId = report.data()['userId'] as String?;
        if (userId != null) {
          reportsByUser[userId] = (reportsByUser[userId] ?? 0) + 1;
        }
      }
      
      return {
        'totalUsers': totalUsers,
        'adminCount': adminCount,
        'userCount': userCount,
        'monthlyActiveUsers': monthlyActiveUsers,
        'totalReports': reportsSnapshot.docs.length,
        'avgReportsPerUser': totalUsers > 0 ? (reportsSnapshot.docs.length / totalUsers).toStringAsFixed(1) : '0',
      };
    } catch (e) {
      developer.log('Error getting user statistics: $e', name: 'UserManagementController');
      return {
        'totalUsers': 0,
        'adminCount': 0,
        'userCount': 0,
        'monthlyActiveUsers': 0,
        'totalReports': 0,
        'avgReportsPerUser': '0',
      };
    }
  }
  
  // Get user activity data for chart
  Future<List<Map<String, dynamic>>> getUserActivityData() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final now = DateTime.now();
      final monthlyData = <String, int>{};
      
      // Initialize last 6 months
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
        monthlyData[monthKey] = 0;
      }
      
      // Count users by month
      for (var doc in snapshot.docs) {
        final createdAt = (doc.data()['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) {
          final monthKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
          if (monthlyData.containsKey(monthKey)) {
            monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
          }
        }
      }
      
      return monthlyData.entries.map((entry) {
        final parts = entry.key.split('-');
        final month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        return {
          'month': _getMonthName(month.month),
          'users': entry.value,
        };
      }).toList();
    } catch (e) {
      developer.log('Error getting user activity data: $e', name: 'UserManagementController');
      return [];
    }
  }
  
  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update local list
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        final user = _users[index];
        _users[index] = UserModel(
          id: user.id,
          email: user.email,
          name: user.name,
          role: newRole,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      
      Get.snackbar('Success', 'User role updated successfully');
    } catch (e) {
      developer.log('Error updating user role: $e', name: 'UserManagementController');
      Get.snackbar('Error', 'Failed to update user role');
    }
  }
  
  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      _users.removeWhere((user) => user.id == userId);
      Get.snackbar('Success', 'User deleted successfully');
    } catch (e) {
      developer.log('Error deleting user: $e', name: 'UserManagementController');
      Get.snackbar('Error', 'Failed to delete user');
    }
  }
  
  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}