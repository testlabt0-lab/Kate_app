import 'package:flutter/material.dart';
import '../models/shipment.dart';
import 'shipment_details_screen.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});
  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  final List<Shipment> _mockShipments = [Shipment(id: '1', tripDate: DateTime.now(), status: 'pending')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الشحنات (الرحلات)')),
      body: ListView.builder(
        itemCount: _mockShipments.length,
        itemBuilder: (context, index) {
          final shipment = _mockShipments[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.assignment),
              title: Text('رحلة يوم: ${shipment.tripDate.toIso8601String().split('T')[0]}'),
              subtitle: Text('الحالة: ${shipment.status == 'pending' ? 'قيد التجهيز' : 'مكتملة'}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShipmentDetailsScreen(shipment: shipment))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _mockShipments.insert(0, Shipment(id: DateTime.now().millisecondsSinceEpoch.toString(), tripDate: DateTime.now(), status: 'pending'))),
        child: const Icon(Icons.add),
      ),
    );
  }
}
