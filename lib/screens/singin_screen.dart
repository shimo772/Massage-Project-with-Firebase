import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messageproject/screens/chat_screen.dart';
import 'package:messageproject/widgits/my_button.dart';

class SignInScreen extends StatefulWidget {
  static const String screenRoute = 'sign_screen';

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // ✅ استخدام TextEditingController للتحكم بالنصوص
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ متغيرات للتحكم في حالة التحميل وعرض الأخطاء
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _auth = FirebaseAuth.instance;

  // ✅ تنظيف controllers عند إغلاق الشاشة
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ دالة تسجيل الدخول مع معالجة الأخطاء
  Future<void> _signInUser() async {
    // ✅ التحقق من صحة الإدخال
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    // ✅ التحقق من صحة البريد الإلكتروني
    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('Please enter a valid email address', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // ✅ عرض رسالة نجاح
        _showSnackBar('Welcome back! 🎉', Colors.green);

        // ✅ الانتقال إلى شاشة الدردشة بعد تأخير بسيط
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, ChatScreen.screenRoute);
        }
      }
    } on FirebaseAuthException catch (e) {
      // ✅ معالجة أخطاء Firebase بشكل مخصص
      String errorMessage = _getFirebaseErrorMessage(e.code);
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      // ✅ معالجة الأخطاء العامة
      _showSnackBar('An error occurred. Please try again.', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ دالة للتحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // ✅ دالة لترجمة أخطاء Firebase
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Login failed: $errorCode';
    }
  }

  // ✅ دالة لعرض SnackBar موحدة
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // ✅ دالة لبناء حقل النص لتجنب التكرار
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      obscureText: isPassword ? _obscurePassword : false,
      onChanged: (value) {
        // ✅ تحديث حالة البطاقة عند تغيير النص
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: isPassword
            ? const Icon(Icons.lock_outline, color: Colors.grey)
            : const Icon(Icons.email_outlined, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ✅ Logo مع تأثير حركي
                Container(
                  height: 180,
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset('images/logo.png', fit: BoxFit.contain),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ عنوان الشاشة
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // ✅ نص ترحيبي
                const Text(
                  'Sign in to continue chatting',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // ✅ حقل البريد الإلكتروني
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Enter Your Email',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 10),

                // ✅ حقل كلمة المرور
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Enter Your Password',
                  keyboardType: TextInputType.text,
                  isPassword: true,
                ),

                const SizedBox(height: 10),

                // ✅ زر "نسيت كلمة المرور"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog();
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ زر تسجيل الدخول مع حالة التحميل
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                    : MyButton(
                        color: Colors.yellow[900]!,
                        title: 'SIGN IN',
                        onPressed: _signInUser,
                      ),

                const SizedBox(height: 20),

                // ✅ رابط للانتقال إلى شاشة التسجيل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        // ✅ الانتقال إلى شاشة التسجيل
                        Navigator.pushReplacementNamed(context, 'reg_screen');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ دالة عرض حوار "نسيت كلمة المرور"
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'Enter your email address to receive a password reset link.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String email = _emailController.text.trim();
              if (email.isNotEmpty && _isValidEmail(email)) {
                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  _showSnackBar('Password reset email sent! 📧', Colors.green);
                  Navigator.pop(context);
                } catch (e) {
                  _showSnackBar(
                    'Failed to send reset email. Try again.',
                    Colors.red,
                  );
                }
              } else {
                _showSnackBar(
                  'Please enter a valid email address.',
                  Colors.red,
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
