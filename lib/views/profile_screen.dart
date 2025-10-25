import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uee_project/views/user_home_screen.dart'; // Import for LanguageController

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = Get.find();
  final ReportController _reportController = Get.find();
  late final LanguageController _languageController;

  // Translation keys for Profile Screen
  final Map<String, Map<String, String>> _translations = {
    'en_US': {
      'my_profile': 'My Profile',
      'administrator': 'Administrator',
      'user_name': 'User Name',
      'no_email': 'No email',
      'report_statistics': 'Report Statistics',
      'total': 'Total',
      'pending': 'Pending',
      'progress': 'Progress',
      'resolved': 'Resolved',
      'settings': 'Settings',
      'logout': 'Logout',
      'logout_confirmation': 'Logout',
      'logout_message': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'change_language': 'Change Language',
    },
    'si_LK': {
      'my_profile': 'මගේ ගිණුම',
      'administrator': 'පරිපාලක',
      'user_name': 'පරිශීලක නාමය',
      'no_email': 'විද්‍යුත් ලිපිනයක් නැත',
      'report_statistics': 'වාර්තා සංඛ්‍යාලේඛන',
      'total': 'මුළු',
      'pending': 'පොරොත්තුවෙන්',
      'progress': 'ක්‍රියාත්මක',
      'resolved': 'විසඳා ඇත',
      'settings': 'සැකසීම්',
      'logout': 'ඉවත් වන්න',
      'logout_confirmation': 'ඉවත් වන්න',
      'logout_message': 'ඔබට ඉවත් වීමට අවශ්‍ය බව විශ්වාසද?',
      'cancel': 'අවලංගු කරන්න',
      'change_language': 'භාෂාව වෙනස් කරන්න',
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
  }

  String _tr(String key) {
    final localeKey = '${_languageController.currentLocale.value.languageCode}_${_languageController.currentLocale.value.countryCode}';
    return _translations[localeKey]?[key] ?? key;
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
    final user = _authController.user;
    final isAdmin = _authController.userRole == 'admin';

    return Obx(() {
      // This will rebuild when language changes
      final _ = _languageController.currentLocale.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text(_tr('my_profile'), style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          )),
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
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Profile Section
              _buildProfileSection(context, user, isAdmin),
              
              const SizedBox(height: 24),
              
              // Role-based content
              if (!isAdmin)
                _buildUserStatisticsSection(context),
              
              const SizedBox(height: 24),
              
              // Settings Section
              _buildSettingsSection(context),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileSection(BuildContext context, User? user, bool isAdmin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Icon(
              isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
              size: 50,
              color: colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // User Name
          Text(
            user?.displayName ?? (isAdmin ? _tr('administrator') : _tr('user_name')),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // User Email
          Text(
            user?.email ?? _tr('no_email'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.red.withOpacity(0.1) : colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAdmin ? _tr('administrator').toUpperCase() : _authController.userRole.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isAdmin ? Colors.red : colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatisticsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<dynamic>>(
      stream: _reportController.getUserReports(_authController.user?.uid ?? ''),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final totalReports = reports.length;
        final pendingReports = reports.where((report) => report.status == 'pending').length;
        final inProgressReports = reports.where((report) => report.status == 'in_progress').length;
        final resolvedReports = reports.where((report) => report.status == 'resolved').length;

        return Container(
          padding: const EdgeInsets.all(20),
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
                _tr('report_statistics'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildStatItem(
                    context,
                    _tr('total'),
                    totalReports.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    context,
                    _tr('pending'),
                    pendingReports.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    context,
                    _tr('progress'),
                    inProgressReports.toString(),
                    Icons.build,
                    Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    context,
                    _tr('resolved'),
                    resolvedReports.toString(),
                    Icons.verified,
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
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
            _tr('settings'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await _showLogoutConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _tr('logout'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _tr('logout_confirmation'),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            _tr('logout_message'),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _tr('cancel'),
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authController.logout();
              },
              child: Text(
                _tr('logout'),
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}