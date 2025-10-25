import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:uee_project/models/report_model.dart';
import 'package:uee_project/utils/app_textstyles.dart';
import 'package:uee_project/views/issue_map_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ReportController _reportController = Get.find();
  String _selectedStatusFilter = 'all';
  String _selectedCategoryFilter = 'all';
  String _selectedPriorityFilter = 'all';
  
  final List<String> _statusFilters = ['all', 'pending', 'in_progress', 'resolved'];
  final List<String> _categoryFilters = [
    'all', 'Road Damage', 'Flooding', 'Garbage', 
    'Street Light', 'Water Leak', 'Sewage Issue', 'Other'
  ];
  final List<String> _priorityFilters = ['all', 'urgent', 'high', 'medium', 'low'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Reports', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCompactFilterSection(isDark),
          const SizedBox(height: 8),
          Expanded(
            child: _buildReportsList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactFilterDropdown(
              'Status',
              _selectedStatusFilter,
              _statusFilters,
              (value) => setState(() => _selectedStatusFilter = value!),
              _getStatusFilterText,
              isDark,
              Icons.flag_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCompactFilterDropdown(
              'Category',
              _selectedCategoryFilter,
              _categoryFilters,
              (value) => setState(() => _selectedCategoryFilter = value!),
              _getCategoryFilterText,
              isDark,
              Icons.category_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCompactFilterDropdown(
              'Priority',
              _selectedPriorityFilter,
              _priorityFilters,
              (value) => setState(() => _selectedPriorityFilter = value!),
              _getPriorityFilterText,
              isDark,
              Icons.priority_high_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterDropdown(
    String label,
    String selectedValue,
    List<String> filters,
    ValueChanged<String?> onChanged,
    String Function(String) getText,
    bool isDark,
    IconData icon,
  ) {
    final textColor = isDark ? Colors.white : Colors.black;
    final dropdownColor = isDark ? Colors.grey[700]! : Colors.grey[50]!;
    final borderColor = isDark ? Colors.grey[600]! : Colors.grey[300]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: dropdownColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              onChanged: onChanged,
              items: filters.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          getText(filter),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: textColor,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: textColor, size: 18),
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
              style: AppTextStyles.bodySmall.copyWith(
                color: textColor,
                fontSize: 12,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportsList(bool isDark) {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportController.getAllReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final allReports = snapshot.data ?? [];
        final filteredReports = _filterReports(allReports);

        if (filteredReports.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredReports.length,
          itemBuilder: (context, index) {
            final report = filteredReports[index];
            return _buildModernReportCard(report, isDark);
          },
        );
      },
    );
  }

  Widget _buildModernReportCard(ReportModel report, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader(report, isDark),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportContent(report),
                const SizedBox(height: 16),
                _buildMetadataGrid(report, isDark),
                const SizedBox(height: 16),
                if (report.images.isNotEmpty) _buildModernImageSection(report),
                const SizedBox(height: 16),
                _buildModernActionButtons(report),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeader(ReportModel report, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(report.status).withValues(alpha: 0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(report.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusText(report.status).toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: _getStatusColor(report.status),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPriorityColor(report.priority),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              report.priority.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showCustomStatusMenu(context, report),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomStatusMenu(BuildContext context, ReportModel report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Update Status',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            _buildStatusOption('pending', 'Mark as Pending', report),
            _buildStatusOption('in_progress', 'Mark as In Progress', report),
            _buildStatusOption('resolved', 'Mark as Resolved', report),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String status, String text, ReportModel report) {
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: _getStatusColor(status),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(text, style: AppTextStyles.bodyMedium),
      onTap: () {
        Navigator.pop(context);
        _updateReportStatus(report.id, status);
      },
    );
  }

  Widget _buildReportContent(ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(report.category),
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          report.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey[700],
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMetadataGrid(ReportModel report, bool isDark) {
    final textColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildMetadataItem(
                Icons.person_outline,
                'Reported by',
                report.reportedBy,
                textColor,
              ),
              const SizedBox(width: 16),
              _buildMetadataItem(
                Icons.calendar_today_outlined,
                'Reported on',
                DateFormat('MMM dd, yyyy').format(report.createdAt),
                textColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetadataItem(
                Icons.access_time_outlined,
                'Time',
                DateFormat('hh:mm a').format(report.createdAt),
                textColor,
              ),
              const SizedBox(width: 16),
              _buildMetadataItem(
                Icons.location_on_outlined,
                'Location',
                report.location?.address ?? 'Not specified',
                textColor,
                isLocation: true,
                onTap: () => _openLocationOnMap(report),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String label, String value, Color? textColor, {bool isLocation = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: isLocation ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: isLocation ? Colors.blue : textColor,
                fontWeight: isLocation ? FontWeight.w500 : FontWeight.normal,
                decoration: isLocation ? TextDecoration.underline : TextDecoration.none,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernImageSection(ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Attached Images (${report.images.length})',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: report.images.length,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(report.images[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showImageDialog(report.images[index]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButtons(ReportModel report) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sendReportEmail(report),
            icon: const Icon(Icons.email_outlined, size: 18),
            label: const Text('Share via Email'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _openLocationOnMap(report),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('View on Map'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendReportEmail(ReportModel report) async {
    try {
      final subject = Uri.encodeComponent('Report: ${report.title}');
      final body = Uri.encodeComponent(_generateEmailBody(report));
      
      final Uri emailUri = Uri(
        scheme: 'mailto',
        query: 'subject=$subject&body=$body',
      );

      if (await canLaunchUrl(emailUri)) {
        final launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          throw 'Failed to launch email app';
        }
      } else {
        throw 'No email app found';
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Could not open email app. Please install an email application (Gmail, Outlook, etc.)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  String _generateEmailBody(ReportModel report) {
    final buffer = StringBuffer();
    
    buffer.writeln('ISSUE REPORT DETAILS');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    buffer.writeln('REPORT ID: ${report.id}');
    buffer.writeln('Title: ${report.title}');
    buffer.writeln('Category: ${report.category}');
    buffer.writeln('Status: ${_getStatusText(report.status)}');
    buffer.writeln('Priority: ${report.priority.toUpperCase()}');
    buffer.writeln();
    
    buffer.writeln('DESCRIPTION:');
    buffer.writeln(report.description);
    buffer.writeln();
    
    buffer.writeln('REPORTER INFORMATION:');
    buffer.writeln('Reported by: ${report.reportedBy}');
    buffer.writeln('Report Date: ${_formatDate(report.createdAt)}');
    buffer.writeln();
    
    buffer.writeln('LOCATION:');
    if (report.location != null) {
      buffer.writeln('Address: ${report.location!.address}');
      if (report.hasLocation) {
        buffer.writeln('Coordinates: ${report.location!.latitude}, ${report.location!.longitude}');
        buffer.writeln('Google Maps: https://www.google.com/maps?q=${report.location!.latitude},${report.location!.longitude}');
      }
    } else {
      buffer.writeln('Location not available');
    }
    buffer.writeln();
    
    if (report.images.isNotEmpty) {
      buffer.writeln('ATTACHED IMAGES (${report.images.length}):');
      for (int i = 0; i < report.images.length; i++) {
        buffer.writeln('${i + 1}. ${report.images[i]}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('=' * 50);
    buffer.writeln('This report was sent from the UEE Project Admin Portal');
    
    return buffer.toString();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Reports...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to Load Reports',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => setState(() {}),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.report_problem_outlined,
                size: 64,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Reports Found',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Road Damage':
        return Icons.directions_car;
      case 'Flooding':
        return Icons.water_damage;
      case 'Garbage':
        return Icons.delete;
      case 'Street Light':
        return Icons.lightbulb;
      case 'Water Leak':
        return Icons.water_drop;
      case 'Sewage Issue':
        return Icons.plumbing;
      default:
        return Icons.report_problem;
    }
  }

  void _updateReportStatus(String reportId, String status) async {
    try {
      await _reportController.updateReportStatus(reportId, status);
      if (mounted) {
        Get.snackbar(
          'Success',
          'Report status updated to ${_getStatusText(status)}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to update report status: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _openLocationOnMap(ReportModel report) {
    if (report.location != null && report.hasLocation) {
      Get.to(() => IssueMapScreen(
        initialLocation: report.location!,
        selectedReport: report,
      ));
    } else {
      Get.snackbar(
        'Location Unavailable',
        'This report does not have valid location data',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ReportModel> _filterReports(List<ReportModel> reports) {
    return reports.where((report) {
      final statusMatch = _selectedStatusFilter == 'all' || report.status == _selectedStatusFilter;
      final categoryMatch = _selectedCategoryFilter == 'all' || report.category == _selectedCategoryFilter;
      final priorityMatch = _selectedPriorityFilter == 'all' || report.priority == _selectedPriorityFilter;
      return statusMatch && categoryMatch && priorityMatch;
    }).toList();
  }

  String _getStatusFilterText(String filter) {
    switch (filter) {
      case 'all': return 'All';
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      default: return 'All';
    }
  }

  String _getCategoryFilterText(String filter) {
    return filter == 'all' ? 'All' : filter;
  }

  String _getPriorityFilterText(String filter) {
    switch (filter) {
      case 'all': return 'All';
      case 'urgent': return 'Urgent';
      case 'high': return 'High';
      case 'medium': return 'Medium';
      case 'low': return 'Low';
      default: return 'All';
    }
  }

  String _getEmptyStateMessage() {
    if (_selectedStatusFilter != 'all' || _selectedCategoryFilter != 'all' || _selectedPriorityFilter != 'all') {
      return 'No reports match the selected filters. Try adjusting your filter criteria.';
    }
    return 'No reports have been submitted yet. Check back later for new reports.';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'resolved': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      default: return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.blue;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}