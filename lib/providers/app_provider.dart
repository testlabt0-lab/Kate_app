import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/farmer.dart';
import '../models/agent.dart';
import '../models/transporter.dart';
import '../models/qat_type.dart';
import '../services/supabase_service.dart';

class AppProvider with ChangeNotifier {
  final SupabaseService _api = SupabaseService();
  List<Farmer> farmers = [];
  List<Agent> agents = [];
  List<Transporter> transporters = [];
  List<QatType> qatTypes = [];
  bool isLoading = false;

  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners();

    // Load from local cache first for super fast UX
    await _loadFromCache();

    // Fetch new updates from server in the background
    try {
      final serverFarmers = await _api.getFarmers();
      final serverAgents = await _api.getAgents();
      final serverTransporters = await _api.getTransporters();
      final serverQatTypes = await _api.getQatTypes();

      if (serverFarmers.isNotEmpty) farmers = serverFarmers;
      if (serverAgents.isNotEmpty) agents = serverAgents;
      if (serverTransporters.isNotEmpty) transporters = serverTransporters;
      if (serverQatTypes.isNotEmpty) qatTypes = serverQatTypes;

      _saveToCache();
    } catch (e) {
      debugPrint('Error fetching from server, falling back to cache only.');
    }

    if (qatTypes.isEmpty) {
      qatTypes = [
        QatType(id: '1', name: 'بقمة', commissionAmount: 100, commissionPer: 'piece'),
        QatType(id: '2', name: 'قطل', commissionAmount: 150, commissionPer: 'pair'),
      ];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('farmers_cache', jsonEncode(farmers.map((e) => e.toJson()).toList()));
    prefs.setString('agents_cache', jsonEncode(agents.map((e) => e.toJson()).toList()));
    prefs.setString('qat_types_cache', jsonEncode(qatTypes.map((e) => e.toJson()).toList()));
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final fCache = prefs.getString('farmers_cache');
    final aCache = prefs.getString('agents_cache');
    final qCache = prefs.getString('qat_types_cache');

    if (fCache != null) farmers = (jsonDecode(fCache) as List).map((e) => Farmer.fromJson(e)).toList();
    if (aCache != null) agents = (jsonDecode(aCache) as List).map((e) => Agent.fromJson(e)).toList();
    if (qCache != null) qatTypes = (jsonDecode(qCache) as List).map((e) => QatType.fromJson(e)).toList();

    if (farmers.isNotEmpty || agents.isNotEmpty) notifyListeners();
  }

  Future<void> addFarmer(String name, String? phone) async {
    final newFarmer = Farmer(name: name, phone: phone);
    farmers.add(newFarmer); // Optimistic UI
    notifyListeners();
    final result = await _api.addFarmer(newFarmer);
    if (result != null) {
      farmers[farmers.indexOf(newFarmer)] = result;
      _saveToCache();
    }
  }

  Future<void> addAgent(String name, String? phone) async {
    final newAgent = Agent(name: name, phone: phone);
    agents.add(newAgent); // Optimistic UI
    notifyListeners();
    final result = await _api.addAgent(newAgent);
    if (result != null) {
      agents[agents.indexOf(newAgent)] = result;
      _saveToCache();
    }
  }

  Future<void> addTransporter(String name, String? phone, double commission) async {
    final newTransporter = Transporter(name: name, phone: phone, commissionRate: commission);
    transporters.add(newTransporter); // Optimistic UI
    notifyListeners();
    final result = await _api.addTransporter(newTransporter);
    if (result != null) {
      transporters[transporters.indexOf(newTransporter)] = result;
    }
  }

  Future<void> addQatType(String name, double commissionAmount, String commissionPer) async {
    final newQatType = QatType(name: name, commissionAmount: commissionAmount, commissionPer: commissionPer);
    qatTypes.add(newQatType); // Optimistic UI
    notifyListeners();
    final result = await _api.addQatType(newQatType);
    if (result != null) {
      qatTypes[qatTypes.indexOf(newQatType)] = result;
      _saveToCache();
    }
  }
}
