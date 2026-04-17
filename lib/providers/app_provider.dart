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

    // Fallback mock data if DB is empty/unconnected
    if (qatTypes.isEmpty) {
      qatTypes = [
        QatType(id: '1', name: 'بقمة', commissionAmount: 100, commissionPer: 'piece'),
        QatType(id: '2', name: 'قطل', commissionAmount: 150, commissionPer: 'pair'),
      ];
    }

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

  Future<void> addQatType(String name, double commissionAmount, String commissionPer) async {
    final newQatType = QatType(name: name, commissionAmount: commissionAmount, commissionPer: commissionPer);
    final result = await _api.addQatType(newQatType);
    if (result != null) { qatTypes.add(result); notifyListeners(); }
    else { qatTypes.add(QatType(id: DateTime.now().toString(), name: name, commissionAmount: commissionAmount, commissionPer: commissionPer)); notifyListeners(); } // Mock fallback
  }
}
