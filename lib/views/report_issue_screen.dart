// lib/views/report_issue_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uee_project/controllers/report_form_controller.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'package:uee_project/utils/app_textstyles.dart';
import 'package:uee_project/views/widgets/custom_textfield.dart';
import 'package:uee_project/views/user_home_screen.dart'; // Import for LanguageController
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final ReportFormController _reportController = Get.put(ReportFormController());
  final AuthController _authController = Get.find();
  late final LanguageController _languageController;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  // Translation keys for Report Issue Screen
  final Map<String, Map<String, String>> _translations = {
    'en_US': {
      'report_issue': 'Report Issue',
      'ai_detection_results': 'AI Detection Results',
      'category': 'Category',
      'priority': 'Priority',
      'confidence': 'Confidence',
      'photos': 'Photos',
      'add_photos': 'Add Photos',
      'add_photo': 'Add Photo',
      'gallery': 'Gallery',
      'camera': 'Camera',
      'detect_issue_ai': 'Detect Issue with AI',
      'analyzing_ai': 'Analyzing with AI...',
      'issue_title': 'Issue Title',
      'please_enter_title': 'Please enter issue title',
      'description': 'Description',
      'please_enter_description': 'Please enter issue description',
      'select_category': 'Select category',
      'please_select_category': 'Please select a category',
      'select_priority': 'Select priority',
      'location': 'Location',
      'no_location_selected': 'No location selected',
      'getting_location': 'Getting location...',
      'current': 'Current',
      'pick_map': 'Pick Map',
      'submit_report': 'Submit Report',
      'success': 'Success',
      'location_updated': 'Location updated successfully',
      'location_selected': 'Location selected successfully',
      'location_error': 'Location Error',
      'enable_location': 'Failed to get current location. Please enable location services.',
      'ai_analysis_complete': 'AI Analysis Complete',
      'issue_detected': 'Issue detected',
      'ai_analysis_failed': 'AI Analysis Failed',
      'report_submitted': 'Report submitted successfully!',
      'error': 'Error',
      'submit_failed': 'Failed to submit report. Please try again.',
      'failed_submit': 'Failed to submit report',
      'validation_error': 'Validation Error',
      'fill_required_fields': 'Please fill all required fields correctly',
      'select_location_method': 'Select Location Method',
      'use_current_location': 'Use Current Location',
      'get_gps_location': 'Get your device GPS location',
      'pick_from_map': 'Pick from Map',
      'select_manually': 'Select location manually on map',
      'cancel': 'Cancel',
      'urgent': 'URGENT',
      'high': 'HIGH',
      'medium': 'MEDIUM',
      'low': 'LOW',
      'required_field': ' *',
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
      'report_issue': 'ගැටළුවක් වාර්තා කරන්න',
      'ai_detection_results': 'AI හඳුනාගැනීමේ ප්‍රතිඵල',
      'category': 'වර්ගය',
      'priority': 'ප්‍රමුඛතාවය',
      'confidence': 'විශ්වාසය',
      'photos': 'ඡායාරූප',
      'add_photos': 'ඡායාරූප එකතු කරන්න',
      'add_photo': 'ඡායාරූපයක් එකතු කරන්න',
      'gallery': 'ගැලරිය',
      'camera': 'කැමරාව',
      'detect_issue_ai': 'AI සමඟ ගැටළුව හඳුනාගන්න',
      'analyzing_ai': 'AI සමඟ විශ්ලේෂණය කරමින්...',
      'issue_title': 'ගැටළු මාතෘකාව',
      'please_enter_title': 'කරුණාකර ගැටළු මාතෘකාව ඇතුළත් කරන්න',
      'description': 'විස්තරය',
      'please_enter_description': 'කරුණාකර ගැටළු විස්තරය ඇතුළත් කරන්න',
      'select_category': 'වර්ගය තෝරන්න',
      'please_select_category': 'කරුණාකර වර්ගයක් තෝරන්න',
      'select_priority': 'ප්‍රමුඛතාවය තෝරන්න',
      'location': 'ස්ථානය',
      'no_location_selected': 'ස්ථානයක් තෝරා නොමැත',
      'getting_location': 'ස්ථානය ලබා ගනිමින්...',
      'current': 'වත්මන්',
      'pick_map': 'සිතියමෙන්',
      'submit_report': 'වාර්තාව ඉදිරිපත් කරන්න',
      'success': 'සාර්ථකයි',
      'location_updated': 'ස්ථානය සාර්ථකව යාවත්කාලීන කරන ලදී',
      'location_selected': 'ස්ථානය සාර්ථකව තෝරන ලදී',
      'location_error': 'ස්ථාන දෝෂයකි',
      'enable_location': 'වත්මන් ස්ථානය ලබා ගැනීමට අසමත් විය. කරුණාකර ස්ථාන සේවා සක්‍රීය කරන්න.',
      'ai_analysis_complete': 'AI විශ්ලේෂණය සම්පූර්ණයි',
      'issue_detected': 'ගැටළුව හඳුනාගන්නා ලදී',
      'ai_analysis_failed': 'AI විශ්ලේෂණය අසාර්ථක විය',
      'report_submitted': 'වාර්තාව සාර්ථකව ඉදිරිපත් කරන ලදී!',
      'error': 'දෝෂයකි',
      'submit_failed': 'වාර්තාව ඉදිරිපත් කිරීමට අසමත් විය. කරුණාකර නැවත උත්සාහ කරන්න.',
      'failed_submit': 'වාර්තාව ඉදිරිපත් කිරීමට අසමත් විය',
      'validation_error': 'වලංගු කිරීමේ දෝෂයකි',
      'fill_required_fields': 'කරුණාකර සියලු අවශ්‍ය ක්ෂේත්‍ර නිවැරදිව පුරවන්න',
      'select_location_method': 'ස්ථාන ක්‍රමය තෝරන්න',
      'use_current_location': 'වත්මන් ස්ථානය භාවිතා කරන්න',
      'get_gps_location': 'ඔබේ උපාංග GPS ස්ථානය ලබා ගන්න',
      'pick_from_map': 'සිතියමෙන් තෝරන්න',
      'select_manually': 'සිතියමෙහි අතින් ස්ථානය තෝරන්න',
      'cancel': 'අවලංගු කරන්න',
      'urgent': 'හදිසි',
      'high': 'ඉහළ',
      'medium': 'මධ්‍යම',
      'low': 'අඩු',
      'required_field': ' *',
      // Categories in Sinhala
      'Roads': 'මාර්ග',
      'Road Damage': 'මාර්ග හානි',
      'Street Light':' වීදි ආලෝක',
      'Garbage':'කැලිකසළ , අපද්‍රව්‍ය',
      'Sewage':' අපද්‍රව්‍ය',
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
    
    // Listen to text field changes and update the controller
    _titleController.addListener(() {
      _reportController.titleController.value = _titleController.text;
    });
    
    _descriptionController.addListener(() {
      _reportController.descriptionController.value = _descriptionController.text;
    });
  }

  String _tr(String key) {
    final localeKey = '${_languageController.currentLocale.value.languageCode}_${_languageController.currentLocale.value.countryCode}';
    return _translations[localeKey]?[key] ?? key;
  }

  Future<void> _getCurrentLocation() async {
    try {
      await _reportController.getCurrentLocation();
      Get.snackbar(
        _tr('success'),
        _tr('location_updated'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        _tr('location_error'),
        _tr('enable_location'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _selectLocationOnMap() async {
    // Get initial location for map
    LatLng initialLocation = const LatLng(6.9271, 79.8612); // Default: Colombo
    
    if (_reportController.currentLocation.value != null) {
      initialLocation = LatLng(
        _reportController.currentLocation.value!.latitude,
        _reportController.currentLocation.value!.longitude,
      );
    }

    final selectedLocation = await Get.to<LatLng>(() => LocationPickerScreen(
      initialLocation: initialLocation,
    ));

    if (selectedLocation != null) {
      // Update the location in the controller
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedLocation.latitude,
          selectedLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = '${place.street}, ${place.locality}, ${place.country}';
          
          _reportController.currentLocation.value = Position(
            latitude: selectedLocation.latitude,
            longitude: selectedLocation.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
          _reportController.locationController.value = address;
          
          Get.snackbar(
            _tr('success'),
            _tr('location_selected'),
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        // If geocoding fails, still save the coordinates
        _reportController.currentLocation.value = Position(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _reportController.locationController.value = 
            'Lat: ${selectedLocation.latitude.toStringAsFixed(4)}, Lng: ${selectedLocation.longitude.toStringAsFixed(4)}';
        
        Get.snackbar(
          _tr('success'),
          _tr('location_selected'),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _showLocationOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('select_location_method'), style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.blue),
              title: Text(_tr('use_current_location'), style: AppTextStyles.bodyMedium),
              subtitle: Text(
                _tr('get_gps_location'),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              onTap: () {
                Get.back();
                _getCurrentLocation();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.green),
              title: Text(_tr('pick_from_map'), style: AppTextStyles.bodyMedium),
              subtitle: Text(
                _tr('select_manually'),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              onTap: () {
                Get.back();
                _selectLocationOnMap();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(_tr('cancel'), style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeWithAI() async {
    try {
      await _reportController.analyzeImagesWithAI();
      Get.snackbar(
        _tr('ai_analysis_complete'),
        '${_tr('issue_detected')}: ${_reportController.aiDetectedCategory.value}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        _tr('ai_analysis_failed'),
        e.toString(),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Ensure all data is synced
        _reportController.titleController.value = _titleController.text.trim();
        _reportController.descriptionController.value = _descriptionController.text.trim();
        
        print('🔄 Starting report submission...');
        print('📋 Form data:');
        print('  Title: ${_reportController.titleController.value}');
        print('  Description: ${_reportController.descriptionController.value}');
        print('  Category: ${_reportController.categoryController.value}');
        print('  Priority: ${_reportController.priorityController.value}');
        print('  Location: ${_reportController.locationController.value}');
        print('  Images: ${_reportController.selectedImages.length}');
        
        final success = await _reportController.submitReport();
        
        if (success) {
          print('✅ Report submission successful!');
          Get.back();
          Get.snackbar(
            _tr('success'),
            _tr('report_submitted'),
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          _reportController.clearForm();
          _titleController.clear();
          _descriptionController.clear();
        } else {
          print('❌ Report submission failed');
          Get.snackbar(
            _tr('error'),
            _tr('submit_failed'),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        print('❌ Error during submission: $e');
        Get.snackbar(
          _tr('error'),
          '${_tr('failed_submit')}: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        _tr('validation_error'),
        _tr('fill_required_fields'),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('add_photo'), style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(_tr('gallery'), style: AppTextStyles.bodyMedium),
              onTap: () {
                Get.back();
                _reportController.pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(_tr('camera'), style: AppTextStyles.bodyMedium),
              onTap: () {
                Get.back();
                _reportController.takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'urgent':
        return _tr('urgent');
      case 'high':
        return _tr('high');
      case 'medium':
        return _tr('medium');
      case 'low':
        return _tr('low');
      default:
        return priority.toUpperCase();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      // This will rebuild when language changes
      final _ = _languageController.currentLocale.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(_tr('report_issue'), style: AppTextStyles.h2),
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
        body: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Detection Status Card
                  if (_reportController.hasAIDetection.value)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade100,
                            Colors.blue.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.purple.shade700),
                              const SizedBox(width: 8),
                              Text(
                                _tr('ai_detection_results'),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAIResultRow(_tr('category'), _reportController.aiDetectedCategory.value),
                          _buildAIResultRow(_tr('priority'), _reportController.aiDetectedPriority.value.toUpperCase()),
                          _buildAIResultRow(_tr('confidence'), '${(_reportController.aiConfidence.value * 100).toStringAsFixed(1)}%'),
                          const SizedBox(height: 8),
                          Text(
                            _reportController.aiDescription.value,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.purple.shade900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Photos Section
                  Text(
                    '${_tr('photos')}${_tr('required_field')}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add Photo Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: colorScheme.primary.withOpacity(0.05),
                            ),
                            child: TextButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: Icon(Icons.add_photo_alternate, color: colorScheme.primary),
                              label: Text(
                                _tr('add_photos'),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Selected Images Grid
                          if (_reportController.selectedImages.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _reportController.selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(_reportController.selectedImages[index].path),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _reportController.removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          
                          // AI Analyze Button
                          if (_reportController.selectedImages.isNotEmpty && !_reportController.hasAIDetection.value)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _reportController.isAnalyzingImage.value 
                                      ? null 
                                      : _analyzeWithAI,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: _reportController.isAnalyzingImage.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.auto_awesome, color: Colors.white),
                                  label: Text(
                                    _reportController.isAnalyzingImage.value
                                        ? _tr('analyzing_ai')
                                        : _tr('detect_issue_ai'),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title Field
                  Text(
                    '${_tr('issue_title')}${_tr('required_field')}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextfield(
                    controller: _titleController,
                    label: _tr('issue_title'),
                    prefixIcon: Icons.title,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _tr('please_enter_title');
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description Field
                  Text(
                    '${_tr('description')}${_tr('required_field')}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextfield(
                    controller: _descriptionController,
                    label: _tr('description'),
                    prefixIcon: Icons.description,
                    keyboardType: TextInputType.multiline,
                    isPassword: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _tr('please_enter_description');
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Category Dropdown
                  Text(
                    '${_tr('category')}${_tr('required_field')}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _reportController.categoryController.value.isEmpty 
                        ? null 
                        : _reportController.categoryController.value,
                    items: _reportController.categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_tr(category)), // Translate category
                      );
                    }).toList(),
                    onChanged: (value) {
                      _reportController.categoryController.value = value!;
                    },
                    decoration: InputDecoration(
                      hintText: _tr('select_category'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _reportController.hasAIDetection.value
                          ? Icon(Icons.auto_awesome, color: Colors.purple.shade400, size: 20)
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _tr('please_select_category');
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Priority Dropdown
                  Text(
                    _tr('priority'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _reportController.priorityController.value,
                    items: _reportController.priorities.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(
                          _getPriorityText(priority),
                          style: TextStyle(
                            color: _getPriorityColor(priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _reportController.priorityController.value = value!;
                    },
                    decoration: InputDecoration(
                      hintText: _tr('select_priority'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _reportController.hasAIDetection.value
                          ? Icon(Icons.auto_awesome, color: Colors.purple.shade400, size: 20)
                          : null,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Location Section
                  Text(
                    '${_tr('location')}${_tr('required_field')}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location Display
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _reportController.isGettingLocation.value
                                    ? Row(
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _tr('getting_location'),
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _reportController.locationController.value.isEmpty
                                                ? _tr('no_location_selected')
                                                : _reportController.locationController.value,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_reportController.currentLocation.value != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                'Lat: ${_reportController.currentLocation.value!.latitude.toStringAsFixed(4)}, '
                                                'Lng: ${_reportController.currentLocation.value!.longitude.toStringAsFixed(4)}',
                                                style: AppTextStyles.bodySmall.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Location Option Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _reportController.isGettingLocation.value 
                                      ? null 
                                      : _getCurrentLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.my_location, size: 18),
                                  label: Text(
                                    _tr('current'),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _selectLocationOnMap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.map, size: 18),
                                  label: Text(
                                    _tr('pick_map'),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _reportController.isLoading.value ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _reportController.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              _tr('submit_report'),
                              style: AppTextStyles.buttonLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildAIResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade900,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
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
}

// Location Picker Screen
class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({
    super.key,
    required this.initialLocation,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  late final LanguageController _languageController;
  String _selectedAddress = 'Loading address...';
  bool _isLoadingAddress = false;

  // Translation keys for Location Picker
  final Map<String, Map<String, String>> _translations = {
    'en_US': {
      'select_location': 'Select Location',
      'loading_address': 'Loading address...',
      'tap_to_select': 'Tap on map to select location',
      'confirm_location': 'Confirm Location',
      'zoom_in': 'Zoom In',
      'zoom_out': 'Zoom Out',
      'my_location': 'My Location',
      'location_error': 'Location Error',
      'location_services_disabled': 'Location services are disabled',
      'location_permission_denied': 'Location permission denied',
      'failed_get_location': 'Failed to get current location',
    },
    'si_LK': {
      'select_location': 'ස්ථානය තෝරන්න',
      'loading_address': 'ලිපිනය පූරණය වෙමින්...',
      'tap_to_select': 'ස්ථානය තෝරා ගැනීමට සිතියමට ස්පර්ශ කරන්න',
      'confirm_location': 'ස්ථානය තහවුරු කරන්න',
      'zoom_in': 'විශාලනය කරන්න',
      'zoom_out': 'කුඩා කරන්න',
      'my_location': 'මගේ ස්ථානය',
      'location_error': 'ස්ථාන දෝෂයකි',
      'location_services_disabled': 'ස්ථාන සේවා අක්‍රීය කර ඇත',
      'location_permission_denied': 'ස්ථාන අවසරය ප්‍රතික්ෂේප කරන ලදී',
      'failed_get_location': 'වත්මන් ස්ථානය ලබා ගැනීමට අසමත් විය',
    },
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
    
    // Initialize language controller
    if (Get.isRegistered<LanguageController>()) {
      _languageController = Get.find<LanguageController>();
    } else {
      _languageController = Get.put(LanguageController());
    }
    
    _getAddressFromLatLng(_selectedLocation);
  }

  String _tr(String key) {
    final localeKey = '${_languageController.currentLocale.value.languageCode}_${_languageController.currentLocale.value.countryCode}';
    return _translations[localeKey]?[key] ?? key;
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _selectedAddress = '${place.street}, ${place.locality}, ${place.country}';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromLatLng(location);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // This will rebuild when language changes
      final _ = _languageController.currentLocale.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(_tr('select_location'), style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialLocation,
                initialZoom: 15.0,
                maxZoom: 18.0,
                minZoom: 5.0,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.uee_project',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Location Info Card
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _tr('tap_to_select'),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingAddress)
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _tr('loading_address'),
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedAddress,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                              'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Confirm Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back(result: _selectedLocation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _tr('confirm_location'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Map Controls
            Positioned(
              bottom: 90,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, currentZoom + 1);
                    },
                    child: const Icon(Icons.add),
                    tooltip: _tr('zoom_in'),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, currentZoom - 1);
                    },
                    child: const Icon(Icons.remove),
                    tooltip: _tr('zoom_out'),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'current_location',
                    onPressed: () async {
                      try {
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          Get.snackbar(
                            _tr('location_error'),
                            _tr('location_services_disabled'),
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied) {
                            Get.snackbar(
                              _tr('location_error'),
                              _tr('location_permission_denied'),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                        }

                        Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                          timeLimit: const Duration(seconds: 5),
                        );

                        final newLocation = LatLng(position.latitude, position.longitude);
                        _mapController.move(newLocation, 15.0);
                        setState(() {
                          _selectedLocation = newLocation;
                        });
                        _getAddressFromLatLng(newLocation);
                      } catch (e) {
                        Get.snackbar(
                          _tr('location_error'),
                          '${_tr('failed_get_location')}: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.my_location, color: Colors.white),
                    tooltip: _tr('my_location'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}