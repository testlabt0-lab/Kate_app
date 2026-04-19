import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/shipment.dart';

class LostItemsScreen extends StatelessWidget {
  const LostItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل العدل المفقودة والضائعة')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          // Dummy data for now - will be fetched from DB
          List<ShipmentItem> lostItems = [];

          if (lostItems.isEmpty) {
            return const Center(child: Text('لا توجد عدل مفقودة مسجلة في النظام.'));
          }

          return ListView.builder(
            itemCount: lostItems.length,
            itemBuilder: (context, index) {
              final item = lostItems[index];
              return Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text('مفقودة: ${item.boxesCount} عدل - ${item.farmer?.name ?? "مجهول"}'),
                  subtitle: Text('الرحلة: ${item.shipmentId} | الوكيل: ${item.agent?.name ?? "مجهول"}'),
                  trailing: TextButton(
                    onPressed: () {
                      // Change status back to delivered or pending
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل الحالة')));
                    },
                    child: const Text('تعديل الحالة'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
