import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedRole = 'farmer'; // نقش پیش‌فرض
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    // آدرس فایل ثبت نام روی هاست شما
    final Uri apiUrl = Uri.parse('https://nikravaan.ir/api/register.php');

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text.trim(),
          "full_name": _fullNameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "role": _selectedRole,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      _showMessageDialog(
        responseData['status'] == 'success' ? 'موفقیت' : 'خطا',
        responseData['message'],
        isSuccess: responseData['status'] == 'success',
      );
    } catch (error) {
      _showMessageDialog('خطای دقیق', error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessageDialog(
    String title,
    String message, {
    bool isSuccess = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // در صورت موفقیت به صفحه لاگین برمی‌گردیم
              if (isSuccess) Navigator.of(context).pop();
            },
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت‌نام در سامانه')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'شماره تماس',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'نام کاربری',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'رمز عبور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'نوع حساب کاربری',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'farmer',
                  child: Text('تولیدکننده (کشاورز/باغدار)'),
                ),
                DropdownMenuItem(value: 'buyer', child: Text('خریدار')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'ثبت‌نام',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
