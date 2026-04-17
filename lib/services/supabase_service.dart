import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/farmer.dart';
import '../models/agent.dart';
import '../models/transporter.dart';
import '../models/qat_type.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

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
}
