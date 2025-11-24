import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../config.dart';


class ProductReportScreen extends StatefulWidget {
  const ProductReportScreen({super.key});

  @override
  State<ProductReportScreen> createState() => _ProductReportScreenState();
}

class _ProductReportScreenState extends State<ProductReportScreen> {
  bool _isLoading = false;
  List<dynamic> _products = [];

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);

    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'jwt');


      if (token == null) {
        throw Exception("Not authenticated");
      }

      final response = await http.get(
        Uri.parse('${Config().baseUrl}/product?page=1&pageSize=9999'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final api = jsonDecode(response.body);
        if (api['success'] == true) {
          setState(() => _products = api['data']);
        } else {
          throw Exception(api['message'] ?? 'API Error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _generatePdf() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to print')),
      );
      return;
    }

    final pdf = pw.Document();
    final dateNow = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());
    final currency = NumberFormat('#,##0.00', 'en_US');

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'PT. SMS System',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Product Report',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Generated on: $dateNow',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Product Name', 'Code', 'Quantity', 'Price (Rp)'],
            data: _products.map((p) {
              final name = p['name'] ?? '';
              final code = p['code'] ?? '';
              final qty = p['quantity'] ?? 0;
              final price = currency.format(p['price'] ?? 0);
              return [name, code, qty.toString(), price];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.blueGrey800),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey, width: 0.3),
              ),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.3),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total products: ${_products.length}',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700),
            ),
          ),
        ],
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
    );
  }

  Future<void> _exportToExcel() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Product Report'];

    // Header row
    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E3A8A'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Create header
    final headers = ['Product Name', 'Code', 'Quantity', 'Price (Rp)'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (int row = 0; row < _products.length; row++) {
      final p = _products[row];
      final values = [
        p['name'] ?? '',
        p['code'] ?? '',
        p['quantity'] ?? 0,
        p['price'] ?? 0,
      ];
      for (int col = 0; col < values.length; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1))
            .value = values[col] is String
            ? TextCellValue(values[col])
            : DoubleCellValue(double.tryParse(values[col].toString()) ?? 0);
      }
    }

    // Save file
    final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Product_Report_$now.xlsx';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file saved: $filePath')),
        );
      }

      // await OpenFilex.open(filePath);
      debugPrint('File saved at: $filePath');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: _generatePdf,
          ),
          IconButton(
            icon: const Icon(Icons.table_view),
            tooltip: 'Export as Excel',
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('No product data available.'))
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            elevation: 1,
            child: ListTile(
              title: Text(
                p['Name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Code: ${p['code'] ?? ''}'),
              trailing: Text(
                'Qty: ${p['quantity'] ?? 0}\nRp ${p['price'] ?? 0}',
                textAlign: TextAlign.right,
              ),
            ),
          );
        },
      ),
    );
  }
}
