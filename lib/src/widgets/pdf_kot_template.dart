import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:shopos/src/models/KotModel.dart';

import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/user.dart';

class PdfKotUI {
  static Future<void> generate57mmKot({
    String tableNo="",
    required User user,
    required List<Map<String, dynamic>> order,
    required List<String> headers,
    required DateTime date,
    required String invoiceNum,
  }) async {
    final pdf = pw.Document();
    final roll57 = PdfPageFormat.roll57;

    final font = await rootBundle.load('assets/OpenSans-Regular.ttf');
    final ttf = await Font.ttf(font);
    List<String>? addressRows() => user.address
        ?.toString()
        .split(',')
        .map((e) =>
    '${e.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll(',', '').replaceAll('locality:', '').replaceAll('city:', '').replaceAll('state:', '').replaceAll('country:', '')}')
        .toList();
    // String dateFormat() => DateFormat('MMM d, y hh:mm:ss a').format(date);
    String dateFormat() {
      final dateFormatter = DateFormat('MMM d, y');
      final timeFormatter = DateFormat('hh:mm:ss a');

      final formattedDate = dateFormatter.format(date);
      final formattedTime = timeFormatter.format(date);

      return '$formattedDate\n$formattedTime';
    }
    List<pw.TableRow> itemRows() => List.generate(
          (order ?? []).length,
          (index) {
            final orderItem = order[index];

            return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: EdgeInsets.all(1),
                    child: pw.Text('${orderItem['name']}',style: TextStyle(font: ttf, fontSize: 12),),
                  ),
                  pw.Padding(
                      padding: EdgeInsets.all(1),
                      child: pw.Text('${orderItem['qty']}',style: TextStyle(font: ttf, fontSize: 12)))

                ]);
          },
        );

    pdf.addPage(pw.Page(
      pageFormat: roll57,
      build: (context) {
        return pw.Container(
          margin: pw.EdgeInsets.all(10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('KOT', style: pw.TextStyle(fontSize: 15, font: ttf, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),

              pw.Text(
                '${user.businessName}',
                style: pw.TextStyle(
                    font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),

              // Phone number
              // pw.Text(
              //   '${user.phoneNumber}',
              //   style: pw.TextStyle(fontSize: 10, font: ttf),
              // ),
              pw.SizedBox(height: 20),
              pw.Text('${dateFormat()}',
                  style: pw.TextStyle(fontSize: 12, font: ttf, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Table No: $tableNo', style: pw.TextStyle(fontSize: 12, font: ttf)),

              pw.SizedBox(height: 10),
              // pw.Text('Order Summary', style: pw.TextStyle(fontSize: 12, font: ttf)),
              pw.SizedBox(height: 5),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(headers[0],
                        style: TextStyle(font: ttf, fontSize: 12)),
                    pw.Text(
                      headers[1],
                      style: TextStyle(font: ttf, fontSize: 12),
                    ),
                  ]),
              pw.Table(
                  children: itemRows()),
              if(itemRows().length <= 3)
                pw.SizedBox(height: 30)
            ],
          ),
        );
      },
    ));

    // Get the directory for saving the PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/KOT.pdf';
    final file = File(filePath);

    // Write the PDF to a file
    await file.writeAsBytes(await pdf.save());

    // final bytes = File(file.path).readAsBytesSync();

    // return bytes;

    // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdf.save());

    try {
      print('run');
      print(file.path);
      print(file.absolute.path);
      // OpenFile.open(file.path);
      OpenAppFile.open(file.path, mimeType: 'application/pdf');
      print('done');
    } catch (e) {
      print(e);
    }
  }

  static Future<void> generate80mmKot({
     String tableNo="",
    required User user,
    required List<Map<String, dynamic>> order,
    required List<String> headers,
    required DateTime date,
    required String invoiceNum,

  }) async {
    final pdf = pw.Document();
    final roll80 = PdfPageFormat.roll80;

    final font = await rootBundle.load('assets/OpenSans-Regular.ttf');
    final ttf = await Font.ttf(font);

    List<String>? addressRows() => user.address
        ?.toString()
        .split(',')
        .map((e) =>
    '${e.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll(',', '').replaceAll('locality:', '').replaceAll('city:', '').replaceAll('state:', '').replaceAll('country:', '')}')
        .toList();
    // String dateFormat() => DateFormat('MMM d, y hh:mm:ss a').format(date);
    String dateFormat() {
      final dateFormatter = DateFormat('MMM d, y');
      final timeFormatter = DateFormat('hh:mm:ss a');

      final formattedDate = dateFormatter.format(date);
      final formattedTime = timeFormatter.format(date);

      return '$formattedDate\n$formattedTime';
    }

    List<pw.TableRow> itemRows() => List.generate(
          (order ?? []).length,
          (index) {
            final orderItem = order[index];

            return pw.TableRow(
                children: [
                  pw.Padding(
                      padding: EdgeInsets.all(1),
                      child: pw.Text('${orderItem['name']}',style: TextStyle(font: ttf, fontSize: 12),),
                  ),
                  pw.Padding(
                      padding: EdgeInsets.all(1),
                      child: pw.Text('${orderItem['qty']}',style: TextStyle(font: ttf, fontSize: 12)))

            ]);
          },
        );

    pdf.addPage(pw.Page(
      pageFormat: roll80,
      build: (context) {
        return pw.Container(
          margin: pw.EdgeInsets.all(0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('KOT', style: pw.TextStyle(fontSize: 15, font: ttf, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),

              pw.Text(
                '${user.businessName}',
                style: pw.TextStyle(
                    font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              //
              // // Phone number
              // pw.Text(
              //   '${user.phoneNumber}',
              //   style: pw.TextStyle(fontSize: 10, font: ttf),
              // ),
              pw.SizedBox(height: 20),
              pw.Text('${dateFormat()}',
                  style: pw.TextStyle(fontSize: 12, font: ttf, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Table No: $tableNo', style: pw.TextStyle(fontSize: 12, font: ttf)),
              pw.SizedBox(height: 10),
              // pw.Text('Order Summary', style: pw.TextStyle(fontSize: 12, font: ttf)),
              pw.SizedBox(height: 5),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(headers[0],
                        style: TextStyle(font: ttf, fontSize: 12)),
                    pw.Text(
                      headers[1],
                      style: TextStyle(font: ttf, fontSize: 12),
                    ),
                  ]),
              pw.SizedBox(height: 10),
              pw.Table(children: itemRows()),
              if(itemRows().length <= 3)
              pw.SizedBox(height: 30)
            ],
          ),
        );
      },
    ));

    // Get the directory for saving the PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/KOT.pdf';
    final file = File(filePath);

    // Write the PDF to a file
    await file.writeAsBytes(await pdf.save());

    // final bytes = File(file.path).readAsBytesSync();

    // return bytes;

    // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdf.save());

    try {
      print('run');
      print(file.path);
      print(file.absolute.path);
      // OpenFile.open(file.path);
      OpenAppFile.open(file.path, mimeType: 'application/pdf');
      print('done');
    } catch (e) {
      print(e);
    }
  }
}
