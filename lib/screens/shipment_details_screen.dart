import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../services/supabase_service.dart';
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
  final SupabaseService _api = SupabaseService();
  List<ShipmentItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (widget.shipment.id == null || widget.shipment.id!.startsWith('temp')) {
      setState(() => isLoading = false);
      return;
    }

    final serverItems = await _api.getShipmentItems(widget.shipment.id!);
    if (mounted) {
      setState(() {
        items = serverItems;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isManager = context.watch<AppProvider>().isManagerMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الرحلة ${widget.shipment.tripDate.toIso8601String().split('T')[0]}', style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), tooltip: 'تأكيد تسليم الكل', onPressed: () => _confirmAll(context)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            onSelected: (value) {
              if (value == 'all') _shareManifest(context, null, isManager);
              else _showAgentSelectForManifest(context, isManager);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'all', child: Text('كشف الناقل (الكل)')),
              const PopupMenuItem(value: 'agent', child: Text('كشف وكيل محدد')),
            ],
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : items.isEmpty
          ? const Center(child: Text('لا توجد عدل مضافة حتى الآن.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                Color statusColor = Colors.grey;
                if (item.status == 'delivered') statusColor = Colors.green;
                if (item.status == 'lost') statusColor = Colors.red;

                double commission = 0;
                if (isManager) {
                  final provider = context.read<AppProvider>();
                  final qatType = provider.qatTypes.firstWhere((q) => q.name == item.qatTypeName, orElse: () => QatType(name: 'unknown', commissionAmount: 0));
                  if (qatType.commissionPer == 'pair') {
                    commission = (item.quantity / 2) * qatType.commissionAmount;
                  } else {
                    commission = item.quantity * qatType.commissionAmount;
                  }
                }

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: statusColor, child: const Icon(Icons.inventory, color: Colors.white)),
                    title: Text('${item.boxesCount} عدل | ${item.quantity} ${item.qatTypeName} - ${item.farmer?.name ?? "غير معروف"}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('للوكيل: ${item.agent?.name ?? "غير معروف"} - ${item.status == "pending" ? "قيد النقل" : item.status == "delivered" ? "مُسَلَّمة" : "مفقودة"}'),
                        if (isManager && commission > 0)
                          Text('عمولة الشداد: ${commission.toStringAsFixed(0)} ريال', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) async {
                        if (val == 'delete') {
                           if (item.id != null && !item.id!.startsWith('temp')) await _api.deleteShipmentItem(item.id!);
                           setState(() => items.removeAt(index));
                        } else {
                           if (item.id != null && !item.id!.startsWith('temp')) await _api.updateShipmentItemStatus(item.id!, val);
                           setState(() {
                             items[index] = ShipmentItem(
                               id: item.id, shipmentId: item.shipmentId, farmerId: item.farmerId, agentId: item.agentId, qatTypeId: item.qatTypeId, qatTypeName: item.qatTypeName, quantity: item.quantity, boxesCount: item.boxesCount, expectedPrice: item.expectedPrice, farmer: item.farmer, agent: item.agent, status: val,
                             );
                           });
                        }
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
            onPressed: () async {
              Navigator.pop(context);
              for (int i = 0; i < items.length; i++) {
                final item = items[i];
                if (item.id != null && !item.id!.startsWith('temp')) await _api.updateShipmentItemStatus(item.id!, 'delivered');
                setState(() {
                  items[i] = ShipmentItem(id: item.id, shipmentId: item.shipmentId, farmerId: item.farmerId, agentId: item.agentId, qatTypeId: item.qatTypeId, qatTypeName: item.qatTypeName, quantity: item.quantity, boxesCount: item.boxesCount, expectedPrice: item.expectedPrice, farmer: item.farmer, agent: item.agent, status: 'delivered');
                });
              }
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد تسليم جميع العدل!')));
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
                    emptyBuilder: (context) => ListTile(
                      leading: const Icon(Icons.add_circle, color: Colors.blue),
                      title: Text('إضافة مزارع جديد: "${farmerController.text}"'),
                      onTap: () async {
                        _showQuickAddDialog(context, 'مزارع', farmerController.text, (name, phone) async {
                          bool success = await provider.addFarmer(name, phone);
                          if (success) { setDialogState(() => selectedFarmer = provider.farmers.last); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة المزارع بنجاح'))); }
                          else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('هذا الاسم مسجل مسبقاً!'))); }
                        });
                      }
                    ),
                  ),
                  const SizedBox(height: 10),
                  TypeAheadField<Agent>(
                    controller: agentController,
                    builder: (context, controller, focusNode) => TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'ابحث عن الوكيل المستلم...', suffixIcon: Icon(Icons.search))),
                    itemBuilder: (context, agent) => ListTile(title: Text(agent.name)),
                    onSelected: (agent) { agentController.text = agent.name; setDialogState(() => selectedAgent = agent); },
                    suggestionsCallback: (pattern) => provider.agents.where((a) => a.name.toLowerCase().contains(pattern.toLowerCase())).toList(),
                    emptyBuilder: (context) => ListTile(
                      leading: const Icon(Icons.add_circle, color: Colors.blue),
                      title: Text('إضافة وكيل جديد: "${agentController.text}"'),
                      onTap: () async {
                        _showQuickAddDialog(context, 'وكيل', agentController.text, (name, phone) async {
                          bool success = await provider.addAgent(name, phone);
                          if (success) { setDialogState(() => selectedAgent = provider.agents.last); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الوكيل بنجاح'))); }
                          else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('هذا الاسم مسجل مسبقاً!'))); }
                        });
                      }
                    ),
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
                onPressed: () async {
                  if (selectedFarmer != null && selectedAgent != null && selectedQatTypesWithQty.isNotEmpty) {
                    bool exists = items.any((i) => i.farmerId == selectedFarmer!.id);
                    if (exists) {
                      _showDuplicateFarmerWarning(context, selectedFarmer!, selectedAgent!, selectedQatTypesWithQty, int.tryParse(boxesCountController.text) ?? 1);
                    } else {
                      await _saveItems(selectedFarmer!, selectedAgent!, selectedQatTypesWithQty, int.tryParse(boxesCountController.text) ?? 1);
                      if(mounted) Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.orange, content: Text('الرجاء تعبئة كافة الحقول.')));
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

  void _showQuickAddDialog(BuildContext context, String role, String initialName, Function(String, String?) onSave) {
    final nameCtrl = TextEditingController(text: initialName);
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة $role جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () { onSave(nameCtrl.text, phoneCtrl.text); Navigator.pop(ctx); },
            child: const Text('حفظ'),
          ),
        ],
      )
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
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: () async {
             // Delete visually first
             final oldItems = items.where((i) => i.farmerId == farmer.id).toList();
             setState(() { items.removeWhere((i) => i.farmerId == farmer.id); });
             // Delete from server
             for (var old in oldItems) { if(old.id != null) await _api.deleteShipmentItem(old.id!); }
             await _saveItems(farmer, agent, qatData, boxes);
             if(mounted) { Navigator.pop(context); Navigator.pop(context); }
          }, child: const Text('تعديل السابق')),
          ElevatedButton(onPressed: () async {
             await _saveItems(farmer, agent, qatData, boxes);
             if(mounted) { Navigator.pop(context); Navigator.pop(context); }
          }, child: const Text('إضافة كعدلة جديدة')),
        ],
      ),
    );
  }

  Future<void> _saveItems(Farmer farmer, Agent agent, List<Map<String, dynamic>> qatData, int boxes) async {
    for (var qatItem in qatData) {
      final type = qatItem['type'] as QatType;

      final newItem = ShipmentItem(
        shipmentId: widget.shipment.id ?? '',
        farmerId: farmer.id ?? '',
        agentId: agent.id ?? '',
        qatTypeId: type.id ?? '',
        qatTypeName: type.name,
        quantity: qatItem['qty'] as int,
        boxesCount: boxes,
        farmer: farmer,
        agent: agent,
        status: 'pending'
      );

      // Save to database
      if (widget.shipment.id != null && !widget.shipment.id!.startsWith('temp')) {
         final savedItem = await _api.addShipmentItem(newItem);
         if (savedItem != null) {
            setState(() => items.add(savedItem));
         }
      } else {
         // Offline / temp shipment
         setState(() {
             items.add(ShipmentItem(
                id: 'temp_${DateTime.now().millisecondsSinceEpoch}', shipmentId: newItem.shipmentId, farmerId: newItem.farmerId, agentId: newItem.agentId, qatTypeId: newItem.qatTypeId, qatTypeName: newItem.qatTypeName, quantity: newItem.quantity, boxesCount: newItem.boxesCount, farmer: farmer, agent: agent, status: 'pending'
             ));
         });
      }
    }
  }

  void _showAgentSelectForManifest(BuildContext context, bool isManager) {
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
              onTap: () { Navigator.pop(context); _shareManifest(context, provider.agents[index].name, isManager); },
            ),
          ),
        ),
      ),
    );
  }

  void _shareManifest(BuildContext context, String? specificAgentName, bool isManager) {
    if (items.isEmpty) return;

    Map<String, List<ShipmentItem>> agentItems = {};
    for (var item in items) {
      if (specificAgentName == null || item.agent?.name == specificAgentName) {
        agentItems.putIfAbsent(item.agent?.name ?? 'غير معروف', () => []).add(item);
      }
    }

    String titleText = specificAgentName == null ? "📝 كشف الناقل" : "📝 كشف الوكيل ($specificAgentName)";
    String manifestText = "$titleText\nالتاريخ: ${widget.shipment.tripDate.toIso8601String().split('T')[0]}\n\n";

    final provider = context.read<AppProvider>();
    double grandTotalCommission = 0;

    agentItems.forEach((agent, list) {
      if (specificAgentName == null) manifestText += "🏢 الوكيل: $agent\n${'-' * 20}\n";
      int totalBoxesForAgent = 0;

      Map<String, List<ShipmentItem>> farmerItems = {};
      for (var i in list) { farmerItems.putIfAbsent(i.farmer?.name ?? 'مجهول', () => []).add(i); }

      farmerItems.forEach((farmerName, fList) {
        manifestText += "👨‍🌾 $farmerName: ";
        int boxes = fList.first.boxesCount;
        totalBoxesForAgent += boxes;

        List<String> typesArr = [];
        double farmerCommission = 0;

        for (var f in fList) {
          typesArr.add("${f.quantity} حبة ${f.qatTypeName}");
          if (isManager) {
            final qt = provider.qatTypes.firstWhere((q) => q.name == f.qatTypeName, orElse: () => QatType(name: 'uk', commissionAmount: 0));
            double c = qt.commissionPer == 'pair' ? (f.quantity / 2) * qt.commissionAmount : f.quantity * qt.commissionAmount;
            farmerCommission += c;
          }
        }

        manifestText += "($boxes عدل) - ${typesArr.join(" + ")}\n";
        if (isManager && farmerCommission > 0) {
           manifestText += "   [عمولة: ${farmerCommission.toStringAsFixed(0)}]\n";
           grandTotalCommission += farmerCommission;
        }
      });
      manifestText += ">> إجمالي العدل للوكيل ($agent): $totalBoxesForAgent عدل\n\n";
    });

    if (isManager && grandTotalCommission > 0) {
      manifestText += "====================\n";
      manifestText += "إجمالي عمولات الشحنة: ${grandTotalCommission.toStringAsFixed(0)} ريال\n";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معاينة الكشف'),
        content: SingleChildScrollView(child: SelectableText(manifestText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton.icon(
            icon: const Icon(Icons.send, color: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final Uri whatsappUrl = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(manifestText)}");
              if (await canLaunchUrl(whatsappUrl)) { await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication); }
              else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء النسخ يدوياً.'))); }
              Navigator.pop(context);
            },
            label: const Text('إرسال WhatsApp', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
