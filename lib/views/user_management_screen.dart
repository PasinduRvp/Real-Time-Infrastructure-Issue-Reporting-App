// lib/views/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:uee_project/controllers/user_management_controller.dart';
import 'package:uee_project/models/user_model.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchUsers();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              FutureBuilder<Map<String, dynamic>>(
                future: controller.getUserStatistics(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {
                    'totalUsers': 0,
                    'adminCount': 0,
                    'userCount': 0,
                    'monthlyActiveUsers': 0,
                    'totalReports': 0,
                    'avgReportsPerUser': '0',
                  };

                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            'Total Users',
                            stats['totalUsers'].toString(),
                            Icons.people,
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Admins',
                            stats['adminCount'].toString(),
                            Icons.admin_panel_settings,
                            Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            'Regular Users',
                            stats['userCount'].toString(),
                            Icons.person,
                            Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Monthly Active',
                            stats['monthlyActiveUsers'].toString(),
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            'Total Reports',
                            stats['totalReports'].toString(),
                            Icons.assignment,
                            Colors.red,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Avg Reports',
                            stats['avgReportsPerUser'],
                            Icons.bar_chart,
                            Colors.teal,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // User Activity Chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Growth (Last 6 Months)',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: controller.getUserActivityData(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                'No data available',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }

                          return SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            primaryYAxis: NumericAxis(
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<Map<String, dynamic>, String>(
                                dataSource: snapshot.data!,
                                xValueMapper: (data, _) => data['month'],
                                yValueMapper: (data, _) => data['users'],
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  textStyle: GoogleFonts.poppins(fontSize: 10),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search and Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: controller.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: GoogleFonts.poppins(),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.white,
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Obx(() => DropdownButton<String>(
                      value: controller.selectedRole,
                      underline: const SizedBox(),
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Roles', style: GoogleFonts.poppins()),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Admin', style: GoogleFonts.poppins()),
                        ),
                        DropdownMenuItem(
                          value: 'user',
                          child: Text('User', style: GoogleFonts.poppins()),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateRoleFilter(value);
                        }
                      },
                    )),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Users List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Users',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Obx(() => Text(
                    '${controller.filteredUsers.length} users',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  )),
                ],
              ),

              const SizedBox(height: 12),

              // Users List
              Obx(() {
                if (controller.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final filteredUsers = controller.filteredUsers;

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Users Found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(context, user, controller);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    UserModel user,
    UserManagementController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: user.role == 'admin' 
              ? Colors.purple.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          child: Icon(
            user.role == 'admin' 
                ? Icons.admin_panel_settings 
                : Icons.person,
            color: user.role == 'admin' ? Colors.purple : Colors.blue,
          ),
        ),
        title: Text(
          user.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: user.role == 'admin'
                        ? Colors.purple.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: user.role == 'admin' ? Colors.purple : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Joined ${_formatDate(user.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: (value) {
            if (value == 'change_role') {
              _showRoleChangeDialog(context, user, controller);
            } else if (value == 'delete') {
              _showDeleteDialog(context, user, controller);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'change_role',
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, size: 20),
                  const SizedBox(width: 12),
                  Text('Change Role', style: GoogleFonts.poppins()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    'Delete User',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleChangeDialog(
    BuildContext context,
    UserModel user,
    UserManagementController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change User Role', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change role for ${user.name}?',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            Text(
              'Current role: ${user.role}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              final newRole = user.role == 'admin' ? 'user' : 'admin';
              controller.updateUserRole(user.id, newRole);
              Get.back();
            },
            child: Text(
              'Change to ${user.role == 'admin' ? 'User' : 'Admin'}',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    UserModel user,
    UserManagementController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteUser(user.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}