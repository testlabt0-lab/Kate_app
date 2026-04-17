import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/shipment.dart';
import '../models/farmer.dart';
import '../models/agent.dart';
import '../models/qat_type.dart';

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
        actions: [IconButton(icon: const Icon(Icons.share), tooltip: 'مشاركة الكشف', onPressed: () => _shareManifest(context))],
      ),
      body: items.isEmpty
          ? const Center(child: Text('لا توجد عدل مضافة.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: const Icon(Icons.eco, color: Colors.green),
                  title: Text('${item.boxesCount} عدل | ${item.quantity} حبة ${item.qatTypeName} - المزارع: ${item.farmer?.name ?? "غير معروف"}'),
                  subtitle: Text('الوكيل المرسل إليه: ${item.agent?.name ?? "غير معروف"}'),
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
    QatType? selectedQatType;
    final quantityController = TextEditingController();
    final boxesCountController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عدلة للرحلة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Farmer>(decoration: const InputDecoration(labelText: 'المزارع'), items: provider.farmers.map((f) => DropdownMenuItem(value: f, child: Text(f.name))).toList(), onChanged: (v) => selectedFarmer = v),
              DropdownButtonFormField<Agent>(decoration: const InputDecoration(labelText: 'الوكيل المستلم'), items: provider.agents.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(), onChanged: (v) => selectedAgent = v),
              DropdownButtonFormField<QatType>(
                decoration: const InputDecoration(labelText: 'نوع القات (من قاعدة البيانات)'),
                items: provider.qatTypes.map((q) => DropdownMenuItem(value: q, child: Text(q.name))).toList(),
                onChanged: (v) => selectedQatType = v,
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: boxesCountController, decoration: const InputDecoration(labelText: 'عدد العدل'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'عدد الحبات'), keyboardType: TextInputType.number)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (selectedFarmer != null && selectedAgent != null && selectedQatType != null && quantityController.text.isNotEmpty && boxesCountController.text.isNotEmpty) {
                setState(() => items.add(ShipmentItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  shipmentId: widget.shipment.id ?? '',
                  farmerId: selectedFarmer!.id ?? '',
                  agentId: selectedAgent!.id ?? '',
                  qatTypeId: selectedQatType!.id ?? '',
                  qatTypeName: selectedQatType!.name,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                  boxesCount: int.tryParse(boxesCountController.text) ?? 1,
                  farmer: selectedFarmer,
                  agent: selectedAgent,
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

    // Grouping by Agent
    Map<String, List<ShipmentItem>> agentItems = {};
    for (var item in items) { agentItems.putIfAbsent(item.agent?.name ?? 'غير معروف', () => []).add(item); }

    String manifestText = "📝 كشف الرحلة (مانيفيست)\nالتاريخ: ${widget.shipment.tripDate.toIso8601String().split('T')[0]}\n\n";

    agentItems.forEach((agent, list) {
      manifestText += "🏢 الوكيل: $agent\n${'-' * 20}\n";
      int totalBoxesForAgent = 0;

      for (var item in list) {
        manifestText += "👨‍🌾 ${item.farmer?.name ?? 'مجهول'}: ${item.boxesCount} عدل (${item.quantity} حبة ${item.qatTypeName})\n";
        totalBoxesForAgent += item.boxesCount;
      }
      manifestText += ">> إجمالي العدل للوكيل ($agent): $totalBoxesForAgent عدل\n\n";
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معاينة الكشف'),
        content: SingleChildScrollView(child: Text(manifestText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الكشف لمشاركته بناجح!'))); Navigator.pop(context); },
            child: const Text('مشاركة / نسخ'),
          ),
        ],
      ),
    );
  }
}
