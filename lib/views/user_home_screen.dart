import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:uee_project/controllers/notification_controller.dart';
import 'package:uee_project/views/report_issue_screen.dart';
import 'package:uee_project/views/my_reports_screen.dart';
import 'package:uee_project/views/issue_map_screen.dart';
import 'package:uee_project/views/profile_screen.dart';
import 'package:uee_project/views/notifications_screen.dart';
import 'package:uee_project/views/emergency_contacts_screen.dart';
import 'package:uee_project/models/report_model.dart';

// ==================== LANGUAGE CONTROLLER ====================
class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';
  
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;
  
  // Translation Map
  final Map<String, Map<String, String>> translations = {
    'en_US': {
      'app_name': 'InfraGuard',
      'welcome': 'Welcome!',
      'welcome_message': 'Report infrastructure issues in your area and help improve your community',
      'quick_actions': 'Quick Actions',
      'recent_reports': 'Recent Reports',
      'view_all': 'View All',
      'notifications': 'Notifications',
      'total': 'Total',
      'pending': 'Pending',
      'resolved': 'Resolved',
      'report_issue': 'Report Issue',
      'report_issue_desc': 'Submit new infrastructure issue',
      'my_reports': 'My Reports',
      'my_reports_desc': 'View your submitted reports',
      'issues_map': 'Issues Map',
      'issues_map_desc': 'View all issues on map',
      'emergency_contacts': 'Emergency Contacts',
      'emergency_contacts_desc': 'Municipal council contacts',
      'home': 'Home',
      'reports': 'Reports',
      'map': 'Map',
      'profile': 'Profile',
      'status_pending': 'Pending',
      'status_in_progress': 'In Progress',
      'status_resolved': 'Resolved',
      'no_reports_yet': 'No Reports Yet',
      'no_reports_message': 'Submit your first report to get started',
      'error_loading_reports': 'Error loading reports',
      'just_now': 'Just now',
      'minutes_ago': 'm ago',
      'hours_ago': 'h ago',
      'days_ago': 'd ago',
      'language': 'Language',
      'english': 'English',
      'sinhala': 'සිංහල',
      'change_language': 'Change Language',
      'select_language': 'Select Language',
      'close': 'Close',
    },
    'si_LK': {
      'app_name': 'InfraGuard',
      'welcome': 'ආයුබෝවන්!',
      'welcome_message': 'ඔබේ ප්‍රදේශයේ යටිතල පහසුකම් ගැටළු වාර්තා කර ඔබේ ප්‍රජාව වැඩිදියුණු කිරීමට උදව් කරන්න',
      'quick_actions': 'ඉක්මන් ක්‍රියා',
      'recent_reports': 'මෑත වාර්තා',
      'view_all': 'සියල්ල බලන්න',
      'notifications': 'දැනුම්දීම්',
      'total': 'මුළු',
      'pending': 'පොරොත්තුවෙන්',
      'resolved': 'විසඳා ඇත',
      'report_issue': 'ගැටළුවක් වාර්තා කරන්න',
      'report_issue_desc': 'නව යටිතල පහසුකම් ගැටළුවක් ඉදිරිපත් කරන්න',
      'my_reports': 'මගේ වාර්තා',
      'my_reports_desc': 'මම ඉදිරිපත් කළ වාර්තා බලන්න',
      'issues_map': 'ගැටළු සිතියම',
      'issues_map_desc': 'සියලු ගැටළු සිතියමෙහි බලන්න',
      'emergency_contacts': 'හදිසි සම්බන්ධතා',
      'emergency_contacts_desc': 'නගර සභා සම්බන්ධතා',
      'home': 'මුල් පිටුව',
      'reports': 'වාර්තා',
      'map': 'සිතියම',
      'profile': 'මගේ ගිණුම',
      'status_pending': 'පොරොත්තුවෙන්',
      'status_in_progress': 'ක්‍රියාත්මක වෙමින්',
      'status_resolved': 'විසඳා ඇත',
      'no_reports_yet': 'තවම වාර්තා නැත',
      'no_reports_message': 'ආරම්භ කිරීමට ඔබේ පළමු වාර්තාව ඉදිරිපත් කරන්න',
      'error_loading_reports': 'වාර්තා පූරණය කිරීමේ දෝෂයකි',
      'just_now': 'මේ දැන්',
      'minutes_ago': 'මි. පෙර',
      'hours_ago': 'පැයකට පෙර',
      'days_ago': 'දිනකට පෙර',
      'language': 'භාෂාව',
      'english': 'English',
      'sinhala': 'සිංහල',
      'change_language': 'භාෂාව වෙනස් කරන්න',
      'select_language': 'භාෂාව තෝරන්න',
      'close': 'වසන්න',
    },
  };
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        if (savedLanguage == 'si_LK') {
          currentLocale.value = const Locale('si', 'LK');
        } else {
          currentLocale.value = const Locale('en', 'US');
        }
      }
    } catch (e) {
      print('Error loading language: $e');
    }
  }
  
  Future<void> changeLanguage(Locale locale) async {
    try {
      currentLocale.value = locale;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, '${locale.languageCode}_${locale.countryCode}');
      
      Get.snackbar(
        translate('language'),
        locale.languageCode == 'en' 
            ? 'Language changed to English'
            : 'භාෂාව සිංහල බවට වෙනස් කර ඇත',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      print('Error changing language: $e');
    }
  }
  
  String translate(String key) {
    final localeKey = '${currentLocale.value.languageCode}_${currentLocale.value.countryCode}';
    return translations[localeKey]?[key] ?? key;
  }
  
  bool get isEnglish => currentLocale.value.languageCode == 'en';
  bool get isSinhala => currentLocale.value.languageCode == 'si';
  
  String get currentLanguageName => isEnglish ? 'English' : 'සිංහල';
}

// ==================== USER HOME SCREEN ====================
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  final AuthController authController = Get.find();
  final ReportController reportController = Get.find();
  final NotificationController notificationController = Get.find();
  late final LanguageController languageController;

  @override
  void initState() {
    super.initState();
    // Initialize language controller
    if (Get.isRegistered<LanguageController>()) {
      languageController = Get.find<LanguageController>();
    } else {
      languageController = Get.put(LanguageController());
    }
  }

  String _tr(String key) {
    return languageController.translate(key);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final userId = authController.user?.uid ?? '';

    return Obx(() {
      // This will rebuild when language changes
      final _ = languageController.currentLocale.value;
      
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            _tr('app_name'),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          elevation: 0,
          actions: [
            // Language Toggle Button
            IconButton(
              onPressed: () => _showLanguageDialog(context),
              icon: Icon(
                Icons.language,
                color: colorScheme.primary,
              ),
              tooltip: _tr('change_language'),
            ),
            // Notification icon with badge
            _buildNotificationIconWithBadge(userId, colorScheme.primary),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
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
                      _tr('welcome'),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tr('welcome_message'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Section
              FutureBuilder<Map<String, int>>(
                future: reportController.getUserReportStatistics(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildStatisticsLoading(context);
                  }

                  if (snapshot.hasError) {
                    return _buildStatisticsError(context);
                  }

                  final stats = snapshot.data ?? {
                    'total': 0,
                    'pending': 0,
                    'resolved': 0,
                  };

                  return _buildStatistics(stats, context);
                },
              ),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(context),

              const SizedBox(height: 24),

              // Recent Activity Section
              _buildRecentActivitySection(context, userId),
              
              // Add bottom padding to prevent overlap with bottom nav
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: _buildModernBottomNavBar(),
      );
    });
  }

  // Language Selection Dialog
  void _showLanguageDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr('select_language'),
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
              languageController.isEnglish,
              colorScheme,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context,
              'සිංහල',
              const Locale('si', 'LK'),
              Icons.language,
              languageController.isSinhala,
              colorScheme,
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _tr('close'),
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
        languageController.changeLanguage(locale);
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

  Widget _buildNotificationIconWithBadge(String userId, Color iconColor) {
    if (userId.isEmpty) {
      return IconButton(
        onPressed: () {
          Get.to(() => const NotificationsScreen());
        },
        icon: Icon(Icons.notifications, color: iconColor),
        tooltip: _tr('notifications'),
      );
    }

    return StreamBuilder<int>(
      stream: notificationController.getUnreadCount(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Stack(
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => const NotificationsScreen());
              },
              icon: Icon(Icons.notifications, color: iconColor),
              tooltip: _tr('notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsLoading(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, _tr('total'), '...', Icons.assignment, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, _tr('pending'), '...', Icons.pending_actions, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, _tr('resolved'), '...', Icons.verified, Colors.green)),
      ],
    );
  }

  Widget _buildStatisticsError(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, _tr('total'), '0', Icons.assignment, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, _tr('pending'), '0', Icons.pending_actions, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, _tr('resolved'), '0', Icons.verified, Colors.green)),
      ],
    );
  }

  Widget _buildStatistics(Map<String, int> stats, BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, _tr('total'), stats['total'].toString(), Icons.assignment, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, _tr('pending'), stats['pending'].toString(), Icons.pending_actions, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, _tr('resolved'), stats['resolved'].toString(), Icons.verified, Colors.green)),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('quick_actions'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 16) / 2;
            
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    context,
                    _tr('report_issue'),
                    Icons.report_problem_rounded,
                    Colors.orange,
                    _tr('report_issue_desc'),
                    () => Get.to(() => const ReportIssueScreen()),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    context,
                    _tr('my_reports'),
                    Icons.history_rounded,
                    Colors.blue,
                    _tr('my_reports_desc'),
                    () => Get.to(() => const MyReportsScreen()),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    context,
                    _tr('issues_map'),
                    Icons.map_rounded,
                    Colors.green,
                    _tr('issues_map_desc'),
                    () => Get.to(() => const IssueMapScreen()),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildActionCard(
                    context,
                    _tr('emergency_contacts'),
                    Icons.contact_phone_rounded,
                    Colors.red,
                    _tr('emergency_contacts_desc'),
                    () => Get.to(() => const EmergencyContactsScreen()),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, String userId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _tr('recent_reports'),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const MyReportsScreen()),
              child: Text(
                _tr('view_all'),
                style: GoogleFonts.poppins(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ReportModel>>(
          stream: reportController.getUserReports(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _tr('error_loading_reports'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final reports = snapshot.data ?? [];
            final recentReports = reports.take(3).toList();

            if (recentReports.isEmpty) {
              return _buildEmptyReportsState();
            }

            return Column(
              children: recentReports.map((report) {
                return _buildReportItem(
                  report.title,
                  report.category,
                  report.status,
                  report.createdAt,
                  _getStatusColor(report.status),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyReportsState() {
    return SizedBox(
      height: 200,
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _tr('no_reports_message'),
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: _tr('home'),
                index: 0,
                isActive: _currentIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.assignment_rounded,
                label: _tr('reports'),
                index: 1,
                isActive: _currentIndex == 1,
              ),
              _buildCentralReportButton(),
              _buildNavItem(
                icon: Icons.map_rounded,
                label: _tr('map'),
                index: 3,
                isActive: _currentIndex == 3,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: _tr('profile'),
                index: 4,
                isActive: _currentIndex == 4,
              ),
            ],
          ),
        ),
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? colorScheme.primary : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCentralReportButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 8,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                _currentIndex = 2;
              });
              Get.to(() => const ReportIssueScreen());
            },
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
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
        Get.to(() => const MyReportsScreen());
        break;
      case 2:
        Get.to(() => const ReportIssueScreen());
        break;
      case 3:
        Get.to(() => const IssueMapScreen());
        break;
      case 4:
        Get.to(() => ProfileScreen());
        break;
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
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
          constraints: const BoxConstraints(
            minHeight: 140,
          ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  Widget _buildReportItem(
    String title,
    String category,
    String status,
    DateTime date,
    Color statusColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(date),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(status),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
        return _tr('status_pending');
      case 'in_progress':
        return _tr('status_in_progress');
      case 'resolved':
        return _tr('status_resolved');
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}${_tr('days_ago')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${_tr('hours_ago')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${_tr('minutes_ago')}';
    } else {
      return _tr('just_now');
    }
  }
}