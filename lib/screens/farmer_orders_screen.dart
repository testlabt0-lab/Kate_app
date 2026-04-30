import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../providers/app_provider.dart';
import '../models/farmer.dart';
import '../models/farmer_order.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});
  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  List<FarmerOrder> orders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات والمقاضي (ديون السوق)')),
      body: orders.isEmpty
          ? const Center(child: Text('لا توجد مقاضي مسجلة.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                    title: Text(order.description),
                    subtitle: Text('المزارع: ${order.farmerId}\nالسعر: ${order.actualPrice ?? order.estimatedPrice} ريال'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGroceryCashierDialog(context),
        label: const Text('فاتورة مقاضي جديدة'),
        icon: const Icon(Icons.receipt_long),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showGroceryCashierDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    Farmer? selectedFarmer;
    final farmerController = TextEditingController();

    List<Map<String, dynamic>> items = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double total = items.fold(0, (sum, item) => sum + (item['price'] as double));

          return AlertDialog(
            title: const Text('فاتورة مقاضي (إدخال سريع)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TypeAheadField<Farmer>(
                    controller: farmerController,
                    builder: (context, controller, focusNode) => TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'اسم المزارع', suffixIcon: Icon(Icons.search))),
                    itemBuilder: (context, farmer) => ListTile(title: Text(farmer.name)),
                    onSelected: (farmer) { farmerController.text = farmer.name; setDialogState(() => selectedFarmer = farmer); },
                    suggestionsCallback: (pattern) => provider.farmers.where((f) => f.name.toLowerCase().contains(pattern.toLowerCase())).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  ...items.map((item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['desc']),
                    trailing: Text('${item['price']} ريال'),
                    leading: IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setDialogState(() => items.remove(item))),
                  )).toList(),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة غرض للفاتورة'),
                    onPressed: () {
                      final dCtrl = TextEditingController();
                      final pCtrl = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('إضافة غرض'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(controller: dCtrl, decoration: const InputDecoration(labelText: 'الغرض (مثال: مبيد، شوالات)')),
                              TextField(controller: pCtrl, decoration: const InputDecoration(labelText: 'السعر (ريال)'), keyboardType: TextInputType.number),
                            ],
                          ),
                          actions: [
                            ElevatedButton(onPressed: () {
                              if (dCtrl.text.isNotEmpty && pCtrl.text.isNotEmpty) {
                                setDialogState(() => items.add({'desc': dCtrl.text, 'price': double.parse(pCtrl.text)}));
                                Navigator.pop(ctx);
                              }
                            }, child: const Text('إضافة'))
                          ],
                        )
                      );
                    },
                  ),
                  const Divider(),
                  Text('الإجمالي: $total ريال', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (selectedFarmer != null && items.isNotEmpty) {
                    setState(() {
                      for (var item in items) {
                        orders.add(FarmerOrder(id: DateTime.now().toString(), farmerId: selectedFarmer!.name, description: item['desc'], actualPrice: item['price'], status: 'completed'));
                      }
                    });
                    // Save total debt to Supabase logic here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الفاتورة بنجاح كدين على المزارع')));
                  }
                },
                child: const Text('اعتماد وتقييد الدين'),
              ),
            ],
          );
        }
      ),
    );
  }
}
