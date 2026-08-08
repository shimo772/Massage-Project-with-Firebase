import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messageproject/widgits/my_button.dart';

class RegistrationScreen extends StatefulWidget {
  static const String screenRoute = 'reg_screen';

  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // ✅ استخدام TextEditingController للتحكم بالنصوص بشكل أفضل
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ متغيرات للتحكم في حالة التحميل وعرض الأخطاء
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ✅ استخدام late مع التأكد من التعريف بشكل صحيح
  final _auth = FirebaseAuth.instance;

  // ✅ تنظيف controllers عند إغلاق الشاشة
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ دالة التسجيل مع معالجة الأخطاء
  Future<void> _registerUser() async {
    // ✅ التحقق من صحة الإدخال
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ تحقق من نجاح التسجيل
      if (newUser.user != null) {
        // ✅ عرض رسالة نجاح
        _showSnackBar('Registration successful! 🎉', Colors.green);

        // ✅ الانتقال إلى شاشة الدردشة بعد تأخير بسيط
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, 'chatscreen');
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

  // ✅ دالة لترجمة أخطاء Firebase
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Registration failed: $errorCode';
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
        // ✅ إضافة أيقونات لحقول النص
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

                // ✅ Logo مع تأثير أنيميشن بسيط
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

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

                // ✅ زر التسجيل مع حالة التحميل
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                    : MyButton(
                        color: Colors.blue[900]!,
                        title: 'REGISTER',
                        onPressed: _registerUser,
                      ),

                const SizedBox(height: 20),

                // ✅ رابط للانتقال إلى شاشة تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        // ✅ الانتقال إلى شاشة تسجيل الدخول
                        Navigator.pushReplacementNamed(context, 'login_screen');
                      },
                      child: const Text(
                        'Login',
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
}
