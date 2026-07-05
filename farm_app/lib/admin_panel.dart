import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<dynamic> _pendingFarmers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingFarmers();
  }

  // دریافت لیست کشاورزان در انتظار تایید
  Future<void> _fetchPendingFarmers() async {
    final Uri apiUrl = Uri.parse('https://nikravaan.ir/api/get_pending_farmers.php');
    
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _pendingFarmers = responseData['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('خطا در دریافت اطلاعات از سرور');
    }
  }

  // ارسال درخواست تایید کشاورز
  Future<void> _approveFarmer(int userId) async {
    final Uri apiUrl = Uri.parse('https://nikravaan.ir/api/approve_farmer.php');
    
    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (responseData['status'] == 'success') {
        _showSnackBar('تولیدکننده تایید شد.');
        _fetchPendingFarmers(); // بروزرسانی مجدد لیست
      } else {
        _showSnackBar(responseData['message']);
      }
    } catch (e) {
      _showSnackBar('خطا در برقراری ارتباط');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل مدیریت (ناظر)'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingFarmers.isEmpty
              ? const Center(child: Text('هیچ تولیدکننده‌ای در انتظار تایید نیست.', style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  itemCount: _pendingFarmers.length,
                  itemBuilder: (context, index) {
                    final farmer = _pendingFarmers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person_outline, color: Colors.blueGrey),
                        title: Text(farmer['full_name']),
                        subtitle: Text('شماره تماس: ${farmer['phone']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _approveFarmer(farmer['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('تایید حساب'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}