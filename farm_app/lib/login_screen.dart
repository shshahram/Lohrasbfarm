import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// وارد کردن فایل‌های سایر صفحات پلتفرم
import 'register_screen.dart';
import 'admin_panel.dart';
import 'farmer_panel.dart';
import 'buyer_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSystemDialog('لطفاً نام کاربری و رمز عبور را وارد کنید.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Uri apiUrl = Uri.parse('https://nikravaan.ir/api/login.php');

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // لاگین موفق: دریافت نقش و شناسه کاربر از بک‌اند
        String role = responseData['role'];
        int userId = int.parse(responseData['user_id'].toString());
        
        _navigateToDashboard(role, userId);
      } else {
        // نمایش خطای نام کاربری، رمز عبور یا عدم تایید ناظر
        _showSystemDialog(responseData['message'] ?? 'خطا در ورود');
      }
    } catch (error) {
      _showSystemDialog('خطا در برقراری ارتباط با سرور. لطفا اتصال اینترنت خود را بررسی کنید.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // هدایت کاربر به پنل مخصوص خودش بر اساس نقش (Role)
  void _navigateToDashboard(String role, int userId) {
    if (role == 'admin') {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const AdminPanel())
      );
    } else if (role == 'farmer') {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => FarmerPanel(farmerId: userId))
      );
    } else if (role == 'buyer') {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => BuyerPanel(buyerId: userId))
      );
    }
  }

  void _showSystemDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('پیام سیستم'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('متوجه شدم'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ورود به سامانه'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.agriculture,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'نام کاربری',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'رمز عبور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )
                      ),
                      child: const Text('ورود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 16),
              // دکمه انتقال به صفحه ثبت‌نام
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const RegisterScreen())
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                ),
                child: const Text('حساب کاربری ندارید؟ ثبت‌نام کنید', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}