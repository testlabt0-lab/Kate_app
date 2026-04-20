import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/agent.dart';

class PdfInvoiceService {
  static Future<void> generateAndPrintSettlementInvoice({
    required Agent agent,
    required double totalAmount,
    required double transporterFee,
    required double agentCommission,
    required double shaddadCommission,
    required double farmersTotalNet,
  }) async {
    final pdf = pw.Document();

    // Ensure we have an arabic font available via Printing
    final font = await PdfGoogleFonts.cairoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('فاتورة تصفية مالية (الشداد)', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('التاريخ: ${DateTime.now().toIso8601String().split('T')[0]}'),
                  pw.Text('الوكيل: ${agent.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              _buildInvoiceRow('إجمالي مبلغ الحوالة', totalAmount),
              pw.SizedBox(height: 10),
              pw.Text('الخصميات:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              _buildInvoiceRow('- عمولة الوكيل', agentCommission, color: PdfColors.red),
              _buildInvoiceRow('- أجور النقل', transporterFee, color: PdfColors.red),
              _buildInvoiceRow('- أجرة الشداد', shaddadCommission, color: PdfColors.red),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildInvoiceRow('صافي حساب المزارعين (للتوزيع)', farmersTotalNet, isBold: true, color: PdfColors.green),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text('تم إصدار الفاتورة من نظام الشداد الذكي', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildInvoiceRow(String title, double amount, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
          pw.Text('${amount.toStringAsFixed(2)} ريال', style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
