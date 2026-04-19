import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => items.removeAt(index)),
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

  void _showAddItemDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    Farmer? selectedFarmer;
    Agent? selectedAgent;

    // Support for multiple Qat Types inside one Adla
    List<Map<String, dynamic>> selectedQatTypesWithQty = [];

    final farmerController = TextEditingController();
    final agentController = TextEditingController();
    final boxesCountController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('إضافة عدلة (أو عدة عدل لنفس المزارع)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Farmer Search & Add ---
                  TypeAheadField<Farmer>(
                    controller: farmerController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'ابحث عن المزارع...', suffixIcon: Icon(Icons.search)),
                      );
                    },
                    itemBuilder: (context, farmer) => ListTile(title: Text(farmer.name)),
                    onSelected: (farmer) {
                      farmerController.text = farmer.name;
                      setDialogState(() => selectedFarmer = farmer);
                    },
                    suggestionsCallback: (pattern) {
                      return provider.farmers.where((f) => f.name.toLowerCase().contains(pattern.toLowerCase())).toList();
                    },
                    emptyBuilder: (context) => ListTile(
                      leading: const Icon(Icons.add_circle, color: Colors.blue),
                      title: Text('إضافة مزارع جديد: "${farmerController.text}"'),
                      onTap: () async {
                        await provider.addFarmer(farmerController.text, null);
                        setDialogState(() => selectedFarmer = provider.farmers.last);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة المزارع')));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- Agent Search & Add ---
                  TypeAheadField<Agent>(
                    controller: agentController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'ابحث عن الوكيل المستلم...', suffixIcon: Icon(Icons.search)),
                      );
                    },
                    itemBuilder: (context, agent) => ListTile(title: Text(agent.name)),
                    onSelected: (agent) {
                      agentController.text = agent.name;
                      setDialogState(() => selectedAgent = agent);
                    },
                    suggestionsCallback: (pattern) {
                      return provider.agents.where((a) => a.name.toLowerCase().contains(pattern.toLowerCase())).toList();
                    },
                    emptyBuilder: (context) => ListTile(
                      leading: const Icon(Icons.add_circle, color: Colors.blue),
                      title: Text('إضافة وكيل جديد: "${agentController.text}"'),
                      onTap: () async {
                        await provider.addAgent(agentController.text, null);
                        setDialogState(() => selectedAgent = provider.agents.last);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الوكيل')));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: boxesCountController,
                    decoration: const InputDecoration(labelText: 'عدد العدل الإجمالي لهذا المزارع'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  const Text('أنواع القات في هذه العدلة:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  ...selectedQatTypesWithQty.map((item) {
                    final qat = item['type'] as QatType;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(qat.name),
                      trailing: Text('${item['qty']} حبة'),
                      leading: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => setDialogState(() => selectedQatTypesWithQty.remove(item)),
                      ),
                    );
                  }).toList(),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة نوع قات للعدلة'),
                    onPressed: () {
                      _showAddQatTypeToAdlaDialog(context, provider.qatTypes, (QatType type, int qty) {
                        setDialogState(() {
                          selectedQatTypesWithQty.add({'type': type, 'qty': qty});
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (selectedFarmer != null && selectedAgent != null && selectedQatTypesWithQty.isNotEmpty) {
                    // Validation Logic: Check if farmer already exists in THIS shipment
                    bool exists = items.any((i) => i.farmerId == selectedFarmer!.id);
                    if (exists) {
                      _showDuplicateFarmerWarning(context, selectedFarmer!, selectedAgent!, selectedQatTypesWithQty, int.tryParse(boxesCountController.text) ?? 1);
                    } else {
                      _saveItems(selectedFarmer!, selectedAgent!, selectedQatTypesWithQty, int.tryParse(boxesCountController.text) ?? 1);
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء التأكد من اختيار المزارع، الوكيل، وإضافة نوع قات واحد على الأقل.')));
                  }
                },
                child: const Text('حفظ العدلة'),
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
        title: const Text('حدد النوع والعدد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<QatType>(
              decoration: const InputDecoration(labelText: 'نوع القات'),
              items: qatTypes.map((q) => DropdownMenuItem(value: q, child: Text(q.name))).toList(),
              onChanged: (v) => selectedType = v,
            ),
            TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'عدد الحبات'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (selectedType != null && qtyController.text.isNotEmpty) {
                onAdd(selectedType!, int.parse(qtyController.text));
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          )
        ],
      ),
    );
  }

  void _showDuplicateFarmerWarning(BuildContext context, Farmer farmer, Agent agent, List<Map<String, dynamic>> qatData, int boxes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنبيه: المزارع مضاف مسبقاً!'),
        content: Text('المزارع "${farmer.name}" لديه قات مسجل بالفعل في هذه الرحلة. ماذا تريد أن تفعل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              // Delete old records for this farmer and add the new ones
              setState(() {
                items.removeWhere((i) => i.farmerId == farmer.id);
                _saveItems(farmer, agent, qatData, boxes);
              });
              Navigator.pop(context); // close warning
              Navigator.pop(context); // close main dialog
            },
            child: const Text('تعديل/استبدال السابق'),
          ),
          ElevatedButton(
            onPressed: () {
              // Just add alongside existing
              setState(() {
                _saveItems(farmer, agent, qatData, boxes);
              });
              Navigator.pop(context); // close warning
              Navigator.pop(context); // close main dialog
            },
            child: const Text('إضافة بجوار السابق'),
          ),
        ],
      ),
    );
  }

  void _saveItems(Farmer farmer, Agent agent, List<Map<String, dynamic>> qatData, int boxes) {
    for (var qatItem in qatData) {
      final type = qatItem['type'] as QatType;
      final qty = qatItem['qty'] as int;
      items.add(ShipmentItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        shipmentId: widget.shipment.id ?? '',
        farmerId: farmer.id ?? farmer.name,
        agentId: agent.id ?? agent.name,
        qatTypeId: type.id ?? type.name,
        qatTypeName: type.name,
        quantity: qty,
        boxesCount: boxes,
        farmer: farmer,
        agent: agent,
      ));
    }
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

      // We might have multiple items per farmer if they sent multiple qat types.
      // Let's group by farmer for display readability
      Map<String, List<ShipmentItem>> farmerItems = {};
      for (var i in list) { farmerItems.putIfAbsent(i.farmer?.name ?? 'مجهول', () => []).add(i); }

      farmerItems.forEach((farmerName, fList) {
        manifestText += "👨‍🌾 $farmerName: ";
        // Assume boxesCount is identical for items belonging to the same Adla
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
