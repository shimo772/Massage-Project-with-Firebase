import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messageproject/screens/chat_screen.dart';
import 'package:messageproject/screens/registeration_screaan.dart';
import 'package:messageproject/screens/singin_screen.dart';
import 'package:messageproject/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MessageMe',

      // ✅ Theme مبسط
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),

      // ✅ Routes مبسطة
      routes: {
        ChatScreen.screenRoute: (context) => const ChatScreen(),
        RegistrationScreen.screenRoute: (context) => const RegistrationScreen(),
        SignInScreen.screenRoute: (context) => const SignInScreen(),
        WelcomeScreen.screenRoute: (context) => const WelcomeScreen(),
      },

      // ✅ تحديد الشاشة الأولى
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasError) {
            return const ErrorScreen();
          }

          final user = snapshot.data;
          return user != null ? const ChatScreen() : const WelcomeScreen();
        },
      ),
    );
  }
}

// ✅ شاشة التحميل المبسطة
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 20),
            Image.asset('images/logo.png', height: 80),
            const SizedBox(height: 10),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

// ✅ شاشة الخطأ المبسطة
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // ✅ إعادة تحميل التطبيق
                Navigator.pushReplacementNamed(
                  context,
                  WelcomeScreen.screenRoute,
                );
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
