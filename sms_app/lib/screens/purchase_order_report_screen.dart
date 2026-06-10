import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config.dart';

import '../enums/app_enums.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';

import '../screens/product_lookup_screen.dart';
import '../screens/supplier_lookup_screen.dart';

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PurchaseOrderReportScreen extends StatefulWidget {
  const PurchaseOrderReportScreen({super.key});

  @override
  State<PurchaseOrderReportScreen> createState() =>
      _PurchaseOrderReportScreenState();
}

class _PurchaseOrderReportScreenState
    extends State<PurchaseOrderReportScreen> {

  DateTime? _dateFrom;
  DateTime? _dateTo;

  Supplier? _selectedSupplier;
  Product? _selectedProduct;

  bool _isLoading = false;

  final dateFormat = DateFormat('dd MMM yyyy');

  Future<void> _pickDate({
    required bool isFrom,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  Future<void> _selectSupplier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SupplierLookupScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSupplier = result['supplier'];
      });
    }
  }

  Future<void> _selectProduct() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductLookupScreen(
          mode: ProductLookupMode.report,
        ),
      ),
    );

    if (result != null) {

      setState(() {
        _selectedProduct = result as Product;
      });
    }
  }

  Future<void> _generateReport() async {

    if (_dateFrom == null || _dateTo == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date range'),
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {

      final storage = const FlutterSecureStorage();

      final token = await storage.read(key: 'jwt');

      final queryParams = {
        'dateFrom': _dateFrom!.toIso8601String(),
        'dateTo': _dateTo!.toIso8601String(),
      };

      if (_selectedSupplier != null) {
        queryParams['supplierId'] =
            _selectedSupplier!.id.toString();
      }

      if (_selectedProduct != null) {
        queryParams['productId'] =
            _selectedProduct!.id.toString();
      }

      final uri = Uri.parse(
        '${Config().baseUrl}/purchaseOrder/report',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final result = jsonDecode(response.body);

      // =========================
      // HANDLE RESPONSE
      // =========================

      List<dynamic> data = [];

      // CASE 1:
      // API RETURNS:
      // {
      //   "success": true,
      //   "data": [...]
      // }

      if (result is Map<String, dynamic>) {

        if (result['success'] != true) {
          throw Exception(
            result['message'] ?? 'Unknown error',
          );
        }

        data = result['data'] ?? [];
      }

      // CASE 2:
      // API RETURNS DIRECT ARRAY:
      // [...]

      else if (result is List<dynamic>) {
        data = result;
      }

      debugPrint('========== PO REPORT DATA ==========');
      debugPrint(jsonEncode(data));
      debugPrint('====================================');

      if (data.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No data found'),
          ),
        );

        return;
      }

      // =========================
      // PDF GENERATION
      // =========================

      final pdf = pw.Document();

      final dateNow =
      DateFormat('dd MMM yyyy HH:mm')
          .format(DateTime.now());

      final currency =
      NumberFormat('#,##0.00', 'en_US');

      final List<List<String>> tableData = [];

      // IMPORTANT:
      // YOUR API IS ALREADY FLAT
      // EACH OBJECT = 1 REPORT ROW

      for (final po in data) {

        debugPrint(
          'PO OBJECT: ${jsonEncode(po)}',
        );

        final poNo =
            po['transNumber']?.toString() ?? '';

        final supplierCode =
            po['supplierCode']?.toString() ?? '';

        final supplierName =
            po['supplierName']?.toString() ?? '';

        final productCode =
            po['productCode']?.toString() ?? '';

        final productName =
            po['productName']?.toString() ?? '';

        final uom =
            po['uom']?.toString() ?? '';

        final qty =
            po['quantity']?.toString() ?? '0';

        final unitPrice = currency.format(
          double.tryParse(
            po['unitPrice'].toString(),
          ) ??
              0,
        );

        final subTotal = currency.format(
          double.tryParse(
            po['subTotal'].toString(),
          ) ??
              0,
        );

        final poDate =
        po['transDate'] != null
            ? DateFormat('dd MMM yyyy').format(
          DateTime.parse(
            po['transDate'].toString(),
          ),
        )
            : '';

        tableData.add([
          poNo,
          poDate,
          supplierCode,
          supplierName,
          productCode,
          productName,
          uom,
          qty,
          unitPrice,
          subTotal,
        ]);
      }

      debugPrint(
        'TOTAL TABLE ROWS: ${tableData.length}',
      );

      if (tableData.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No report rows found'),
          ),
        );

        return;
      }

      pdf.addPage(
        pw.MultiPage(

          margin: const pw.EdgeInsets.all(24),

          pageFormat: PdfPageFormat.a4.landscape,

          build: (context) => [

            // HEADER

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
                    'Purchase Order Report',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    'Generated on: $dateNow',
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    'Period: '
                        '${dateFormat.format(_dateFrom!)} '
                        '- '
                        '${dateFormat.format(_dateTo!)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // TABLE

            pw.TableHelper.fromTextArray(

              headers: [
                'PO Number',
                'PO Date',
                'Supplier Code',
                'Supplier Name',
                'Product Code',
                'Product Name',
                'UOM',
                'Qty',
                'Unit Price',
                'Sub Total',
              ],

              data: tableData,

              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),

              headerDecoration:
              const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),

              rowDecoration:
              const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.grey,
                    width: 0.3,
                  ),
                ),
              ),

              cellAlignment:
              pw.Alignment.centerLeft,

              cellStyle:
              const pw.TextStyle(
                fontSize: 9,
              ),

              border: pw.TableBorder.all(
                color: PdfColors.grey400,
                width: 0.3,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Divider(),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total rows: ${tableData.length}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey700,
                ),
              ),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();

      await Printing.layoutPdf(
        onLayout: (format) async =>
            Uint8List.fromList(pdfBytes),
      );

    } catch (e) {

      debugPrint('REPORT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );

    } finally {

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSelectorTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.search),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Order Report'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // DATE FROM

            Card(
              child: ListTile(
                title: const Text('Date From'),
                subtitle: Text(
                  _dateFrom == null
                      ? 'Select date'
                      : dateFormat.format(_dateFrom!),
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => _pickDate(isFrom: true),
              ),
            ),

            // DATE TO

            Card(
              child: ListTile(
                title: const Text('Date To'),
                subtitle: Text(
                  _dateTo == null
                      ? 'Select date'
                      : dateFormat.format(_dateTo!),
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => _pickDate(isFrom: false),
              ),
            ),

            const SizedBox(height: 12),

            // SUPPLIER

            _buildSelectorTile(
              title: 'Supplier',
              value: _selectedSupplier == null
                  ? 'All Suppliers'
                  : '${_selectedSupplier!.code} - ${_selectedSupplier!.name}',
              onTap: _selectSupplier,
            ),

            // PRODUCT

            _buildSelectorTile(
              title: 'Product',
              value: _selectedProduct == null
                  ? 'All Products'
                  : '${_selectedProduct!.code} - ${_selectedProduct!.name}',
              onTap: _selectProduct,
            ),

            const SizedBox(height: 20),

            // CLEAR FILTER

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                onPressed: () {
                  setState(() {
                    _selectedSupplier = null;
                    _selectedProduct = null;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // GENERATE REPORT

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.picture_as_pdf),
                label: const Text('Generate Report'),
                onPressed: _isLoading
                    ? null
                    : _generateReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}