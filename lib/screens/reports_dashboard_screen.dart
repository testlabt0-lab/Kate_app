import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'farmer_report_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isManager = provider.isManagerMode;

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير الشاملة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('تقارير المزارعين:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...provider.farmers.map((farmer) => Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(farmer.name),
              subtitle: isManager ? Text('الديون: ${farmer.totalDebt} ريال', style: const TextStyle(color: Colors.red)) : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FarmerReportScreen(farmer: farmer))),
            ),
          )),
          const SizedBox(height: 20),
          const Text('تقارير الوكلاء:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...provider.agents.map((agent) => Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: Text(agent.name),
              subtitle: isManager ? Text('الرصيد المعلق: ${agent.balance} ريال') : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Future: Agent specific full report
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تقرير الوكيل قيد التطوير...')));
              },
            ),
          )),
        ],
      ),
    );
  }
}
