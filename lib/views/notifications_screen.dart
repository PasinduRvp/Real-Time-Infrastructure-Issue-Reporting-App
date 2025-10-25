// lib/views/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uee_project/controllers/notification_controller.dart';
import 'package:uee_project/models/notification_model.dart';
import 'package:uee_project/utils/app_textstyles.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'package:uee_project/views/user_home_screen.dart';
import 'dart:developer' as developer;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notificationController = Get.find();
  final AuthController _authController = Get.find();
  late final LanguageController _languageController;

  final Map<String, Map<String, String>> _translations = {
    'en_US': {
      'notifications': 'Notifications',
      'mark_all_read': 'Mark all read',
      'not_logged_in': 'Not Logged In',
      'login_to_view': 'Please log in to view notifications',
      'loading_notifications': 'Loading notifications...',
      'no_notifications': 'No Notifications',
      'notifications_appear_here': 'You\'ll see notifications here when your reports are updated',
      'create_test_notification': 'Create Test Notification',
      'check_permissions': 'Check Permissions',
      'failed_to_load': 'Failed to load notifications',
      'retry': 'Retry',
      'permission_issue': 'Permission Issue Detected',
      'security_rules_update': 'This usually means Firestore security rules need to be updated.',
      'debug_info': 'Debug Info:',
      'user_id': 'User ID:',
      'email': 'Email:',
      'none': 'None',
      'success': 'Success',
      'test_notification_created': 'Test notification created!',
      'error': 'Error',
      'failed_create_notification': 'Failed to create test notification',
      'permissions_ok': 'Permissions OK',
      'can_read_notifications': 'You can read',
      'notifications_count': 'notifications',
      'permissions_issue': 'Permissions Issue',
      'cannot_read': 'Cannot read notifications:',
      'report_update': 'Report Update',
      'opening_details': 'Opening report details...',
      'delete_notification': 'Delete Notification',
      'mark_as_read': 'Mark as Read',
      'delete_confirmation': 'Delete Notification',
      'delete_message': 'Are you sure you want to delete this notification?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'notification_deleted': 'Notification deleted',
      'failed_delete': 'Failed to delete notification',
      'failed_mark_read': 'Failed to mark notification as read',
      'all_marked_read': 'All notifications marked as read',
      'failed_mark_all': 'Failed to mark all notifications as read',
      'just_now': 'Just now',
      'minutes_ago': 'm ago',
      'hours_ago': 'h ago',
      'yesterday': 'Yesterday',
      'days_ago': 'd ago',
      'change_language': 'Change Language',
      'network_error': 'Network connection issue. Please check your internet connection.',
      'optimization_message': 'Notifications are being optimized. Please wait a moment and try again.',
      'unexpected_error': 'An unexpected error occurred',
    },
    'si_LK': {
      'notifications': 'දැනුම්දීම්',
      'mark_all_read': 'සියල්ල කියවූ බව සලකුණු කරන්න',
      'not_logged_in': 'ඇතුළු වී නැත',
      'login_to_view': 'දැනුම්දීම් බැලීමට කරුණාකර පුරන්න',
      'loading_notifications': 'දැනුම්දීම් පූරණය වෙමින්...',
      'no_notifications': 'දැනුම්දීම් නැත',
      'notifications_appear_here': 'ඔබේ වාර්තා යාවත්කාලීන වන විට ඔබට මෙහි දැනුම්දීම් පෙනෙනු ඇත',
      'create_test_notification': 'පරීක්ෂණ දැනුම්දීමක් සාදන්න',
      'check_permissions': 'අවසර පරීක්ෂා කරන්න',
      'failed_to_load': 'දැනුම්දීම් පූරණය කිරීමට අසමත් විය',
      'retry': 'නැවත උත්සාහ කරන්න',
      'permission_issue': 'අවසර ගැටළුවක් අනාවරණය විය',
      'security_rules_update': 'මෙයින් අදහස් වන්නේ Firestore ආරක්ෂණ නීති යාවත්කාලීන කිරීමට අවශ්‍ය බවයි.',
      'debug_info': 'දෝෂ නිරාකරණ තොරතුරු:',
      'user_id': 'පරිශීලක හැඳුනුම්පත:',
      'email': 'විද්‍යුත් ලිපිනය:',
      'none': 'කිසිවක් නැත',
      'success': 'සාර්ථකයි',
      'test_notification_created': 'පරීක්ෂණ දැනුම්දීම සාදන ලදී!',
      'error': 'දෝෂයකි',
      'failed_create_notification': 'පරීක්ෂණ දැනුම්දීම සෑදීමට අසමත් විය',
      'permissions_ok': 'අවසර හරි',
      'can_read_notifications': 'ඔබට කියවිය හැක',
      'notifications_count': 'දැනුම්දීම්',
      'permissions_issue': 'අවසර ගැටළුවක්',
      'cannot_read': 'දැනුම්දීම් කියවීමට නොහැක:',
      'report_update': 'වාර්තා යාවත්කාලීන',
      'opening_details': 'වාර්තා විස්තර විවෘත කරමින්...',
      'delete_notification': 'දැනුම්දීම මකන්න',
      'mark_as_read': 'කියවූ බව සලකුණු කරන්න',
      'delete_confirmation': 'දැනුම්දීම මකන්න',
      'delete_message': 'ඔබට මෙම දැනුම්දීම මකා දැමීමට අවශ්‍ය බව විශ්වාසද?',
      'cancel': 'අවලංගු කරන්න',
      'delete': 'මකන්න',
      'notification_deleted': 'දැනුම්දීම මකා දමන ලදී',
      'failed_delete': 'දැනුම්දීම මකා දැමීමට අසමත් විය',
      'failed_mark_read': 'දැනුම්දීම කියවූ බව සලකුණු කිරීමට අසමත් විය',
      'all_marked_read': 'සියලුම දැනුම්දීම් කියවූ බව සලකුණු කර ඇත',
      'failed_mark_all': 'සියලුම දැනුම්දීම් සලකුණු කිරීමට අසමත් විය',
      'just_now': 'මේ දැන්',
      'minutes_ago': 'මි. පෙර',
      'hours_ago': 'පැයකට පෙර',
      'yesterday': 'ඊයේ',
      'days_ago': 'දිනකට පෙර',
      'change_language': 'භාෂාව වෙනස් කරන්න',
      'network_error': 'ජාල සම්බන්ධතා ගැටළුවක්. කරුණාකර ඔබේ අන්තර්ජාල සම්බන්ධතාවය පරීක්ෂා කරන්න.',
      'optimization_message': 'දැනුම්දීම් ප්‍රශස්තකරණය වෙමින් පවතී. කරුණාකර මොහොතක් රැඳී නැවත උත්සාහ කරන්න.',
      'unexpected_error': 'අනපේක්ෂිත දෝෂයක් සිදු විය',
    },
  };

  String get _currentUserId {
    final user = _authController.user;
    final userId = user?.uid ?? '';
    developer.log('📱 Current User ID: $userId');
    return userId;
  }

  @override
  void initState() {
    super.initState();
    developer.log('🔔 NotificationsScreen initialized');
    
    if (Get.isRegistered<LanguageController>()) {
      _languageController = Get.find<LanguageController>();
    } else {
      _languageController = Get.put(LanguageController());
    }
    
    final user = _authController.user;
    developer.log('👤 Current User: ${user?.email}');
    developer.log('🆔 Current User ID: $_currentUserId');
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', const Locale('en', 'US'), 
                Icons.language, _languageController.isEnglish, colorScheme, isDark),
            const SizedBox(height: 12),
            _buildLanguageOption(context, 'සිංහල', const Locale('si', 'LK'), 
                Icons.language, _languageController.isSinhala, colorScheme, isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_languageController.translate('close'),
                style: GoogleFonts.poppins(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language, Locale locale,
      IconData icon, bool isSelected, ColorScheme colorScheme, bool isDark) {
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
            color: isSelected ? colorScheme.primary : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colorScheme.primary : Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(language,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colorScheme.primary : (isDark ? Colors.white : Colors.black87),
                  )),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
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
      final _ = _languageController.currentLocale.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text(_tr('notifications'), style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _showLanguageDialog(context),
              icon: Icon(Icons.language, color: colorScheme.primary),
              tooltip: _languageController.translate('change_language'),
            ),
            StreamBuilder<List<NotificationModel>>(
              stream: _notificationController.getUserNotifications(_currentUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  developer.log('❌ Error in AppBar stream: ${snapshot.error}');
                }
                
                final hasUnread = snapshot.hasData && 
                    snapshot.data!.any((notification) => !notification.isRead);
                
                if (hasUnread) {
                  return TextButton(
                    onPressed: _markAllAsRead,
                    child: Text(_tr('mark_all_read'),
                        style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.w500)),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        body: _currentUserId.isEmpty ? _buildNoUserState() : _buildNotificationsList(isDark),
      );
    });
  }

  Widget _buildNoUserState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_tr('not_logged_in'), style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(_tr('login_to_view'),
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(bool isDark) {
    developer.log('🔍 Building notifications list for user: $_currentUserId');
    
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationController.getUserNotifications(_currentUserId),
      builder: (context, snapshot) {
        developer.log('📊 Stream state: ${snapshot.connectionState}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_tr('loading_notifications')),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          developer.log('❌ Stream error: ${snapshot.error}');
          return _buildErrorState(snapshot.error.toString(), isDark);
        }

        final notifications = snapshot.data ?? [];
        developer.log('✅ Loaded ${notifications.length} notifications');

        if (notifications.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return RefreshIndicator(
          onRefresh: _refreshNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) => _buildNotificationCard(notifications[index], isDark),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: !notification.isRead 
          ? (isDark ? Colors.blue[900]!.withAlpha(77) : Colors.blue[50])
          : (isDark ? Colors.grey[800] : Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildNotificationIcon(notification.type),
        title: Text(notification.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[700]),
                maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(_formatDate(notification.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[500])),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle))
            : null,
        onTap: () => _handleNotificationTap(notification),
        onLongPress: () => _showNotificationOptions(notification),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'status_update':
        icon = Icons.update;
        color = Colors.orange;
        break;
      case 'assignment':
        icon = Icons.assignment;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    final user = _authController.user;
    
    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(_tr('failed_to_load'),
                      style: AppTextStyles.h3.copyWith(
                        color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 8),
                  Text(_getUserFriendlyError(error),
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshNotifications,
                    child: Text(_tr('retry')),
                  ),
                  if (error.contains('PERMISSION_DENIED'))
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_tr('permission_issue'),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold, color: Colors.orange)),
                          const SizedBox(height: 4),
                          Text(_tr('security_rules_update'), style: AppTextStyles.bodySmall),
                          const SizedBox(height: 8),
                          Text(_tr('debug_info'),
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                          Text('${_tr('user_id')} $_currentUserId', style: AppTextStyles.bodySmall),
                          Text('${_tr('email')} ${user?.email ?? _tr('none')}',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('PERMISSION_DENIED')) {
      return _tr('login_to_view');
    } else if (error.contains('UNAVAILABLE')) {
      return _tr('network_error');
    } else if (error.contains('index')) {
      return _tr('optimization_message');
    } else {
      return '${_tr('unexpected_error')}: $error';
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(_tr('no_notifications'),
                      style: AppTextStyles.h3.copyWith(
                        color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 8),
                  Text(_tr('notifications_appear_here'),
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  if (_currentUserId.isNotEmpty)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _createTestNotification,
                          icon: const Icon(Icons.add),
                          label: Text(_tr('create_test_notification')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _checkPermissions,
                          child: Text(_tr('check_permissions'),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    setState(() {});
  }

  void _createTestNotification() async {
    try {
      developer.log('🧪 Creating test notification for user: $_currentUserId');
      
      await _notificationController.createStatusUpdateNotification(
        reportId: 'test_report_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId,
        reportTitle: 'Test Report',
        oldStatus: 'pending',
        newStatus: 'in_progress',
        updatedBy: 'System Test',
      );
      
      Get.snackbar(_tr('success'), _tr('test_notification_created'),
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      developer.log('❌ Error creating test notification: $e');
      Get.snackbar(_tr('error'), '${_tr('failed_create_notification')}: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _checkPermissions() async {
    try {
      final testSnapshot = await _notificationController.getUserNotifications(_currentUserId).first;
      Get.snackbar(_tr('permissions_ok'),
          '${_tr('can_read_notifications')} ${testSnapshot.length} ${_tr('notifications_count')}',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(_tr('permissions_issue'), '${_tr('cannot_read')} $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _handleNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      try {
        await _notificationController.markAsRead(notification.id);
        setState(() {});
      } catch (e) {
        developer.log('❌ Error marking notification as read: $e');
      }
    }

    if (notification.reportId.isNotEmpty) {
      Get.snackbar(_tr('report_update'), _tr('opening_details'),
          backgroundColor: Colors.blue, colorText: Colors.white);
    }
  }

  void _showNotificationOptions(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(_tr('delete_notification')),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification);
              },
            ),
            if (!notification.isRead)
              ListTile(
                leading: const Icon(Icons.mark_email_read, color: Colors.blue),
                title: Text(_tr('mark_as_read')),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(notification);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _deleteNotification(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('delete_confirmation')),
        content: Text(_tr('delete_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _notificationController.deleteNotification(notification.id);
                Get.snackbar(_tr('success'), _tr('notification_deleted'),
                    backgroundColor: Colors.green, colorText: Colors.white);
                setState(() {});
              } catch (e) {
                Get.snackbar(_tr('error'), '${_tr('failed_delete')}: $e',
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: Text(_tr('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markAsRead(NotificationModel notification) async {
    try {
      await _notificationController.markAsRead(notification.id);
      setState(() {});
    } catch (e) {
      Get.snackbar(_tr('error'), '${_tr('failed_mark_read')}: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _markAllAsRead() async {
    try {
      await _notificationController.markAllAsRead(_currentUserId);
      Get.snackbar(_tr('success'), _tr('all_marked_read'),
          backgroundColor: Colors.green, colorText: Colors.white);
      setState(() {});
    } catch (e) {
      Get.snackbar(_tr('error'), '${_tr('failed_mark_all')}: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return _tr('just_now');
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}${_tr('minutes_ago')}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}${_tr('hours_ago')}';
    } else if (difference.inDays == 1) {
      return _tr('yesterday');
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${_tr('days_ago')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}