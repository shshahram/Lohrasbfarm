import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerPanel extends StatefulWidget {
  final int buyerId;

  const BuyerPanel({super.key, required this.buyerId});

  @override
  State<BuyerPanel> createState() => _BuyerPanelState();
}

class _BuyerPanelState extends State<BuyerPanel> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts(); 
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    String province = _provinceController.text.trim();
    String city = _cityController.text.trim();
    
    final Uri apiUrl = Uri.parse(
        'https://nikravaan.ir/api/get_products.php?province=$province&city=$city');

    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          if (!mounted) return; 
          setState(() {
            _products = responseData['data'];
          });
        }
      }
    } catch (e) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در دریافت اطلاعات محصولات')),
      );
    } finally {
      if (mounted) { 
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOrderDialog(Map<String, dynamic> product) {
    final TextEditingController tonnageController = TextEditingController();
    String selectedOrderType = 'خرید قطعی';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) { // ctx = BuildContext مخصوص دیالوگ
        return StatefulBuilder(
          builder: (contextDialog, setStateDialog) {
            return AlertDialog(
              title: Text('سفارش ${product['product_name']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('تولیدکننده: ${product['farmer_name']}'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tonnageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'تناژ درخواستی (تن)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // جایگزینی DropdownButtonFormField با ساختار استاندارد بدون اخطار Deprecated
                  InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedOrderType,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'خرید قطعی', child: Text('خرید قطعی')),
                          DropdownMenuItem(value: 'پیش‌خرید', child: Text('پیش‌خرید (قراردادی)')),
                        ],
                        onChanged: (val) {
                          setStateDialog(() => selectedOrderType = val!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('انصراف'),
                ),
                isSubmitting
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (tonnageController.text.isEmpty) return;
                          
                          setStateDialog(() => isSubmitting = true);
                          
                          final Uri apiUrl = Uri.parse('https://nikravaan.ir/api/create_order.php');
                          try {
                            final response = await http.post(
                              apiUrl,
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "buyer_id": widget.buyerId,
                                "product_id": product['id'],
                                "requested_tonnage": double.tryParse(tonnageController.text) ?? 0,
                                "order_type": selectedOrderType,
                              }),
                            );

                            final responseData = jsonDecode(response.body);
                            
                            // بررسی باز بودن دیالوگ (با استفاده از ctx)
                            if (!ctx.mounted) return; 
                            Navigator.of(ctx).pop(); 
                            
                            // بررسی باز بودن صفحه اصلی (با استفاده از mounted کلاس اصلی)
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(responseData['message'])),
                            );
                          } catch (e) {
                            setStateDialog(() => isSubmitting = false);
                            
                            if (!mounted) return; 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('خطا در ارتباط با سرور')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('ثبت نهایی', style: TextStyle(color: Colors.white)),
                      ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازار محصولات کشاورزی'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'استان',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'شهر',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('هیچ محصولی با این مشخصات یافت نشد.', style: TextStyle(fontSize: 16)))
                    : ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product['product_name'] ?? 'نامشخص',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Chip(
                                        label: Text(product['product_type'] ?? ''),
                                        backgroundColor: Colors.green.shade100,
                                        side: BorderSide.none,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('تولیدکننده: ${product['farmer_name']}', style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text('موقعیت: ${product['province']} - ${product['city']}', style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text('تناژ تخمینی: ${product['estimated_tonnage']} تن', style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text('تاریخ برداشت: ${product['harvest_date']}', style: const TextStyle(fontSize: 15, color: Colors.blueGrey)),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showOrderDialog(product),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
                                      label: const Text('ثبت سفارش / پیش‌خرید', style: TextStyle(color: Colors.white, fontSize: 14)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}