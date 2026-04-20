import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/agent.dart';
import '../services/pdf_invoice_service.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});
  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  Agent? selectedAgent;
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('التصفيات المالية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Agent>(decoration: const InputDecoration(labelText: 'اختر الوكيل'), items: provider.agents.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(), onChanged: (v) => setState(() => selectedAgent = v)),
            const SizedBox(height: 16),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'مبلغ الحوالة'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedAgent != null && amountController.text.isNotEmpty) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('تقرير التصفية المبدئي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('الحوالة: ${amountController.text}'),
                          const Expanded(child: Center(child: Text('هنا تظهر مقاصة ديون المزارعين'))),
                          ElevatedButton(onPressed: () { Navigator.pop(context); PdfInvoiceService.generateAndPrintSettlementInvoice(agent: selectedAgent!, totalAmount: double.parse(amountController.text), transporterFee: 5000, agentCommission: 10000, shaddadCommission: 8000, farmersTotalNet: double.parse(amountController.text) - 23000); }, child: const Text('طباعة الفاتورة (PDF) واعتماد')),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: const Text('إجراء المقاصة'),
            ),
          ],
        ),
      ),
    );
  }
}
