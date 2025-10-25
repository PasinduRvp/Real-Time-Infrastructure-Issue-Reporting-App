import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:uee_project/utils/app_textstyles.dart';
import 'package:uee_project/views/admin_reports_screen.dart';
import 'package:uee_project/views/analytics_screen.dart';
import 'package:uee_project/views/profile_screen.dart';
import 'package:uee_project/views/user_management_screen.dart';
import 'package:uee_project/views/issue_map_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  final AuthController authController = Get.find();
  final ReportController reportController = Get.find();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 9.0),
          child: Text(
            'InfraGuard Admin',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Overview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor and manage all infrastructure reports',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Cards - FIXED LAYOUT
            FutureBuilder<Map<String, int>>(
              future: reportController.getReportStatistics(),
              builder: (context, snapshot) {
                final stats =
                    snapshot.data ??
                    {'pending': 0, 'in_progress': 0, 'resolved': 0, 'total': 0};

                return Row(
                  children: [
                    _buildStatCard(
                      context,
                      'Total',
                      stats['total']!.toString(),
                      Icons.assignment,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      'Pending',
                      stats['pending']!.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      'Progress',
                      stats['in_progress']!.toString(),
                      Icons.build,
                      Colors.purple,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      'Resolved',
                      stats['resolved']!.toString(),
                      Icons.verified,
                      Colors.green,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Charts Section
            Container(
              height: 200,
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
              child: FutureBuilder<Map<String, int>>(
                future: reportController.getReportStatistics(),
                builder: (context, snapshot) {
                  final stats =
                      snapshot.data ??
                      {'pending': 0, 'in_progress': 0, 'resolved': 0};

                  final chartData = [
                    _ChartData('Pending', stats['pending']!, Colors.orange),
                    _ChartData(
                      'In Progress',
                      stats['in_progress']!,
                      Colors.purple,
                    ),
                    _ChartData('Resolved', stats['resolved']!, Colors.green),
                  ];

                  return SfCircularChart(
                    title: ChartTitle(
                      text: 'Reports Distribution',
                      textStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    series: <CircularSeries>[
                      DoughnutSeries<_ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.category,
                        yValueMapper: (_ChartData data, _) => data.value,
                        pointColorMapper: (_ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Admin Action Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                _buildAdminActionCard(
                  context,
                  'Manage Reports',
                  Icons.assignment_rounded,
                  Colors.blue,
                  'View and manage all reports',
                  () {
                    Get.to(() => const AdminReportsScreen());
                  },
                ),
                _buildAdminActionCard(
                  context,
                  'Analytics',
                  Icons.analytics_rounded,
                  Colors.purple,
                  'View detailed analytics',
                  () {
                    Get.to(() => const AnalyticsScreen());
                  },
                ),
                _buildAdminActionCard(
                  context,
                  'User Management',
                  Icons.people_rounded,
                  Colors.green,
                  'Manage system users',
                  () {
                    Get.to(() => const UserManagementScreen());
                  },
                ),
                _buildAdminActionCard(
                  context,
                  'Issues Map',
                  Icons.map_rounded,
                  Colors.orange,
                  'View all issues on map',
                  () {
                    Get.to(() => const IssueMapScreen());
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Reports Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Reports',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const AdminReportsScreen());
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<dynamic>>(
                  stream: reportController.getAllReports(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            'Error loading reports',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      );
                    }

                    final reports = snapshot.data ?? [];
                    final recentReports = reports.take(3).toList();

                    if (recentReports.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.report_problem_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Reports Yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No reports have been submitted yet',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
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
                      itemCount: recentReports.length,
                      itemBuilder: (context, index) {
                        final report = recentReports[index];
                        return _buildAdminReportItem(
                          report.title,
                          report.category,
                          report.status,
                          report.priority,
                          report.createdAt,
                          _getStatusColor(report.status),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  Widget _buildModernBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            index: 0,
            isActive: _currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.assignment_rounded,
            label: 'Reports',
            index: 1,
            isActive: _currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.analytics_rounded,
            label: 'Analytics',
            index: 2,
            isActive: _currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.map_rounded,
            label: 'Map',
            index: 3,
            isActive: _currentIndex == 3,
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            index: 4,
            isActive: _currentIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
            _onBottomNavItemTapped(index);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? colorScheme.primary : Colors.grey[500],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? colorScheme.primary : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onBottomNavItemTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Get.to(() => const AdminReportsScreen());
        break;
      case 2:
        Get.to(() => const AnalyticsScreen());
        break;
      case 3:
        Get.to(() => const IssueMapScreen());
        break;
      case 4:
        Get.to(() => ProfileScreen());
        break;
    }
  }

  // FIXED: Responsive stat card that handles larger numbers
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamically adjust font size based on number length
    double getFontSize(String val) {
      if (val.length <= 2) return 22;
      if (val.length == 3) return 18;
      return 16;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: getFontSize(value),
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
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

  Widget _buildAdminActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminReportItem(
    String title,
    String category,
    String status,
    String priority,
    DateTime date,
    Color statusColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            Icons.report_problem_rounded,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _getPriorityColor(priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(date)} • ${_getStatusText(status)}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            _getStatusText(status),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: statusColor,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ChartData {
  final String category;
  final int value;
  final Color color;

  _ChartData(this.category, this.value, this.color);
}