import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام الشداد (الرئيسية)', style: TextStyle(fontWeight: FontWeight.bold)),
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

          // Calculate some quick stats
          double totalMarketDebt = provider.farmers.fold(0.0, (sum, f) => sum + f.totalDebt);
          int totalFarmers = provider.farmers.length;
          int totalAgents = provider.agents.length;

          return RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('مرحباً بك!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('إليك ملخص سريع لحالة العمل اليوم:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Main Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'إجمالي ديون السوق',
                        value: '${totalMarketDebt.toStringAsFixed(0)} ريال',
                        icon: Icons.money_off,
                        color: Colors.red.shade100,
                        textColor: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'شحنات اليوم',
                        value: 'رحلة نشطة', // Dynamic later
                        icon: Icons.local_shipping,
                        color: Colors.blue.shade100,
                        textColor: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Secondary Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'المزارعين',
                        value: '$totalFarmers',
                        icon: Icons.people,
                        color: Colors.green.shade100,
                        textColor: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'الوكلاء',
                        value: '$totalAgents',
                        icon: Icons.store,
                        color: Colors.orange.shade100,
                        textColor: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Quick Actions
                const Text('إجراءات سريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.add_shopping_cart)),
                  title: const Text('تسجيل طلب/مقاضي لمزارع'),
                  trailing: const Icon(Icons.chevron_right),
                  tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    // Navigate to Add Order quickly
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.tertiaryContainer, child: const Icon(Icons.attach_money)),
                  title: const Text('إجراء تصفية وكيل'),
                  trailing: const Icon(Icons.chevron_right),
                  tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    // Navigate to Settlements quickly
                  },
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 32),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
