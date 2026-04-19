import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'farmer_report_screen.dart';

class FarmersScreen extends StatelessWidget {
  const FarmersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المزارعين والتقارير')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.farmers.isEmpty) return const Center(child: Text('لا يوجد مزارعين. أضف مزارعاً جديداً.'));
          return ListView.builder(
            itemCount: provider.farmers.length,
            itemBuilder: (context, index) {
              final farmer = provider.farmers[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(farmer.name),
                subtitle: Text(farmer.phone ?? 'لا يوجد رقم'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${farmer.totalDebt} ريال', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.analytics, color: Colors.blue),
                  ],
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FarmerReportScreen(farmer: farmer))),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFarmerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddFarmerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مزارع جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المزارع')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<AppProvider>().addFarmer(nameController.text, phoneController.text);
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
