import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/farmer.dart';

class PdfFarmerReportService {
  static Future<void> generateAndPrintFarmerReport({
    required Farmer farmer,
  }) async {
    final pdf = pw.Document();
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
                child: pw.Text('كشف حساب مزارع', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('تاريخ الطباعة: ${DateTime.now().toIso8601String().split('T')[0]}'),
                  pw.Text('المزارع: ${farmer.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text('الوضع المالي:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('إجمالي الديون المتبقية (السوق):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                    pw.Text('${farmer.totalDebt} ريال', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                  ]
                )
              ),
              pw.SizedBox(height: 30),
              pw.Text('تم إصدار هذا الكشف عبر نظام الشداد الذكي لإدارة القات', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
