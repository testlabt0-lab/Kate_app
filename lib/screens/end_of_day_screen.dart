import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/shipment.dart';
import '../models/qat_type.dart';

class EndOfDayScreen extends StatelessWidget {
  const EndOfDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isManager = provider.isManagerMode;

    // Calculate Today's Stats
    final today = DateTime.now();
    int totalBoxes = 0;
    int pendingItems = 0;
    int lostItems = 0;
    double expectedCommission = 0;
    Map<String, int> qatTotals = {};

    // Get today's shipments
    final todaysShipments = provider.shipments.where((s) =>
      s.tripDate.year == today.year &&
      s.tripDate.month == today.month &&
      s.tripDate.day == today.day
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('جرد نهاية اليوم')),
      body: todaysShipments.isEmpty
        ? const Center(child: Text('لا توجد شحنات مسجلة لهذا اليوم.'))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                color: Colors.blueAccent,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'ملخص عمليات اليوم',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
                  title: const Text('إجمالي الشحنات المرسلة'),
                  trailing: Text('${todaysShipments.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.blue),
                  title: const Text('إجمالي العدل'),
                  trailing: const Text('جارِ الحساب...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Needs async fetch or provider state
                ),
              ),
              const SizedBox(height: 16),
              const Text('حالة التوصيل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Card(
                color: Colors.orange.shade50,
                child: const ListTile(
                  leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  title: Text('عدل لم يتم تأكيد وصولها'),
                  trailing: Text('الرجاء تأكيد التسليم', style: TextStyle(color: Colors.orange)),
                ),
              ),
              if (isManager) ...[
                const SizedBox(height: 16),
                const Text('العوائد المتوقعة (للمدير):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.monetization_on, color: Colors.green),
                    title: Text('إجمالي العمولات'),
                    trailing: Text('0 ريال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                ),
              ],
            ],
          ),
    );
  }
}
