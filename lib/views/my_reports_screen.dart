import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'package:uee_project/models/report_model.dart';
import 'package:uee_project/utils/app_textstyles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uee_project/views/edit_report_screen.dart';
import 'package:uee_project/views/user_home_screen.dart'; // Import for LanguageController

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final AuthController _authController = Get.find();
  final ReportController _reportController = Get.find();
  late final LanguageController _languageController;
  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = ''.obs;
  final RxList<ReportModel> _reports = <ReportModel>[].obs;

  // Translation keys for My Reports Screen
  final Map<String, Map<String, String>> _translations = {
    'en_US': {
      'my_reports': 'My Reports',
      'refresh': 'Refresh',
      'loading_reports': 'Loading your reports...',
      'failed_load_reports': 'Failed to Load Reports',
      'try_again': 'Try Again',
      'no_reports_yet': 'No Reports Yet',
      'submit_first_report': 'Submit your first infrastructure issue report',
      'create_first_report': 'Create First Report',
      'using_compatibility_mode': 'Using compatibility mode',
      'warning': 'Warning',
      'reports_loading_compatibility': 'Reports are loading in compatibility mode. Some features may be limited.',
      'error': 'Error',
      'failed_refresh': 'Failed to refresh reports',
      'location': 'Location',
      'edit_report': 'Edit Report',
      'delete_report': 'Delete Report',
      'delete_confirmation': 'Delete Report',
      'delete_message': 'Are you sure you want to delete this report? This action cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'success': 'Success',
      'report_deleted': 'Report deleted successfully',
      'failed_delete': 'Failed to delete report',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      // Status
      'status_pending': 'Pending',
      'status_in_progress': 'In Progress',
      'status_resolved': 'Resolved',
      // Priority
      'priority_urgent': 'URGENT',
      'priority_high': 'HIGH',
      'priority_medium': 'MEDIUM',
      'priority_low': 'LOW',
      // Categories
      'Roads': 'Roads',
      'Water Supply': 'Water Supply',
      'Electricity': 'Electricity',
      'Drainage': 'Drainage',
      'Street Lights': 'Street Lights',
      'Waste Management': 'Waste Management',
      'Public Transport': 'Public Transport',
      'Parks & Recreation': 'Parks & Recreation',
      'Other': 'Other',
    },
    'si_LK': {
      'my_reports': 'මගේ වාර්තා',
      'refresh': 'නැවුම් කරන්න',
      'loading_reports': 'ඔබේ වාර්තා පූරණය වෙමින්...',
      'failed_load_reports': 'වාර්තා පූරණය කිරීමට අසමත් විය',
      'try_again': 'නැවත උත්සාහ කරන්න',
      'no_reports_yet': 'තවම වාර්තා නැත',
      'submit_first_report': 'ඔබේ පළමු යටිතල පහසුකම් ගැටළු වාර්තාව ඉදිරිපත් කරන්න',
      'create_first_report': 'පළමු වාර්තාව සාදන්න',
      'using_compatibility_mode': 'ගැළපුම් ආකාරය භාවිතා කරමින්',
      'warning': 'අනතුරු ඇඟවීම',
      'reports_loading_compatibility': 'වාර්තා ගැළපුම් ආකාරයෙන් පූරණය වෙමින් පවතී. සමහර විශේෂාංග සීමිත විය හැක.',
      'error': 'දෝෂයකි',
      'failed_refresh': 'වාර්තා නැවුම් කිරීමට අසමත් විය',
      'location': 'ස්ථානය',
      'edit_report': 'වාර්තාව සංස්කරණය කරන්න',
      'delete_report': 'වාර්තාව මකන්න',
      'delete_confirmation': 'වාර්තාව මකන්න',
      'delete_message': 'ඔබට මෙම වාර්තාව මකා දැමීමට අවශ්‍ය බව විශ්වාසද? මෙම ක්‍රියාව අහෝසි කළ නොහැක.',
      'cancel': 'අවලංගු කරන්න',
      'delete': 'මකන්න',
      'success': 'සාර්ථකයි',
      'report_deleted': 'වාර්තාව සාර්ථකව මකා දමන ලදී',
      'failed_delete': 'වාර්තාව මකා දැමීමට අසමත් විය',
      'today': 'අද',
      'yesterday': 'ඊයේ',
      'days_ago': 'දින පෙර',
      // Status
      'status_pending': 'පොරොත්තුවෙන්',
      'status_in_progress': 'ක්‍රියාත්මක වෙමින්',
      'status_resolved': 'විසඳා ඇත',
      // Priority
      'priority_urgent': 'හදිසි',
      'priority_high': 'ඉහළ',
      'priority_medium': 'මධ්‍යම',
      'priority_low': 'අඩු',
      // Categories in Sinhala
      'Roads': 'මාර්ග',
      'Water Supply': 'ජල සැපයුම',
      'Electricity': 'විදුලිය',
      'Drainage': 'ජලාපවහන',
      'Street Lights': 'වීදි ආලෝක',
      'Waste Management': 'අපද්‍රව්‍ය කළමනාකරණය',
      'Public Transport': 'පොදු ප්‍රවාහනය',
      'Parks & Recreation': 'උද්‍යාන සහ විනෝදාස්වාදය',
      'Other': 'වෙනත්',
    },
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize language controller
    if (Get.isRegistered<LanguageController>()) {
      _languageController = Get.find<LanguageController>();
    } else {
      _languageController = Get.put(LanguageController());
    }
    
    _loadUserReports();
  }

  String _tr(String key) {
    final localeKey = '${_languageController.currentLocale.value.languageCode}_${_languageController.currentLocale.value.countryCode}';
    return _translations[localeKey]?[key] ?? key;
  }

  void _loadUserReports() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final userId = _authController.user?.uid ?? '';
      print('🔄 Loading reports for user: $userId');
      
      // Use stream to get real-time updates with error handling
      final stream = _reportController.getUserReports(userId);
      stream.listen(
        (reports) {
          _reports.value = reports;
          _isLoading.value = false;
          print('✅ Loaded ${reports.length} reports');
        },
        onError: (error) {
          print('❌ Error loading reports: $error');
          _isLoading.value = false;
          _errorMessage.value = 'Failed to load reports. Please pull to refresh.';
          Get.snackbar(
            _tr('warning'),
            _tr('reports_loading_compatibility'),
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isLoading.value = false;
      _errorMessage.value = 'Error loading reports: $e';
      print('❌ Exception loading reports: $e');
    }
  }

  Future<void> _refreshReports() async {
    try {
      final userId = _authController.user?.uid ?? '';
      await _reportController.refreshUserReports(userId);
      _reports.value = _reportController.userReports;
    } catch (e) {
      Get.snackbar(
        _tr('error'),
        '${_tr('failed_refresh')}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _languageController.translate('select_language'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              'English',
              const Locale('en', 'US'),
              Icons.language,
              _languageController.isEnglish,
              colorScheme,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context,
              'සිංහල',
              const Locale('si', 'LK'),
              Icons.language,
              _languageController.isSinhala,
              colorScheme,
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _languageController.translate('close'),
              style: GoogleFonts.poppins(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    Locale locale,
    IconData icon,
    bool isSelected,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        _languageController.changeLanguage(locale);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      // This will rebuild when language changes
      final _ = _languageController.currentLocale.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text(_tr('my_reports'), style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Language Toggle Button
            IconButton(
              onPressed: () => _showLanguageDialog(context),
              icon: Icon(
                Icons.language,
                color: colorScheme.primary,
              ),
              tooltip: _languageController.translate('change_language'),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshReports,
              tooltip: _tr('refresh'),
            ),
          ],
        ),
        body: Obx(() {
          if (_isLoading.value && _reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_tr('loading_reports')),
                ],
              ),
            );
          }

          if (_errorMessage.isNotEmpty && _reports.isEmpty) {
            return _buildErrorState(context, isDark);
          }

          if (_reports.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return RefreshIndicator(
            onRefresh: _refreshReports,
            child: Column(
              children: [
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tr('using_compatibility_mode'),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return _buildReportCard(report, isDark, context);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            _tr('failed_load_reports'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadUserReports,
            child: Text(_tr('try_again')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: _refreshReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
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
                  _tr('no_reports_yet'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tr('submit_first_report'),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(_tr('create_first_report')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report, bool isDark, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    _getStatusText(report.status),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: _getStatusColor(report.status),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              report.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Details row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDetailChip(
                  Icons.category,
                  _tr(report.category),
                  Colors.blue,
                ),
                _buildDetailChip(
                  Icons.flag,
                  _getPriorityText(report.priority),
                  _getPriorityColor(report.priority),
                ),
                if (report.location?.address.isNotEmpty == true)
                  _buildDetailChip(
                    Icons.location_on,
                    _tr('location'),
                    Colors.green,
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Date and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(report.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                // Action buttons
                Row(
                  children: [
                    // Edit button - only show for pending reports
                    if (report.status == 'pending')
                      IconButton(
                        onPressed: () {
                          _editReport(report);
                        },
                        icon: Icon(Icons.edit, size: 20, color: Colors.blue),
                        tooltip: _tr('edit_report'),
                      ),
                    
                    // Delete button - only show for pending reports
                    if (report.status == 'pending')
                      IconButton(
                        onPressed: () {
                          _deleteReport(report.id, context);
                        },
                        icon: Icon(Icons.delete, size: 20, color: Colors.red),
                        tooltip: _tr('delete_report'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        return _tr('status_pending');
      case 'in_progress':
        return _tr('status_in_progress');
      case 'resolved':
        return _tr('status_resolved');
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

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'urgent':
        return _tr('priority_urgent');
      case 'high':
        return _tr('priority_high');
      case 'medium':
        return _tr('priority_medium');
      case 'low':
        return _tr('priority_low');
      default:
        return priority.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return _tr('today');
    } else if (difference.inDays == 1) {
      return _tr('yesterday');
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${_tr('days_ago')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editReport(ReportModel report) {
    Get.to(() => EditReportScreen(report: report));
  }

  void _deleteReport(String reportId, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_tr('delete_confirmation')),
          content: Text(_tr('delete_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_tr('cancel'), style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _reportController.deleteReport(reportId);
                  Get.snackbar(
                    _tr('success'),
                    _tr('report_deleted'),
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  // Refresh the list
                  _refreshReports();
                } catch (e) {
                  Get.snackbar(
                    _tr('error'),
                    '${_tr('failed_delete')}: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text(_tr('delete'), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}