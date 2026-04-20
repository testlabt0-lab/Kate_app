import 'package:flutter/material.dart';
import 'agents_screen.dart';
import 'transporters_screen.dart';
import 'rawakib_screen.dart';
import 'farmer_orders_screen.dart';
import 'settlements_screen.dart';
import 'qat_types_screen.dart';
import 'lost_items_screen.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة النظام والمزيد')),
      body: ListView(
        children: [
          _buildListTile(context, 'الوكلاء (العملاء)', Icons.store, const AgentsScreen()),
          _buildListTile(context, 'أنواع القات والعمولات', Icons.category, const QatTypesScreen()),
          _buildListTile(context, 'الناقلين', Icons.local_shipping, const TransportersScreen()),
          const Divider(),
          _buildListTile(context, 'تتبع الضياع (العدل المفقودة)', Icons.warning_amber_rounded, const LostItemsScreen(), iconColor: Colors.red),
          _buildListTile(context, 'الرواكب (المخزون)', Icons.inventory_2, const RawakibScreen()),
          _buildListTile(context, 'الطلبات والمقاضي (ديون السوق)', Icons.shopping_basket, const FarmerOrdersScreen()),
          _buildListTile(context, 'التصفيات المالية', Icons.account_balance_wallet, const SettlementsScreen(), iconColor: Colors.green),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('مزامنة البيانات يدوياً'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري المزامنة مع السيرفر...')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, Widget destination, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
    );
  }
}
