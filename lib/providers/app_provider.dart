import 'package:flutter/foundation.dart';
import '../models/farmer.dart';
import '../models/agent.dart';
import '../models/transporter.dart';
import '../services/supabase_service.dart';

class AppProvider with ChangeNotifier {
  final SupabaseService _api = SupabaseService();
  List<Farmer> farmers = [];
  List<Agent> agents = [];
  List<Transporter> transporters = [];
  bool isLoading = false;

  Future<void> loadInitialData() async {
    isLoading = true; notifyListeners();
    farmers = await _api.getFarmers();
    agents = await _api.getAgents();
    transporters = await _api.getTransporters();
    isLoading = false; notifyListeners();
  }

  Future<void> addFarmer(String name, String? phone) async {
    final newFarmer = Farmer(name: name, phone: phone);
    final result = await _api.addFarmer(newFarmer);
    if (result != null) { farmers.add(result); notifyListeners(); }
    else { farmers.add(newFarmer); notifyListeners(); } // Mock fallback
  }

  Future<void> addAgent(String name, String? phone) async {
    final newAgent = Agent(name: name, phone: phone);
    final result = await _api.addAgent(newAgent);
    if (result != null) { agents.add(result); notifyListeners(); }
    else { agents.add(newAgent); notifyListeners(); } // Mock fallback
  }

  Future<void> addTransporter(String name, String? phone, double commission) async {
    final newTransporter = Transporter(name: name, phone: phone, commissionRate: commission);
    final result = await _api.addTransporter(newTransporter);
    if (result != null) { transporters.add(result); notifyListeners(); }
    else { transporters.add(newTransporter); notifyListeners(); } // Mock fallback
  }
}
