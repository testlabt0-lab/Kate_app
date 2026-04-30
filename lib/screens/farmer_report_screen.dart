import '../services/pdf_farmer_report_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/farmer.dart';
import '../models/shipment.dart';

class FarmerReportScreen extends StatelessWidget {
  final Farmer farmer;
  const FarmerReportScreen({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isManager = provider.isManagerMode;

    // Calculate aggregated stats
    List<ShipmentItem> farmerItems = [];
    int totalBoxes = 0;
    Map<String, int> typeCounts = {};

    for (var shipment in provider.shipments) {
      // Note: Ideally, we should fetch items per shipment, but for the demo we'll assume we have a way.
      // Since shipment items are lazy loaded in details, a proper implementation would query Supabase for all items by farmerId.
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('كشف حساب: ${farmer.name}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'القات المورد (الشحنات)'),
              Tab(text: 'سجل الديون والدفعات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQatHistoryTab(isManager),
            _buildFinancialTab(context, isManager),
          ],
        ),
      ),
    );
  }

  Widget _buildQatHistoryTab(bool isManager) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('إجمالي القات المورد (منذ البداية)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('بقمة:'), Text('150 حبة', style: TextStyle(fontWeight: FontWeight.bold))]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('قطل:'), Text('80 حبة', style: TextStyle(fontWeight: FontWeight.bold))]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('إجمالي العدل:'), Text('10 عدل', style: TextStyle(fontWeight: FontWeight.bold))]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text('تفاصيل الأيام الأخيرة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('تاريخ: ${"2026-04-18"}'),
            subtitle: const Text('الوكيل: صالح\n2 عدل (20 بقمة + 10 قطل)'),
            trailing: const Text('مُسلّمة', style: TextStyle(color: Colors.green)),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialTab(BuildContext context, bool isManager) {
    if (isManager) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('إجمالي الديون الحالية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                  Text('${farmer.totalDebt} ريال', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(onPressed: () { PdfFarmerReportService.generateAndPrintFarmerReport(farmer: farmer); }, icon: const Icon(Icons.picture_as_pdf), label: const Text('تصدير وطباعة الكشف (PDF)')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('سجل العمليات المالية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(
            child: ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: const Text('سحب رواكب (دين)'),
              subtitle: const Text('2026-04-17
تم أخذ 50 راكبة'),
              trailing: const Text('- 5000 ريال', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }
    if (!isManager) {
      return const Center(child: Text('البيانات المالية متاحة للمدير فقط.', style: TextStyle(color: Colors.grey, fontSize: 18)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('إجمالي الديون الحالية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                Text('${farmer.totalDebt} ريال', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text('سجل العمليات المالية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.red),
            title: const Text('سحب رواكب (دين)'),
            subtitle: const Text('2026-04-17\nتم أخذ 50 راكبة'),
            trailing: const Text('- 5000 ريال', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.green),
            title: const Text('تصفية وكيل (تسديد)'),
            subtitle: const Text('2026-04-16\nبيد الوكيل: صالح'),
            trailing: const Text('+ 5000 ريال', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
