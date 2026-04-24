import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/farmer.dart';
import '../models/agent.dart';
import '../models/transporter.dart';
import '../models/qat_type.dart';
import '../models/payment.dart';
import '../models/daily_price.dart';
import '../models/shipment.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Farmers
  Future<List<Farmer>> getFarmers() async {
    try {
      final response = await _client.from('farmers').select().order('name');
      return (response as List).map((e) => Farmer.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<Farmer?> addFarmer(Farmer farmer) async {
    try {
      final response = await _client.from('farmers').insert(farmer.toJson()).select().single();
      return Farmer.fromJson(response);
    } catch (e) { return null; }
  }

  // Agents
  Future<List<Agent>> getAgents() async {
    try {
      final response = await _client.from('agents').select().order('name');
      return (response as List).map((e) => Agent.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<Agent?> addAgent(Agent agent) async {
    try {
      final response = await _client.from('agents').insert(agent.toJson()).select().single();
      return Agent.fromJson(response);
    } catch (e) { return null; }
  }

  // Transporters
  Future<List<Transporter>> getTransporters() async {
    try {
      final response = await _client.from('transporters').select().order('name');
      return (response as List).map((e) => Transporter.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<Transporter?> addTransporter(Transporter transporter) async {
    try {
      final response = await _client.from('transporters').insert(transporter.toJson()).select().single();
      return Transporter.fromJson(response);
    } catch (e) { return null; }
  }

  // Qat Types
  Future<List<QatType>> getQatTypes() async {
    try {
      final response = await _client.from('qat_types').select().order('name');
      return (response as List).map((e) => QatType.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<QatType?> addQatType(QatType qatType) async {
    try {
      final response = await _client.from('qat_types').insert(qatType.toJson()).select().single();
      return QatType.fromJson(response);
    } catch (e) { return null; }
  }

  // Shipments (Trips)
  Future<List<Shipment>> getShipments() async {
    try {
      final response = await _client.from('shipments').select().order('trip_date', ascending: false);
      return (response as List).map((e) => Shipment.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<Shipment?> addShipment(Shipment shipment) async {
    try {
      // Remove ID before inserting if it's not a real UUID from server yet
      var data = shipment.toJson();
      data.remove('id');
      final response = await _client.from('shipments').insert(data).select().single();
      return Shipment.fromJson(response);
    } catch (e) { return null; }
  }

  // Shipment Items (Adlas)
  Future<List<ShipmentItem>> getShipmentItems(String shipmentId) async {
    try {
      final response = await _client
          .from('shipment_items')
          .select('*, farmers(*), agents(*)')
          .eq('shipment_id', shipmentId);
      return (response as List).map((e) => ShipmentItem.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<ShipmentItem?> addShipmentItem(ShipmentItem item) async {
    try {
      var data = item.toJson();
      data.remove('id');
      final response = await _client.from('shipment_items').insert(data).select().single();
      return ShipmentItem.fromJson(response);
    } catch (e) { return null; }
  }

  Future<void> updateShipmentItemStatus(String itemId, String status) async {
    try {
      await _client.from('shipment_items').update({'status': status}).eq('id', itemId);
    } catch (e) {}
  }

  Future<void> deleteShipmentItem(String itemId) async {
    try {
      await _client.from('shipment_items').delete().eq('id', itemId);
    } catch (e) {}
  }

  // Others
  Future<Payment?> addPayment(Payment payment) async {
    try {
      final response = await _client.from('payments').insert(payment.toJson()).select().single();
      return Payment.fromJson(response);
    } catch (e) { return null; }
  }

  Future<DailyPrice?> addDailyPrice(DailyPrice dailyPrice) async {
    try {
      final response = await _client.from('daily_prices')
          .upsert(dailyPrice.toJson(), onConflict: 'agent_id, qat_type_id, price_date')
          .select()
          .single();
      return DailyPrice.fromJson(response);
    } catch (e) { return null; }
  }
}
