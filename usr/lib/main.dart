import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF Export Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample data to be displayed and exported
  final List<Map<String, dynamic>> _salesData = [
    {'id': 1, 'product': 'لابتوب', 'price': 4500.0, 'quantity': 2, 'total': 9000.0},
    {'id': 2, 'product': 'ماوس', 'price': 120.0, 'quantity': 5, 'total': 600.0},
    {'id': 3, 'product': 'شاشة', 'price': 1800.0, 'quantity': 3, 'total': 5400.0},
    {'id': 4, 'product': 'لوحة مفاتيح', 'price': 250.0, 'quantity': 4, 'total': 1000.0},
    {'id': 5, 'product': 'سماعات', 'price': 350.0, 'quantity': 10, 'total': 3500.0},
  ];

  // Column headers for the DataTable
  final List<String> _columns = ['الرقم', 'المنتج', 'السعر', 'الكمية', 'الإجمالي'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصدير البيانات إلى PDF'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTable(
              columns: _columns.map((col) => DataColumn(label: Text(col))).toList(),
              rows: _salesData.map((sale) {
                return DataRow(cells: [
                  DataCell(Text(sale['id'].toString())),
                  DataCell(Text(sale['product'].toString())),
                  DataCell(Text(sale['price'].toString())),
                  DataCell(Text(sale['quantity'].toString())),
                  DataCell(Text(sale['total'].toString())),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportToPdf,
        tooltip: 'تصدير PDF',
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }

  /// Generates and saves a PDF document with all the table data.
  Future<void> _exportToPdf() async {
    final doc = pw.Document();

    // Load an Arabic font
    final font = await PdfGoogleFonts.cairoRegular();

    // Headers for the PDF table, ensuring they match the data keys
    final headers = ['الإجمالي', 'الكمية', 'السعر', 'المنتج', 'الرقم'];

    // Map the sales data to a list of lists for the PDF table
    final data = _salesData.map((sale) {
      return [
        sale['total'].toString(),
        sale['quantity'].toString(),
        sale['price'].toString(),
        sale['product'],
        sale['id'].toString(),
      ];
    }).toList();

    doc.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('تقرير المبيعات', style: pw.TextStyle(fontSize: 24)),
                ),
                pw.Table.fromTextArray(
                  headers: headers,
                  data: data,
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerRight,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                ),
              ],
            ),
          );
        },
      ),
    );

    // Use the printing package to share or save the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
