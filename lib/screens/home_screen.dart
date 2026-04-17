import 'package:flutter/material.dart';
import 'farmers_screen.dart';
import 'agents_screen.dart';
import 'transporters_screen.dart';
import 'shipments_screen.dart';
import 'rawakib_screen.dart';
import 'farmer_orders_screen.dart';
import 'settlements_screen.dart';
import 'qat_types_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام الشداد'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(context, 'المزارعين', Icons.people, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmersScreen()))),
          _buildMenuCard(context, 'الوكلاء', Icons.store, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentsScreen()))),
          _buildMenuCard(context, 'أنواع القات', Icons.category, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QatTypesScreen()))),
          _buildMenuCard(context, 'الشحنات (الرحلات)', Icons.assignment, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentsScreen()))),
          _buildMenuCard(context, 'الناقلين', Icons.local_shipping, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportersScreen()))),
          _buildMenuCard(context, 'الرواكب', Icons.inventory, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RawakibScreen()))),
          _buildMenuCard(context, 'الطلبات والمقاضي', Icons.shopping_basket, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()))),
          _buildMenuCard(context, 'التصفيات', Icons.attach_money, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettlementsScreen()))),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
