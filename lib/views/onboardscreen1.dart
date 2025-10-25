// view/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uee_project/controllers/auth_controller.dart';
import 'signin_screen.dart'; // Import your SigninScreen

class Onboardscreen1 extends StatefulWidget {
  const Onboardscreen1({super.key});

  @override
  State<Onboardscreen1> createState() => _Onboardscreen1State();
}

class _Onboardscreen1State extends State<Onboardscreen1>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Secure Infrastructure",
      subtitle: "Monitor & Protect",
      description:
          "Advanced security monitoring for your critical infrastructure with real-time threat detection and automated response systems.",
      icon: Icons.security_outlined,
      color: const Color(0xFFff5722),
    ),
    OnboardingData(
      title: "Real-time Monitoring",
      subtitle: "24/7 Surveillance",
      description:
          "Continuous monitoring of your systems with intelligent alerts and comprehensive analytics to keep you informed.",
      icon: Icons.monitor_heart_outlined,
      color: const Color(0xFF2196F3),
    ),
    OnboardingData(
      title: "Smart Analytics",
      subtitle: "Data Insights",
      description:
          "Powerful analytics and reporting tools to help you make informed decisions and optimize your infrastructure performance.",
      icon: Icons.analytics_outlined,
      color: const Color(0xFF4CAF50),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _nextPage() {
    if (_currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to SigninScreen
      _navigateToSignIn();
    }
  }

  void _skipOnboarding() {
    // Navigate directly to the 3rd screen
    _pageController.animateToPage(
      _onboardingData.length - 1, // Last page index
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToSignIn() {
    final AuthController authController = Get.find<AuthController>();
    authController.setFirstTimeDone(); // Mark onboarding as completed
    Get.off(() => const SigninScreen());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button - Only show on first two screens
            if (_currentIndex < 2)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            else
              // Empty space to maintain layout consistency
              const SizedBox(height: 60),

            // PageView Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                      _onboardingData[index],
                      size,
                      theme,
                    );
                  },
                ),
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildPageIndicator(index, theme),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Previous Button
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: _onboardingData[_currentIndex].color,
                              ),
                            ),
                            child: Text(
                              "Previous",
                              style: TextStyle(
                                color: _onboardingData[_currentIndex].color,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      
                      if (_currentIndex > 0) const SizedBox(width: 16),
                      
                      // Next/Get Started Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _onboardingData[_currentIndex].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentIndex == _onboardingData.length - 1
                                ? "Get Started"
                                : "Next",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    OnboardingData data,
    Size size,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Animated Icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: data.color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    size: 60,
                    color: data.color,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 48),
          
          // Title and Subtitle
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 30),
                  child: Column(
                    children: [
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.headlineLarge?.color,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        data.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: data.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Description
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withAlpha(200),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, ThemeData theme) {
    final isActive = index == _currentIndex;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive 
            ? _onboardingData[_currentIndex].color 
            : theme.dividerColor.withAlpha(100),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}