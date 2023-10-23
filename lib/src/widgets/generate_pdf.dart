import 'dart:io';
import 'package:flutter/services.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/checkout.dart';

Future<void> generatePdf({
  required String fileName,
  required String date,
  required String companyName,
  required OrderInput orderInput,
  required User user,
  String? totalPrice,
  required String gstType,
  required OrderType orderType,
  String? subtotal,
  String? gstTotal,
  String? invoiceNum,
}) async {
  final pdf = pw.Document();

  List<String> address = user.address.toString().split(',');

  final List<pw.Row> tableRows = [];

  for (var data in orderInput.orderItems!) {
    double basePrice = 0.0;
    String gstrate = '';

    if (gstType == 'WithoutGST') {
      if (orderType == OrderType.sale) {
        basePrice = data.product!.sellingPrice!;
      } else {
        basePrice = data.product!.purchasePrice.toDouble();
      }
    } else {
      if (orderType == OrderType.sale) {
        if (data.product!.gstRate == "null") {
          basePrice = data.product!.sellingPrice!.toDouble();
          gstrate = "NA";
        } else {
          basePrice = double.parse(data.product!.baseSellingPriceGst!);
          gstrate = data.product!.gstRate!;
        }
      } else {
        if (data.product!.gstRate == "null" &&
            data.product!.purchasePrice != 0) {
          basePrice = data.product!.purchasePrice.toDouble();
          gstrate = "NA";
        } else if (data.product!.gstRate == "null" &&
            data.product!.purchasePrice == 0) {
          basePrice = 0;
          gstrate = "NA";
        } else if (data.product!.gstRate != "null" &&
            data.product!.purchasePrice != 0) {
          basePrice = double.parse(data.product!.basePurchasePriceGst!);
          gstrate = data.product!.gstRate!;
        } else {
          basePrice = 0;
          gstrate = data.product!.gstRate!;
        }
      }
    }
    PdfColor pdfColor = PdfColor.fromInt(1);
      PdfColor pdfColor2 = PdfColor.fromInt(0xFF808080);
    final tableRow = pw.Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        pw.Container(
        
          width: 200,
          child: pw.Text(
            (data.product!.name! + "                              ")
                .substring(0, 30),
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: 20,
        
          child: pw.Text(data.quantity.toString(), textAlign: TextAlign.center),
        ),
        SizedBox(width: 30),
        Container(
          width: 70,
          child: pw.Text('$basePrice')),
             SizedBox(width: 20),
        gstType == 'WithoutGST'
            ? Container()
            : (data.product!.gstRate == 'null'
                ? pw.Text('NA')
                : Container(
                  width: 50,
                  child: pw.Text(data.product!.saleigst!)
                )),
                   SizedBox(width: 20),
        orderType == OrderType.sale
            ? Container(
              width: 50,
              child: pw.Text('${(data.quantity) * (data.product?.sellingPrice ?? 0)}')
            ) 
            : Container(
              width: 50,
              child:pw.Text(
                '${(data.quantity) * (data.product?.purchasePrice ?? 0)}'), ) 
      ],
    );
    tableRows.add(tableRow);
  }

  final pw.Column table = pw.Column(
    children: tableRows,
  );

  final font = await rootBundle.load('assets/OpenSans-Regular.ttf');
  final ttf = await Font.ttf(font);
   PdfColor pdfColor = PdfColor.fromInt(1);
    PdfColor pdfColor2 = PdfColor.fromInt(0xFF808080);
  pdf.addPage(
    pw.Page(build: (pw.Context context) {
      return pw.Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Invoice($invoiceNum)', style: TextStyle(font: ttf)),
          pw.Text('Date: ${date.substring(0, 10)}',
              style: TextStyle(font: ttf)),
        ]),
        pw.Divider(
          height: 10,
        ),
        pw.SizedBox(height: 10),
        pw.Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            pw.Text('From: ',
                style: TextStyle(
                  font: ttf,
                )),
            pw.SizedBox(height: 10),
            pw.Text('$companyName',
                style: TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            pw.Text('${address[0].replaceAll('{', '')}',
                style: TextStyle(font: ttf)),
            pw.Text('${address[1].replaceAll(' ', '')}',
                style: TextStyle(font: ttf)),
            pw.Text('${address[2].replaceAll(' ', '')}',
                style: TextStyle(font: ttf)),
            pw.Text('${address[3].replaceAll('}', '').replaceAll(' ', '')}',
                style: TextStyle(font: ttf)),
            pw.Text('Email: ${user.email}', style: TextStyle(font: ttf)),
            pw.Text('Phone: ${user.phoneNumber}', style: TextStyle(font: ttf)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            pw.Text('Billed to: ',
                style: TextStyle(
                  font: ttf,
                )),
            pw.SizedBox(height: 10),
            pw.Text('Business Name:' + user.businessName.toString(),
                style: TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
            pw.Text('Address:' + address[1], style: TextStyle(font: ttf)),
            pw.Text('GSTIN:' + user.GstIN.toString(),
                style: TextStyle(font: ttf)),
          ])
        ]),

        pw.SizedBox(height: 20),
             pw.Divider(thickness: 1,color: pdfColor2),
        pw.Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          pw.Container(
            width: 200,
            child: pw.Text('Name'),
          ),
          SizedBox(width: 20),
          pw.Container(
            width: 30,
            child: pw.Text('Qty'),
          ),
          SizedBox(width: 20),
            pw.Container(
              
            width: 70,
            child:  pw.Text('Rate/Unit'),
          ),
         
          SizedBox(width: 20),
          gstType == 'WithoutGST' ? Container() :Container(
            width: 50,
            child:pw.Text('GST/Unit')) ,
          SizedBox(width: 20),
          Container(width: 50,child:  pw.Text('Amount') )
        
        ]),
        pw.Divider(thickness: 1,color: pdfColor2),

        // pw.Table(children: [
        //   pw.TableRow(children: [
        //     pw.Text('Name', style: TextStyle(font: ttf)),
        //     pw.Text('Qty', style: TextStyle(font: ttf)),
        //     pw.Text('Rate/Unit', style: TextStyle(font: ttf)),
        //     pw.Text('GST/Unit', style: TextStyle(font: ttf)),
        //     pw.Text('Amount', style: TextStyle(font: ttf)),
        //   ]),

        // ]),

        table,

        // table,

        pw.SizedBox(height: 20),

        subtotal == null || subtotal == ''
            ? Container()
            : pw.Row(children: [
                pw.Text('Sub Total: ',
                    style:
                        TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                pw.Text('$subtotal', style: TextStyle(font: ttf)),
                pw.SizedBox(width: 50)
              ]),

        gstTotal == null || gstTotal == ''
            ? Container()
            : pw.Row(children: [
                pw.Text('GST Total: ',
                    style:
                        TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                pw.Text('$gstTotal', style: TextStyle(font: ttf)),
                
              ]),

        pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          pw.Text('Sub Total:       ',
              style: TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
          subtotal == null || subtotal == ''
              ? Container(
                width: 50,
                child: pw.Text('0.0') )
              : Container(
                width: 50,
                child: pw.Text(subtotal.toString(), style: TextStyle(font: ttf)) )
        ]),

        pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          pw.Text('GST Total:       ',
              style: TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
         gstTotal == null || gstTotal == ''
              ? Container(
                width: 50,
                child: pw.Text('0.0') )
              :Container(
                width: 50,
                child: pw.Text(gstTotal.toString(), style: TextStyle(font: ttf)) )
        ]),

        pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          pw.Text('Net Total:       ',
              style: TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
          subtotal == null || subtotal == ''
              ? Container(
                width: 50,
                child: pw.Text('0.0') )
              : Container(
                width: 50,
                child: pw.Text(subtotal.toString(), style: TextStyle(font: ttf)) )
        ]),

        pw.SizedBox(height: 10),
        pw.Divider(height: 10),

        pw.SizedBox(height: 20),
        pw.Center(
            child: pw.Text('Thank you for your business',
                style: TextStyle(font: ttf))),
      ]);
    }),
  );

  print('ruuning');

  // Save PDF to a file
  final file = File(fileName);
  await file.writeAsBytes(await pdf.save());

  print('pdf save');

  await OpenAppFile.open(
    file.path,
    mimeType: 'application/pdf',
  );

  // final pdfController =
  //     PdfController(document: PdfDocument.openFile(file.path));

  // Widget pdfView() => PdfView(
  //       controller: pdfController,
  //     );

  // if (await file.exists()) {
  //   final filePath = file.path;

  // final uri = Uri.file(filePath);
  print('launching');

  // if (await canLaunch(filePath)) {
  //   await launch(filePath);
  //   print('launch');
  // } else {
  //   // handle the case when file would not be opened.
  // }
  // }
}
