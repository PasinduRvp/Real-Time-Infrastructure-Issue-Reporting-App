import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'package:uee_project/controllers/theme_controller.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:uee_project/utils/app_themes.dart';
import 'package:uee_project/views/splash_screen.dart';
import 'package:uee_project/controllers/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  debugPrint('Firebase initialized successfully');
  
  // Initialize controllers using GetX's dependency injection
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(NotificationController()); 
  Get.put(ReportController(), permanent: true);
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    
    return GetMaterialApp(
      title: 'InfraGuard',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.cupertino,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
    );
  }
}