import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FarmerPanel extends StatefulWidget {
  final int farmerId;

  const FarmerPanel({super.key, required this.farmerId});

  @override
  State<FarmerPanel> createState() => _FarmerPanelState();
}

class _FarmerPanelState extends State<FarmerPanel> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('داشبورد تولیدکننده'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'ثبت محصول'),
              Tab(icon: Icon(Icons.list_alt), text: 'سفارشات ورودی'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AddProductTab(farmerId: widget.farmerId),
            OrdersTab(farmerId: widget.farmerId),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// تب ثبت محصول
// ---------------------------------------------------------
class AddProductTab extends StatefulWidget {
  final int farmerId;
  const AddProductTab({super.key, required this.farmerId});

  @override
  State<AddProductTab> createState() => _AddProductTabState();
}

class _AddProductTabState extends State<AddProductTab> {
  final _formKey = GlobalKey<FormState>();

  String _productType = 'زراعی';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _plantDateController = TextEditingController();
  final TextEditingController _harvestDateController = TextEditingController();
  final TextEditingController _fertilizerController = TextEditingController();
  final TextEditingController _tonnageController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController(
    text: 'خوزستان',
  );
  final TextEditingController _cityController = TextEditingController(
    text: 'اهواز',
  );

  bool _isLoading = false;

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final Uri apiUrl = Uri.parse('https://nikravaan.ir/api/add_product.php');
    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "farmer_id": widget.farmerId,
          "product_type": _productType,
          "product_name": _nameController.text.trim(),
          "cultivation_area": double.tryParse(_areaController.text) ?? 0.0,
          "planting_date": _plantDateController.text.trim(),
          "harvest_date": _harvestDateController.text.trim(),
          "fertilizer_type": _fertilizerController.text.trim(),
          "estimated_tonnage": double.tryParse(_tonnageController.text) ?? 0.0,
          "province": _provinceController.text.trim(),
          "city": _cityController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (!mounted) return; // حل اخطار build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseData['message'])));

      if (responseData['status'] == 'success') _formKey.currentState!.reset();
    } catch (e) {
      if (!mounted) return; // حل اخطار build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('خطا در ارتباط با سرور')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _productType, // <--- کلمه به initialValue تغییر کرد
            decoration: const InputDecoration(
              labelText: 'نوع محصول',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'زراعی', child: Text('زراعی')),
              DropdownMenuItem(value: 'باغی', child: Text('باغی')),
              DropdownMenuItem(value: 'گلخانه‌ای', child: Text('گلخانه‌ای')),
            ],
            onChanged: (val) => setState(() => _productType = val!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'نام محصول',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value!.isEmpty ? 'الزامی است' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'مساحت (هکتار)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _tonnageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'تناژ تخمینی (تن)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _plantDateController,
                  decoration: const InputDecoration(
                    labelText: 'تاریخ کاشت',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _harvestDateController,
                  decoration: const InputDecoration(
                    labelText: 'تاریخ برداشت',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _fertilizerController,
            decoration: const InputDecoration(
              labelText: 'نوع کود مصرفی',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _provinceController,
                  decoration: const InputDecoration(
                    labelText: 'استان',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'شهر',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _submitProduct,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'ثبت محصول',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// تب سفارشات ورودی
// ---------------------------------------------------------
class OrdersTab extends StatefulWidget {
  final int farmerId;
  const OrdersTab({super.key, required this.farmerId});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final Uri apiUrl = Uri.parse(
      'https://nikravaan.ir/api/get_farmer_orders.php?farmer_id=${widget.farmerId}',
    );

    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          if (!mounted) return;
          setState(() {
            _orders = responseData['data'];
          });
        }
      }
    } catch (e) {
      if (!mounted) return; // حل اخطار build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('خطا در دریافت سفارشات')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(int orderId, String status) async {
    final Uri apiUrl = Uri.parse(
      'https://nikravaan.ir/api/update_order_status.php',
    );

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId, "status": status}),
      );

      final responseData = jsonDecode(response.body);

      if (!mounted) return; // حل اخطار build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseData['message'])));

      if (responseData['status'] == 'success') {
        _fetchOrders();
      }
    } catch (e) {
      if (!mounted) return; // حل اخطار build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('خطا در ارتباط با سرور')));
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    String text;

    switch (status) {
      case 'accepted':
        bgColor = Colors.green;
        text = 'تایید شده';
        break;
      case 'rejected':
        bgColor = Colors.red;
        text = 'رد شده';
        break;
      default:
        bgColor = Colors.orange;
        text = 'در انتظار بررسی';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_orders.isEmpty) {
      return const Center(
        child: Text('تاکنون سفارشی برای محصولات شما ثبت نشده است.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'محصول: ${order['product_name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusBadge(order['status']),
                    ],
                  ),
                  const Divider(),
                  Text('خریدار: ${order['buyer_name']}'),
                  Text('شماره تماس: ${order['buyer_phone']}'),
                  Text(
                    'تناژ درخواستی: ${order['requested_tonnage']} تن (از ${order['estimated_tonnage']} تن کل)',
                  ),
                  Text('نوع قرارداد: ${order['order_type']}'),

                  if (order['status'] == 'pending') ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              _updateStatus(order['order_id'], 'rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('رد سفارش'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _updateStatus(order['order_id'], 'accepted'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'تایید و تماس',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
