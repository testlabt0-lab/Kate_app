import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart';
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
        title: Text('تفاصيل الرحلة ${widget.shipment.tripDate.toIso8601String().split('T')[0]}', style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), tooltip: 'تأكيد تسليم الكل', onPressed: () => _confirmAll(context)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            onSelected: (value) {
              if (value == 'all') _shareManifest(context, null);
              else _showAgentSelectForManifest(context);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'all', child: Text('كشف الناقل (الكل)')),
              const PopupMenuItem(value: 'agent', child: Text('كشف وكيل محدد')),
            ],
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('لا توجد عدل مضافة.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                Color statusColor = Colors.grey;
                if (item.status == 'delivered') statusColor = Colors.green;
                if (item.status == 'lost') statusColor = Colors.red;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: statusColor, child: const Icon(Icons.inventory, color: Colors.white)),
                    title: Text('${item.boxesCount} عدل | ${item.quantity} ${item.qatTypeName} - ${item.farmer?.name ?? "غير معروف"}'),
                    subtitle: Text('للوكيل: ${item.agent?.name ?? "غير معروف"} - ${item.status == "pending" ? "قيد النقل" : item.status == "delivered" ? "مُسَلَّمة" : "مفقودة"}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        setState(() {
                          if (val == 'delete') items.removeAt(index);
                          else {
                            items[index] = ShipmentItem(
                              id: item.id, shipmentId: item.shipmentId, farmerId: item.farmerId, agentId: item.agentId, qatTypeId: item.qatTypeId, qatTypeName: item.qatTypeName, quantity: item.quantity, boxesCount: item.boxesCount, expectedPrice: item.expectedPrice, farmer: item.farmer, agent: item.agent, status: val,
                            );
                          }
                        });
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'delivered', child: Text('تأكيد التسليم ✔️')),
                        const PopupMenuItem(value: 'lost', child: Text('تحديد كـ "مفقودة" ❌')),
                        const PopupMenuItem(value: 'pending', child: Text('إرجاع "قيد النقل" ⏳')),
                        const PopupMenuItem(value: 'delete', child: Text('حذف العدلة 🗑️')),
                      ],
                    ),
                  ),
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

  void _confirmAll(BuildContext context) {
    if (items.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسليم الكل'),
        content: const Text('هل أنت متأكد من تغيير حالة جميع العدل في هذه الرحلة إلى "مُسلَّمة"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              setState(() {
                for (int i = 0; i < items.length; i++) {
                  final item = items[i];
                  items[i] = ShipmentItem(id: item.id, shipmentId: item.shipmentId, farmerId: item.farmerId, agentId: item.agentId, qatTypeId: item.qatTypeId, qatTypeName: item.qatTypeName, quantity: item.quantity, boxesCount: item.boxesCount, expectedPrice: item.expectedPrice, farmer: item.farmer, agent: item.agent, status: 'delivered');
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد تسليم جميع العدل!')));
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    Farmer? selectedFarmer;
    Agent? selectedAgent;
    List<Map<String, dynamic>> selectedQatTypesWithQty = [];
    final farmerController = TextEditingController();
    final agentController = TextEditingController();
    final boxesCountController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('إضافة عدلة للمزارع'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TypeAheadField<Farmer>(
                    controller: farmerController,
                    builder: (context, controller, focusNode) => TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'ابحث عن المزارع...', suffixIcon: Icon(Icons.search))),
                    itemBuilder: (context, farmer) => ListTile(title: Text(farmer.name)),
                    onSelected: (farmer) { farmerController.text = farmer.name; setDialogState(() => selectedFarmer = farmer); },
                    suggestionsCallback: (pattern) => provider.farmers.where((f) => f.name.toLowerCase().contains(pattern.toLowerCase())).toList(),
                    emptyBuilder: (context) => ListTile(leading: const Icon(Icons.add_circle, color: Colors.blue), title: Text('إضافة مزارع جديد: "${farmerController.text}"'), onTap: () async { await provider.addFarmer(farmerController.text, null); setDialogState(() => selectedFarmer = provider.farmers.last); }),
                  ),
                  const SizedBox(height: 10),
                  TypeAheadField<Agent>(
                    controller: agentController,
                    builder: (context, controller, focusNode) => TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'ابحث عن الوكيل المستلم...', suffixIcon: Icon(Icons.search))),
                    itemBuilder: (context, agent) => ListTile(title: Text(agent.name)),
                    onSelected: (agent) { agentController.text = agent.name; setDialogState(() => selectedAgent = agent); },
                    suggestionsCallback: (pattern) => provider.agents.where((a) => a.name.toLowerCase().contains(pattern.toLowerCase())).toList(),
                    emptyBuilder: (context) => ListTile(leading: const Icon(Icons.add_circle, color: Colors.blue), title: Text('إضافة وكيل جديد: "${agentController.text}"'), onTap: () async { await provider.addAgent(agentController.text, null); setDialogState(() => selectedAgent = provider.agents.last); }),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: boxesCountController, decoration: const InputDecoration(labelText: 'عدد العدل الإجمالي'), keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  const Text('أنواع القات:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...selectedQatTypesWithQty.map((item) => ListTile(
                    dense: true, contentPadding: EdgeInsets.zero, title: Text((item['type'] as QatType).name), trailing: Text('${item['qty']} حبة'),
                    leading: IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setDialogState(() => selectedQatTypesWithQty.remove(item))),
                  )).toList(),
                  TextButton.icon(icon: const Icon(Icons.add), label: const Text('إضافة نوع للعدلة'), onPressed: () => _showAddQatTypeToAdlaDialog(context, provider.qatTypes, (QatType type, int qty) => setDialogState(() => selectedQatTypesWithQty.add({'type': type, 'qty': qty})))),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (selectedFarmer != null && selectedAgent != null && selectedQatTypesWithQty.isNotEmpty) {
                    bool exists = items.any((i) => i.farmerId == selectedFarmer!.id);
                    if (exists) _showDuplicateFarmerWarning(context, selectedFarmer!, selectedAgent!, selectedQatTypesWithQty, int.tryParse(boxesCountController.text) ?? 1);
                    else { _saveItems(selectedFarmer!, selectedAgent!, selectedQatTypesWithQty, int.tryParse(boxesCountController.text) ?? 1); Navigator.pop(context); }
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showAddQatTypeToAdlaDialog(BuildContext context, List<QatType> qatTypes, Function(QatType, int) onAdd) {
    QatType? selectedType;
    final qtyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النوع والعدد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<QatType>(decoration: const InputDecoration(labelText: 'نوع القات'), items: qatTypes.map((q) => DropdownMenuItem(value: q, child: Text(q.name))).toList(), onChanged: (v) => selectedType = v),
            TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'عدد الحبات'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [ElevatedButton(onPressed: () { if (selectedType != null && qtyController.text.isNotEmpty) { onAdd(selectedType!, int.parse(qtyController.text)); Navigator.pop(context); } }, child: const Text('إضافة'))],
      ),
    );
  }

  void _showDuplicateFarmerWarning(BuildContext context, Farmer farmer, Agent agent, List<Map<String, dynamic>> qatData, int boxes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنبيه: مزارع مكرر!'),
        content: const Text('المزارع مسجل بالفعل. ماذا تريد؟'),
        actions: [
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () { setState(() { items.removeWhere((i) => i.farmerId == farmer.id); _saveItems(farmer, agent, qatData, boxes); }); Navigator.pop(context); Navigator.pop(context); }, child: const Text('تعديل السابق')),
          ElevatedButton(onPressed: () { setState(() { _saveItems(farmer, agent, qatData, boxes); }); Navigator.pop(context); Navigator.pop(context); }, child: const Text('إضافة كعدلة جديدة')),
        ],
      ),
    );
  }

  void _saveItems(Farmer farmer, Agent agent, List<Map<String, dynamic>> qatData, int boxes) {
    for (var qatItem in qatData) {
      final type = qatItem['type'] as QatType;
      items.add(ShipmentItem(id: DateTime.now().millisecondsSinceEpoch.toString(), shipmentId: widget.shipment.id ?? '', farmerId: farmer.id ?? farmer.name, agentId: agent.id ?? agent.name, qatTypeId: type.id ?? type.name, qatTypeName: type.name, quantity: qatItem['qty'] as int, boxesCount: boxes, farmer: farmer, agent: agent, status: 'pending'));
    }
  }

  void _showAgentSelectForManifest(BuildContext context) {
    final provider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر الوكيل لإرسال الكشف له'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.agents.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(provider.agents[index].name),
              onTap: () { Navigator.pop(context); _shareManifest(context, provider.agents[index].name); },
            ),
          ),
        ),
      ),
    );
  }

  void _shareManifest(BuildContext context, String? specificAgentName) {
    if (items.isEmpty) return;

    Map<String, List<ShipmentItem>> agentItems = {};
    for (var item in items) {
      if (specificAgentName == null || item.agent?.name == specificAgentName) {
        agentItems.putIfAbsent(item.agent?.name ?? 'غير معروف', () => []).add(item);
      }
    }

    String titleText = specificAgentName == null ? "📝 كشف الناقل" : "📝 كشف الوكيل ($specificAgentName)";
    String manifestText = "$titleText\nالتاريخ: ${widget.shipment.tripDate.toIso8601String().split('T')[0]}\n\n";

    agentItems.forEach((agent, list) {
      if (specificAgentName == null) manifestText += "🏢 الوكيل: $agent\n${'-' * 20}\n";
      int totalBoxesForAgent = 0;

      Map<String, List<ShipmentItem>> farmerItems = {};
      for (var i in list) { farmerItems.putIfAbsent(i.farmer?.name ?? 'مجهول', () => []).add(i); }

      farmerItems.forEach((farmerName, fList) {
        manifestText += "👨‍🌾 $farmerName: ";
        int boxes = fList.first.boxesCount;
        totalBoxesForAgent += boxes;
        List<String> typesArr = fList.map((f) => "${f.quantity} حبة ${f.qatTypeName}").toList();
        manifestText += "($boxes عدل) - ${typesArr.join(" + ")}\n";
      });
      manifestText += ">> إجمالي العدل للوكيل ($agent): $totalBoxesForAgent عدل\n\n";
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معاينة الكشف للنسخ/الإرسال'),
        content: SingleChildScrollView(child: SelectableText(manifestText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton.icon(
            icon: const Icon(Icons.send, color: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final Uri whatsappUrl = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(manifestText)}");
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح تطبيق واتساب. يرجى النسخ اليدوي.')));
              }
              Navigator.pop(context);
            },
            label: const Text('إرسال عبر WhatsApp', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
