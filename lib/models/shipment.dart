import 'farmer.dart';
import 'agent.dart';

class Shipment {
  final String? id;
  final DateTime tripDate;
  final String? transporterId;
  final String status;

  Shipment({this.id, required this.tripDate, this.transporterId, this.status = 'pending'});

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
      id: json['id'],
      tripDate: DateTime.parse(json['trip_date']),
      transporterId: json['transporter_id'],
      status: json['status'] ?? 'pending');

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'trip_date': tripDate.toIso8601String().split('T')[0],
    if (transporterId != null) 'transporter_id': transporterId,
    'status': status
  };
}

class ShipmentItem {
  final String? id;
  final String shipmentId;
  final String farmerId;
  final String agentId;
  final String qatTypeId;
  final String qatTypeName;
  final int quantity;
  final int boxesCount;
  final double? expectedPrice;
  final String status; // 'pending', 'delivered', 'lost'

  Farmer? farmer;
  Agent? agent;

  ShipmentItem({
    this.id,
    required this.shipmentId,
    required this.farmerId,
    required this.agentId,
    required this.qatTypeId,
    required this.qatTypeName,
    required this.quantity,
    required this.boxesCount,
    this.expectedPrice,
    this.status = 'pending',
    this.farmer,
    this.agent
  });

  factory ShipmentItem.fromJson(Map<String, dynamic> json) => ShipmentItem(
      id: json['id'],
      shipmentId: json['shipment_id'],
      farmerId: json['farmer_id'],
      agentId: json['agent_id'],
      qatTypeId: json['qat_type_id'] ?? '',
      qatTypeName: json['qat_type_name'] ?? 'غير محدد',
      quantity: json['quantity'] ?? 0,
      boxesCount: json['boxes_count'] ?? 1,
      expectedPrice: (json['expected_price'] as num?)?.toDouble(),
      status: json['status'] ?? 'pending',
      farmer: json['farmers'] != null ? Farmer.fromJson(json['farmers']) : null,
      agent: json['agents'] != null ? Agent.fromJson(json['agents']) : null);

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'shipment_id': shipmentId,
    'farmer_id': farmerId,
    'agent_id': agentId,
    'qat_type_id': qatTypeId,
    'qat_type_name': qatTypeName,
    'quantity': quantity,
    'boxes_count': boxesCount,
    if (expectedPrice != null) 'expected_price': expectedPrice,
    'status': status
  };
}
