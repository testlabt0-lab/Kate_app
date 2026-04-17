import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(title: const Text('الطلبات والمقاضي')),
      body: orders.isEmpty
          ? const Center(child: Text('لا توجد طلبات.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  color: order.status == 'completed' ? Colors.green.shade50 : Colors.white,
                  child: ListTile(
                    leading: Checkbox(
                      value: order.status == 'completed',
                      onChanged: (val) {
                        if (val == true && order.status != 'completed') _showCompleteOrderDialog(context, index, order);
                        else setState(() => orders[index] = FarmerOrder(id: order.id, farmerId: order.farmerId, description: order.description, status: 'pending', estimatedPrice: order.estimatedPrice));
                      },
                    ),
                    title: Text(order.description, style: TextStyle(decoration: order.status == 'completed' ? TextDecoration.lineThrough : null)),
                    subtitle: Text(order.status == 'completed' ? "تم الشراء بـ ${order.actualPrice}" : "قيد التنفيذ"),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrderDialog(context),
        label: const Text('طلب جديد'), icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  void _showAddOrderDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    Farmer? selectedFarmer;
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طلب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Farmer>(decoration: const InputDecoration(labelText: 'المزارع'), items: provider.farmers.map((f) => DropdownMenuItem(value: f, child: Text(f.name))).toList(), onChanged: (v) => selectedFarmer = v),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'الوصف')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (selectedFarmer != null && descController.text.isNotEmpty) {
                setState(() => orders.add(FarmerOrder(id: DateTime.now().toString(), farmerId: selectedFarmer!.id ?? '1', description: descController.text, status: 'pending')));
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showCompleteOrderDialog(BuildContext context, int index, FarmerOrder order) {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إكمال الطلب'),
        content: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'السعر الفعلي'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              setState(() => orders[index] = FarmerOrder(id: order.id, farmerId: order.farmerId, description: order.description, status: 'completed', actualPrice: double.tryParse(priceController.text) ?? 0));
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
