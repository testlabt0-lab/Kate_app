import 'package:flutter/foundation.dart';
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
    isLoading = true; notifyListeners();
    farmers = await _api.getFarmers();
    agents = await _api.getAgents();
    transporters = await _api.getTransporters();
    qatTypes = await _api.getQatTypes();
    isLoading = false; notifyListeners();
  }

  Future<void> addFarmer(String name, String? phone) async {
    final newFarmer = Farmer(name: name, phone: phone);
    final result = await _api.addFarmer(newFarmer);
    if (result != null) { farmers.add(result); notifyListeners(); }
  }

  Future<void> addAgent(String name, String? phone) async {
    final newAgent = Agent(name: name, phone: phone);
    final result = await _api.addAgent(newAgent);
    if (result != null) { agents.add(result); notifyListeners(); }
  }

  Future<void> addTransporter(String name, String? phone, double commission) async {
    final newTransporter = Transporter(name: name, phone: phone, commissionRate: commission);
    final result = await _api.addTransporter(newTransporter);
    if (result != null) { transporters.add(result); notifyListeners(); }
  }

  Future<void> addQatType(String name, double commissionAmount, String commissionPer) async {
    final newQatType = QatType(name: name, commissionAmount: commissionAmount, commissionPer: commissionPer);
    final result = await _api.addQatType(newQatType);
    if (result != null) { qatTypes.add(result); notifyListeners(); }
  }
}
