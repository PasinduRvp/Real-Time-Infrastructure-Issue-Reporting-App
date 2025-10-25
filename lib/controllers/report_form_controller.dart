// lib/controllers/report_form_controller.dart
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uee_project/services/firebase_report_service.dart';
import 'package:uee_project/services/huggingface_detection_service.dart';
import 'dart:io';
import 'dart:developer' as developer;

class ReportFormController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Form controllers
  final RxString titleController = ''.obs;
  final RxString descriptionController = ''.obs;
  final RxString categoryController = ''.obs;
  final RxString priorityController = 'medium'.obs;
  final RxString locationController = ''.obs;
  
  // Image handling
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxBool isAnalyzingImage = false.obs;
  
  // Location handling
  final Rx<Position?> currentLocation = Rx<Position?>(null);
  final RxBool isGettingLocation = false.obs;
  final RxBool isLoading = false.obs;
  
  // AI Detection
  final RxBool hasAIDetection = false.obs;
  final RxString aiDetectedCategory = ''.obs;
  final RxString aiDetectedPriority = ''.obs;
  final RxDouble aiConfidence = 0.0.obs;
  final RxString aiDescription = ''.obs;
  
  // Services
  final FirebaseReportService _reportService = FirebaseReportService();
  final HuggingFaceDetectionService _aiService = HuggingFaceDetectionService();
  
  // Categories and priorities
  final List<String> categories = [
    'Road Damage',
    'Street Light',
    'Water Supply',
    'Sewage',
    'Garbage',
    'Electricity',
    'Public Transport',
    'Parks & Recreation',
    'Other'
  ];
  
  final List<String> priorities = ['urgent', 'high', 'medium', 'low'];

  final ImagePicker _imagePicker = ImagePicker();
  
  // Image picking methods
  Future<void> pickImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (images != null && images.isNotEmpty) {
        selectedImages.addAll(images);
        developer.log('✅ Added ${images.length} images', name: 'ReportFormController');
      }
    } catch (e) {
      developer.log('❌ Error picking images: $e', name: 'ReportFormController');
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }
  
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        selectedImages.add(image);
        developer.log('✅ Photo taken successfully', name: 'ReportFormController');
      }
    } catch (e) {
      developer.log('❌ Error taking photo: $e', name: 'ReportFormController');
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }
  
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      developer.log('🗑️ Removed image at index $index', name: 'ReportFormController');
    }
  }
  
  // Location methods
  Future<void> getCurrentLocation() async {
    isGettingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      currentLocation.value = position;
      developer.log('📍 Location acquired: ${position.latitude}, ${position.longitude}', 
          name: 'ReportFormController');
      
      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          locationController.value = 
            '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}'.replaceAll(RegExp(r'^,\s*|\s*,$'), '');
        } else {
          locationController.value = 
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        }
      } catch (e) {
        locationController.value = 
          'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      developer.log('❌ Location error: $e', name: 'ReportFormController');
      Get.snackbar('Location Error', e.toString());
    } finally {
      isGettingLocation.value = false;
    }
  }
  
  // 🆕 AI Analysis with Hugging Face
  Future<void> analyzeImagesWithAI() async {
    if (selectedImages.isEmpty) {
      Get.snackbar('Error', 'Please add at least one image first');
      return;
    }
    
    isAnalyzingImage.value = true;
    try {
      developer.log('🤖 Starting Hugging Face AI analysis...', name: 'ReportFormController');
      
      // Convert XFile to File
      List<File> imageFiles = selectedImages.map((xfile) => File(xfile.path)).toList();
      
      // Analyze images
      final result = await _aiService.analyzeMultipleImages(imageFiles);
      
      developer.log('✅ AI Analysis complete:', name: 'ReportFormController');
      developer.log('   Category: ${result.category}', name: 'ReportFormController');
      developer.log('   Priority: ${result.priority}', name: 'ReportFormController');
      developer.log('   Confidence: ${result.confidencePercentage}', name: 'ReportFormController');
      
      // Update form with AI results
      aiDetectedCategory.value = result.category;
      aiDetectedPriority.value = result.priority;
      aiConfidence.value = result.confidence;
      aiDescription.value = result.description;
      hasAIDetection.value = true;
      
      // Auto-fill form fields if empty
      if (categoryController.value.isEmpty) {
        categoryController.value = result.category;
        developer.log('📝 Auto-filled category: ${result.category}', name: 'ReportFormController');
      }
      
      if (priorityController.value == 'medium') {
        priorityController.value = result.priority;
        developer.log('📝 Auto-filled priority: ${result.priority}', name: 'ReportFormController');
      }
      
      Get.snackbar(
        'AI Analysis Complete',
        'Detected: ${result.category} (${result.confidencePercentage} confidence)',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      developer.log('❌ AI Analysis error: $e', name: 'ReportFormController');
      Get.snackbar(
        'AI Analysis Failed',
        'Could not analyze images. You can still submit manually.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isAnalyzingImage.value = false;
    }
  }
  
  // Submit report
  Future<bool> submitReport() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to submit a report');
      return false;
    }
    
    if (currentLocation.value == null) {
      Get.snackbar('Error', 'Please enable location services');
      return false;
    }
    
    if (titleController.value.isEmpty || 
        descriptionController.value.isEmpty || 
        categoryController.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return false;
    }
    
    isLoading.value = true;
    try {
      developer.log('📝 Submitting report...', name: 'ReportFormController');
      developer.log('   User: ${currentUser.uid}', name: 'ReportFormController');
      developer.log('   Title: ${titleController.value}', name: 'ReportFormController');
      developer.log('   Category: ${categoryController.value}', name: 'ReportFormController');
      developer.log('   AI Detected: ${hasAIDetection.value}', name: 'ReportFormController');
      
      // Prepare location data
      Map<String, dynamic> locationData = {
        'latitude': currentLocation.value!.latitude,
        'longitude': currentLocation.value!.longitude,
        'address': locationController.value,
      };
      
      // Submit report
      String reportId = await _reportService.createReport(
        title: titleController.value,
        description: descriptionController.value,
        category: categoryController.value,
        priority: priorityController.value,
        location: locationData,
        images: selectedImages,
        reportedBy: currentUser.uid,
        aiDetected: hasAIDetection.value,
        aiConfidence: aiConfidence.value,
      );
      
      developer.log('✅ Report submitted successfully: $reportId', name: 'ReportFormController');
      
      clearForm();
      return true;
    } catch (e) {
      developer.log('❌ Error submitting report: $e', name: 'ReportFormController');
      Get.snackbar('Error', 'Failed to submit report: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Clear form
  void clearForm() {
    titleController.value = '';
    descriptionController.value = '';
    categoryController.value = '';
    priorityController.value = 'medium';
    locationController.value = '';
    selectedImages.clear();
    currentLocation.value = null;
    hasAIDetection.value = false;
    aiDetectedCategory.value = '';
    aiDetectedPriority.value = '';
    aiConfidence.value = 0.0;
    aiDescription.value = '';
    developer.log('🧹 Form cleared', name: 'ReportFormController');
  }

  // Validate form
  bool validateForm() {
    if (titleController.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a title');
      return false;
    }
    if (descriptionController.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a description');
      return false;
    }
    if (categoryController.value.isEmpty) {
      Get.snackbar('Error', 'Please select a category');
      return false;
    }
    if (currentLocation.value == null) {
      Get.snackbar('Error', 'Please set a location');
      return false;
    }
    return true;
  }
}