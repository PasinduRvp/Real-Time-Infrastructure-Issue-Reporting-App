import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uee_project/services/firebase_user_service.dart';
import 'package:uee_project/views/signin_screen.dart';
import 'package:uee_project/views/admin_home_screen.dart';
import 'package:uee_project/views/user_home_screen.dart';
import 'dart:developer' as developer;

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUserService _userService = FirebaseUserService();
  
  final _isLoggedIn = false.obs;
  final _userRole = ''.obs;
  bool _isFirstTime = true;
  bool _isLoggingOut = false;
  bool _isSigningUp = false;

  bool get isLoggedIn => _isLoggedIn.value;
  String get userRole => _userRole.value;
  bool get isFirstTime => _isFirstTime;
  User? get user => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    ever(_isLoggedIn, _handleAuthChanged);
    _auth.authStateChanges().listen((User? user) async {
      if (!_isLoggingOut && !_isSigningUp) {
        _isLoggedIn.value = user != null;
        if (user != null) {
          await _loadUserRole(user.uid);
          _navigateBasedOnRole();
        }
      }
    });
  }

  void _handleAuthChanged(bool loggedIn) {
    if (!loggedIn && !_isLoggingOut && !_isSigningUp) {
      Get.offAll(() => const SigninScreen());
    }
  }

  void _navigateBasedOnRole() {
    if (_isLoggedIn.value && !_isSigningUp && !_isLoggingOut) {
      if (_userRole.value == 'admin') {
        Get.offAll(() => const AdminHomeScreen());
      } else {
        Get.offAll(() => const UserHomeScreen());
      }
    }
  }

  void resetLogoutFlag() {
    _isLoggingOut = false;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _isLoggedIn.value = true;
        await _loadUserRole(userCredential.user!.uid);
        
        // Handle navigation based on role
        if (_userRole.value == 'admin') {
          Get.offAll(() => const AdminHomeScreen());
        } else {
          Get.offAll(() => const UserHomeScreen());
        }
      }
    } catch (e) {
      _isLoggedIn.value = false;
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signUp(String email, String password, String name, String role) async {
    try {
      _isSigningUp = true;
      
      // Step 1: Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Step 2: Create Firestore document
        await _userService.createUserDocument(
          userId: userCredential.user!.uid,
          email: email,
          name: name,
          role: role,
        );
        
        // Step 3: Set local role
        _userRole.value = role;
        _isLoggedIn.value = true;
        
        // Step 4: Navigate to appropriate screen
        if (role == 'admin') {
          Get.offAll(() => const AdminHomeScreen());
        } else {
          Get.offAll(() => const UserHomeScreen());
        }
      }
    } catch (e) {
      // If Firestore creation fails, delete the auth user
      if (_auth.currentUser != null) {
        try {
          await _auth.currentUser!.delete();
        } catch (deleteError) {
          developer.log('Error deleting auth user: $deleteError', name: 'AuthController');
        }
      }
      
      throw Exception('Failed to create account: $e');
    } finally {
      _isSigningUp = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoggingOut = true;
      await _auth.signOut();
      _isLoggedIn.value = false;
      _userRole.value = '';
      Get.offAll(() => const SigninScreen());
    } catch (e) {
      developer.log('Error during logout: $e', name: 'AuthController');
    } finally {
      _isLoggingOut = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        _isLoggingOut = false;
      });
    }
  }

  Future<void> _loadUserRole(String userId) async {
    try {
      final userData = await _userService.getUserData(userId);
      if (userData != null) {
        _userRole.value = userData['role'] ?? 'user';
      } else {
        _userRole.value = 'user'; // Default to user role if no data found
      }
    } catch (e) {
      developer.log('Error loading user role: $e', name: 'AuthController');
      _userRole.value = 'user'; // Default to user role on error
    }
  }

  void login(String email, String role) {
    _isLoggedIn.value = true;
    _userRole.value = role;
  }

  void setFirstTimeDone() {
    _isFirstTime = false;
  }
}