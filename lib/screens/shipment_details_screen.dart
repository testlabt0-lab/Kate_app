import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/shipment.dart';
import '../models/farmer.dart';
import '../models/agent.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final Shipment shipment;
  const ShipmentDetailsScreen({super.key, required this.shipment});
  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  List<ShipmentItem> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الرحلة ${widget.shipment.tripDate.toIso8601String().split('T')[0]}'),
        actions: [IconButton(icon: const Icon(Icons.share), tooltip: 'مشاركة الكشف (مانيفيست)', onPressed: () => _shareManifest(context))],
      ),
      body: items.isEmpty
          ? const Center(child: Text('لا توجد عدل مضافة.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: const Icon(Icons.eco, color: Colors.green),
                  title: Text('${item.quantity} ${item.qatType} - من: ${item.farmer?.name ?? "غير معروف"}'),
                  subtitle: Text('إلى الوكيل: ${item.agent?.name ?? "غير معروف"}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        label: const Text('إضافة عدلة'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    Farmer? selectedFarmer;
    Agent? selectedAgent;
    final typeController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عدلة قات'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Farmer>(decoration: const InputDecoration(labelText: 'المزارع'), items: provider.farmers.map((f) => DropdownMenuItem(value: f, child: Text(f.name))).toList(), onChanged: (v) => selectedFarmer = v),
              DropdownButtonFormField<Agent>(decoration: const InputDecoration(labelText: 'الوكيل المستلم'), items: provider.agents.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(), onChanged: (v) => selectedAgent = v),
              TextField(controller: typeController, decoration: const InputDecoration(labelText: 'النوع')),
              TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'العدد'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (selectedFarmer != null && selectedAgent != null && typeController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                setState(() => items.add(ShipmentItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(), shipmentId: widget.shipment.id ?? '',
                  farmerId: selectedFarmer!.id ?? '', agentId: selectedAgent!.id ?? '',
                  qatType: typeController.text, quantity: int.tryParse(quantityController.text) ?? 0,
                  farmer: selectedFarmer, agent: selectedAgent,
                )));
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _shareManifest(BuildContext context) {
    if (items.isEmpty) return;
    Map<String, List<ShipmentItem>> agentItems = {};
    for (var item in items) { agentItems.putIfAbsent(item.agent?.name ?? 'غير معروف', () => []).add(item); }
    String manifestText = "📝 كشف الرحلة\nالتاريخ: ${widget.shipment.tripDate.toIso8601String().split('T')[0]}\n\n";
    agentItems.forEach((agent, list) {
      manifestText += "🏢 الوكيل: $agent\n${'-' * 20}\n";
      for (var item in list) { manifestText += "👨‍🌾 ${item.farmer?.name ?? 'مجهول'}: ${item.quantity} ${item.qatType}\n"; }
      manifestText += "\n";
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معاينة الكشف'),
        content: SingleChildScrollView(child: Text(manifestText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الكشف!'))); Navigator.pop(context); },
            child: const Text('مشاركة / نسخ'),
          ),
        ],
      ),
    );
  }
}
