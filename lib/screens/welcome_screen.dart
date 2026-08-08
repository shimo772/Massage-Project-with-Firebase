import 'package:flutter/material.dart';
import 'package:messageproject/screens/registeration_screaan.dart';
import 'package:messageproject/screens/singin_screen.dart';
import 'package:messageproject/widgits/my_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String screenRoute = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ تهيئة الـ Animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    // ✅ بدء الأنيميشن عند تحميل الشاشة
    _animationController.forward();
  }

  @override
  void dispose() {
    // ✅ تنظيف الـ Animation Controller
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Logo مع تأثيرات حركية
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ اسم التطبيق مع تأثير حركي
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'MessageMe',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff2e386b),
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ✅ إضافة وصف للتطبيق
                        const Text(
                          'Connect with friends instantly',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // ✅ الأزرار مع تأثيرات حركية
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // ✅ زر تسجيل الدخول
                        MyButton(
                          color: Colors.blue[900]!,
                          title: 'SIGN IN',
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              SignInScreen.screenRoute,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // ✅ زر التسجيل مع أيقونة
                        MyButton(
                          color: const Color.fromRGBO(33, 150, 243, 1),
                          title: 'CREATE ACCOUNT',
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              RegistrationScreen.screenRoute,
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // ✅ نسخة التطبيق (اختياري)
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
