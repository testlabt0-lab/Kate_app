import 'package:flutter/material.dart';
import '../models/shipment.dart';
import 'shipment_details_screen.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});
  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  final List<Shipment> _mockShipments = [Shipment(id: '1', tripDate: DateTime.now().subtract(const Duration(days: 1)), status: 'delivered')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الشحنات')),
      body: ListView.builder(
        itemCount: _mockShipments.length,
        itemBuilder: (context, index) {
          final shipment = _mockShipments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: shipment.status == 'pending' ? Colors.blue.shade100 : Colors.green.shade100,
                child: Icon(Icons.assignment, color: shipment.status == 'pending' ? Colors.blue : Colors.green),
              ),
              title: Text('رحلة يوم: ${shipment.tripDate.toIso8601String().split('T')[0]}'),
              subtitle: Text('الحالة: ${shipment.status == 'pending' ? 'قيد التجهيز' : 'مكتملة ومُسلمة'}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShipmentDetailsScreen(shipment: shipment))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTripOptions(context),
        label: const Text('رحلة جديدة'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showNewTripOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16.0), child: Text('خيارات الرحلة الجديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.content_copy, color: Colors.blue),
              title: const Text('نسخ مزارعي الأمس (سريع)'),
              subtitle: const Text('إنشاء رحلة بنفس الأسماء والوكلاء لتعديل الأعداد فقط'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _mockShipments.insert(0, Shipment(id: DateTime.now().millisecondsSinceEpoch.toString(), tripDate: DateTime.now(), status: 'pending')));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الرحلة ونسخ تفاصيل الأمس!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.green),
              title: const Text('رحلة جديدة فارغة'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _mockShipments.insert(0, Shipment(id: DateTime.now().millisecondsSinceEpoch.toString(), tripDate: DateTime.now(), status: 'pending')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
