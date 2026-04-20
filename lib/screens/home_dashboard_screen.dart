import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم والإحصائيات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.farmers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          double totalMarketDebt = provider.farmers.fold(0.0, (sum, f) => sum + f.totalDebt);
          int totalFarmers = provider.farmers.length;
          int totalAgents = provider.agents.length;

          return RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('ملخص اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, title: 'إجمالي ديون السوق', value: '${totalMarketDebt.toStringAsFixed(0)} ريال', icon: Icons.money_off, color: Colors.red.shade50, textColor: Colors.red.shade900)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, title: 'العدل الموردة اليوم', value: '45 عدلة', icon: Icons.local_shipping, color: Colors.blue.shade50, textColor: Colors.blue.shade900)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, title: 'عدد المزارعين', value: '$totalFarmers', icon: Icons.people, color: Colors.green.shade50, textColor: Colors.green.shade900)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, title: 'عدد الوكلاء', value: '$totalAgents', icon: Icons.store, color: Colors.orange.shade50, textColor: Colors.orange.shade900)),
                  ],
                ),

                const SizedBox(height: 32),
                const Text('المبيعات خلال الأسبوع (تقديرية)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Chart section
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)]),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => Text('يوم ${val.toInt()}'))),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 80, color: Colors.green)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 60, color: Colors.green)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 90, color: Colors.green)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 45, color: Colors.green)]),
                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 70, color: Colors.green)]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 32),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
