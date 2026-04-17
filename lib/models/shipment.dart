import 'farmer.dart';
import 'agent.dart';
class Shipment {
  final String? id;
  final DateTime tripDate;
  final String? transporterId;
  final String status;
  Shipment({this.id, required this.tripDate, this.transporterId, this.status = 'pending'});
  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
      id: json['id'], tripDate: DateTime.parse(json['trip_date']), transporterId: json['transporter_id'], status: json['status'] ?? 'pending');
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'trip_date': tripDate.toIso8601String().split('T')[0], if (transporterId != null) 'transporter_id': transporterId, 'status': status};
}
class ShipmentItem {
  final String? id;
  final String shipmentId;
  final String farmerId;
  final String agentId;
  final String qatType;
  final int quantity;
  final double? expectedPrice;
  Farmer? farmer;
  Agent? agent;
  ShipmentItem({this.id, required this.shipmentId, required this.farmerId, required this.agentId, required this.qatType, required this.quantity, this.expectedPrice, this.farmer, this.agent});
  factory ShipmentItem.fromJson(Map<String, dynamic> json) => ShipmentItem(
      id: json['id'], shipmentId: json['shipment_id'], farmerId: json['farmer_id'], agentId: json['agent_id'], qatType: json['qat_type'], quantity: json['quantity'], expectedPrice: (json['expected_price'] as num?)?.toDouble(),
      farmer: json['farmers'] != null ? Farmer.fromJson(json['farmers']) : null, agent: json['agents'] != null ? Agent.fromJson(json['agents']) : null);
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'shipment_id': shipmentId, 'farmer_id': farmerId, 'agent_id': agentId, 'qat_type': qatType, 'quantity': quantity, if (expectedPrice != null) 'expected_price': expectedPrice};
}
