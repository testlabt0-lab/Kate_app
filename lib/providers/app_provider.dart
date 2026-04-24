import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/farmer.dart';
import '../models/agent.dart';
import '../models/transporter.dart';
import '../models/qat_type.dart';
import '../models/shipment.dart';
import '../services/supabase_service.dart';

class AppProvider with ChangeNotifier {
  final SupabaseService _api = SupabaseService();
  List<Farmer> farmers = [];
  List<Agent> agents = [];
  List<Transporter> transporters = [];
  List<QatType> qatTypes = [];
  List<Shipment> shipments = [];

  bool isLoading = false;
  bool isManagerMode = true;

  void toggleManagerMode() {
    isManagerMode = !isManagerMode;
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners();

    await _loadFromCache();

    try {
      final serverFarmers = await _api.getFarmers();
      final serverAgents = await _api.getAgents();
      final serverTransporters = await _api.getTransporters();
      final serverQatTypes = await _api.getQatTypes();
      final serverShipments = await _api.getShipments();

      if (serverFarmers.isNotEmpty) farmers = serverFarmers;
      if (serverAgents.isNotEmpty) agents = serverAgents;
      if (serverTransporters.isNotEmpty) transporters = serverTransporters;
      if (serverQatTypes.isNotEmpty) qatTypes = serverQatTypes;
      if (serverShipments.isNotEmpty) shipments = serverShipments;

      _saveToCache();
    } catch (e) {
      debugPrint('Error fetching from server');
    }

    if (qatTypes.isEmpty) {
      qatTypes = [
        QatType(id: '1', name: 'بقمة', commissionAmount: 10, commissionPer: 'piece'),
        QatType(id: '2', name: 'قطل', commissionAmount: 15, commissionPer: 'pair'),
      ];
    }

    if (shipments.isEmpty) {
       // Temporary mock if db empty
       shipments = [Shipment(id: 'temp_1', tripDate: DateTime.now(), status: 'pending')];
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

  // Real Database Writes
  Future<bool> addFarmer(String name, String? phone) async {
    if (farmers.any((f) => f.name.trim().toLowerCase() == name.trim().toLowerCase())) return false;
    final newFarmer = Farmer(name: name.trim(), phone: phone);
    farmers.add(newFarmer);
    notifyListeners();
    final result = await _api.addFarmer(newFarmer);
    if (result != null) { farmers[farmers.indexOf(newFarmer)] = result; _saveToCache(); }
    return true;
  }

  Future<bool> addAgent(String name, String? phone) async {
    if (agents.any((a) => a.name.trim().toLowerCase() == name.trim().toLowerCase())) return false;
    final newAgent = Agent(name: name.trim(), phone: phone);
    agents.add(newAgent);
    notifyListeners();
    final result = await _api.addAgent(newAgent);
    if (result != null) { agents[agents.indexOf(newAgent)] = result; _saveToCache(); }
    return true;
  }

  Future<void> addTransporter(String name, String? phone, double commission) async {
    final newTransporter = Transporter(name: name, phone: phone, commissionRate: commission);
    transporters.add(newTransporter);
    notifyListeners();
    final result = await _api.addTransporter(newTransporter);
    if (result != null) transporters[transporters.indexOf(newTransporter)] = result;
  }

  Future<void> addQatType(String name, double commissionAmount, String commissionPer) async {
    final newQatType = QatType(name: name, commissionAmount: commissionAmount, commissionPer: commissionPer);
    qatTypes.add(newQatType);
    notifyListeners();
    final result = await _api.addQatType(newQatType);
    if (result != null) { qatTypes[qatTypes.indexOf(newQatType)] = result; _saveToCache(); }
  }

  Future<void> addShipment(DateTime date) async {
    final newShipment = Shipment(tripDate: date, status: 'pending');
    // Add temporary to UI
    final tempShipment = Shipment(id: DateTime.now().millisecondsSinceEpoch.toString(), tripDate: date, status: 'pending');
    shipments.insert(0, tempShipment);
    notifyListeners();

    // Save to DB
    final result = await _api.addShipment(newShipment);
    if (result != null) {
      shipments[shipments.indexOf(tempShipment)] = result;
      notifyListeners();
    }
  }

}
