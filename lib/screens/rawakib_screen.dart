import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/farmer.dart';

class RawakibScreen extends StatefulWidget {
  const RawakibScreen({super.key});
  @override
  State<RawakibScreen> createState() => _RawakibScreenState();
}

class _RawakibScreenState extends State<RawakibScreen> {
  int totalRawakib = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة مخزون الرواكب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.inventory, size: 40),
                title: const Text('إجمالي الرواكب المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: Text('$totalRawakib', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(onPressed: _showAddInventoryDialog, icon: const Icon(Icons.add_shopping_cart), label: const Text('شراء رواكب')),
                ElevatedButton.icon(
                  onPressed: totalRawakib > 0 ? () => _showGiveToFarmerDialog(context) : null,
                  icon: const Icon(Icons.send), label: const Text('صرف لمزارع'),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInventoryDialog() {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة للمخزون'),
        content: TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'العدد'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              setState(() => totalRawakib += int.tryParse(quantityController.text) ?? 0);
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showGiveToFarmerDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    Farmer? selectedFarmer;
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('صرف رواكب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Farmer>(decoration: const InputDecoration(labelText: 'المزارع'), items: provider.farmers.map((f) => DropdownMenuItem(value: f, child: Text(f.name))).toList(), onChanged: (v) => selectedFarmer = v),
            TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'العدد'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(quantityController.text) ?? 0;
              if (selectedFarmer != null && qty > 0 && qty <= totalRawakib) {
                setState(() => totalRawakib -= qty);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الصرف')));
                Navigator.pop(context);
              }
            },
            child: const Text('صرف'),
          ),
        ],
      ),
    );
  }
}
