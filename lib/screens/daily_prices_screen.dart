import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../models/agent.dart';
import '../models/qat_type.dart';
import '../models/daily_price.dart';

class DailyPricesScreen extends StatefulWidget {
  const DailyPricesScreen({super.key});

  @override
  State<DailyPricesScreen> createState() => _DailyPricesScreenState();
}

class _DailyPricesScreenState extends State<DailyPricesScreen> {
  Agent? selectedAgent;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الأسعار اليومية والرسائل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('سجل أسعار بيع الوكلاء لهذا اليوم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            DropdownButtonFormField<Agent>(
              decoration: const InputDecoration(labelText: 'اختر الوكيل', border: OutlineInputBorder()),
              items: provider.agents.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
              onChanged: (v) => setState(() => selectedAgent = v),
            ),
            const SizedBox(height: 16),
            if (selectedAgent != null)
              Expanded(
                child: ListView.builder(
                  itemCount: provider.qatTypes.length,
                  itemBuilder: (context, index) {
                    final type = provider.qatTypes[index];
                    final controller = TextEditingController();

                    return Card(
                      child: ListTile(
                        title: Text('سعر بيع: ${type.name}'),
                        subtitle: Text('العمولة المحددة سلفاً: ${type.commissionAmount} ريال'),
                        trailing: SizedBox(
                          width: 100,
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'السعر (ريال)'),
                            onSubmitted: (val) {
                              // Save to daily_prices logic here
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ سعر ${type.name}')));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () => _sendSmsToFarmers(context),
            icon: const Icon(Icons.sms),
            label: const Text('إرسال SMS بالأسعار للمزارعين'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _sendSmsToFarmers(BuildContext context) async {
    // Generate a bulk SMS string or open SMS app
    String message = "مزارعنا الكريم، تم بيع قاتكم اليوم بالأسعار التالية:\n- بقمة: 5000 ريال\n- قطل: 3000 ريال\nلمعرفة صافي الحساب يرجى مراجعة الشداد.";

    final Uri smsUri = Uri.parse("sms:?body=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح تطبيق الرسائل النصية.')));
    }
  }
}
