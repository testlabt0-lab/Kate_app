import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class QatTypesScreen extends StatelessWidget {
  const QatTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة أنواع القات والعمولات')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.qatTypes.isEmpty) return const Center(child: Text('لا توجد أنواع. أضف نوعاً جديداً.'));
          return ListView.builder(
            itemCount: provider.qatTypes.length,
            itemBuilder: (context, index) {
              final qatType = provider.qatTypes[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.eco)),
                title: Text(qatType.name),
                subtitle: Text('العمولة: ${qatType.commissionAmount} ريال لكل ${qatType.commissionPer == "piece" ? "حبة" : "زوج (حبتين)"}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQatTypeDialog(context),
        label: const Text('إضافة نوع'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddQatTypeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final commissionController = TextEditingController();
    String commissionPer = 'piece';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('إضافة نوع قات جديد'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم النوع (بقمة، قطل...)')),
                TextField(controller: commissionController, decoration: const InputDecoration(labelText: 'مبلغ العمولة (ريال)'), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                const Text('تُحسب العمولة لكل:'),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('حبة'),
                        value: 'piece',
                        groupValue: commissionPer,
                        onChanged: (v) => setDialogState(() => commissionPer = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('زوج (2)'),
                        value: 'pair',
                        groupValue: commissionPer,
                        onChanged: (v) => setDialogState(() => commissionPer = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && commissionController.text.isNotEmpty) {
                    context.read<AppProvider>().addQatType(
                      nameController.text,
                      double.tryParse(commissionController.text) ?? 0.0,
                      commissionPer,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        }
      ),
    );
  }
}
