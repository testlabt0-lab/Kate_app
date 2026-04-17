import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TransportersScreen extends StatelessWidget {
  const TransportersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الناقلين')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.transporters.isEmpty) return const Center(child: Text('لا يوجد ناقلين.'));
          return ListView.builder(
            itemCount: provider.transporters.length,
            itemBuilder: (context, index) {
              final transporter = provider.transporters[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.local_shipping)),
                title: Text(transporter.name),
                subtitle: Text(transporter.phone ?? 'لا يوجد رقم'),
                trailing: Text('عمولة: ${transporter.commissionRate}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransporterDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransporterDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final commissionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ناقل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الناقل')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
            TextField(controller: commissionController, decoration: const InputDecoration(labelText: 'نسبة العمولة (اختياري)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                double commission = double.tryParse(commissionController.text) ?? 0.0;
                context.read<AppProvider>().addTransporter(nameController.text, phoneController.text, commission);
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
