import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
// import 'package:number_to_words/number_to_words.dart';
import '../utils/terbilang.dart';

class SalesOrderItemPrint {
  final String code;
  final String name;
  final int qty;
  final String unit;
  final double price;

  SalesOrderItemPrint({
    required this.code,
    required this.name,
    required this.qty,
    required this.unit,
    required this.price,
  });

  double get subtotal => qty * price;
}

Future<Uint8List> generateSalesOrderInvoice({
  required String customerName,
  required String transNumber,
  required DateTime transDate,
  required DateTime dueDate,
  required List<SalesOrderItemPrint> items,
}) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  final currency = NumberFormat("#,##0", "id_ID");

  double grandTotal = items.fold(0, (sum, item) => sum + item.subtotal);
  final totalInt = grandTotal.round();
  final totalInWords = '${terbilang(totalInt)} rupiah';

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        // Header
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("ONE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text("Pusat Tanah Abang Blok A/C"),
                pw.Text("Jl. S. Parman No. 777"),
                pw.Text("Telp. (021) 335599"),
                pw.SizedBox(height: 10),
                pw.Text("Kepada Yth:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  width: 180,
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
                  child: pw.Text(customerName, style: pw.TextStyle(fontSize: 12)),
                ),
              ],
            ),
            pw.Container(
              width: 200,
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Nomor : $transNumber'),
                  pw.Text('Tanggal : ${dateFormat.format(transDate)}'),
                  pw.Text('Jatuh Tempo : ${dateFormat.format(dueDate)}'),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Text("FAKTUR PENJUALAN",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        ),
        pw.SizedBox(height: 10),

        // ✅ UPDATED: use TableHelper.fromTextArray
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
          child: pw.TableHelper.fromTextArray(
            headers: ['No', 'Kode Barang', 'Nama Barang', 'Jumlah', 'Harga Satuan', 'Sub Total'],
            data: [
              for (int i = 0; i < items.length; i++)
                [
                  (i + 1).toString(),
                  items[i].code,
                  items[i].name,
                  '${items[i].qty} ${items[i].unit}',
                  'Rp ${currency.format(items[i].price)}',
                  'Rp ${currency.format(items[i].subtotal)}',
                ]
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            border: pw.TableBorder.symmetric(
              inside: pw.BorderSide(color: PdfColors.grey),
              outside: pw.BorderSide(color: PdfColors.black),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(4),
            columnWidths: {
              0: const pw.FixedColumnWidth(20),
              1: const pw.FixedColumnWidth(70),
              2: const pw.FlexColumnWidth(),
              3: const pw.FixedColumnWidth(55),
              4: const pw.FixedColumnWidth(75),
              5: const pw.FixedColumnWidth(75),
            },
          ),
        ),

        pw.SizedBox(height: 8),

        // Total
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
              width: 200,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rp ${currency.format(grandTotal)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 6),
        pw.Text('Terbilang: ${totalInWords.toUpperCase()}'),
        pw.SizedBox(height: 20),

        // Footer
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Pembayaran ditransfer ke Rek:",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("BCA 874234567"),
                    pw.Text("a/n Hiso Aje"),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "Note: Giro a/n Hiso Aje dianggap lunas kalau dana sudah efektif.",
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Column(
              children: [
                pw.Text("Hormat Kami,"),
                pw.SizedBox(height: 40),
                pw.Container(
                  width: 120,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: PdfColors.black)),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text("Tanda tangan / Nama"),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  return pdf.save();
}
