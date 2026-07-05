import 'package:flutter/material.dart';
import 'login_screen.dart'; // اضافه کردن فایل اسکرین

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سامانه کشاورزی',
      theme: ThemeData(
        primarySwatch: Colors.green,
        // پشتیبانی از راست‌چین شدن متون برای فارسی
        fontFamily: 'Tahoma', 
      ),
      // راست‌چین کردن کل اپلیکیشن
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const LoginScreen(),
    );
  }
}