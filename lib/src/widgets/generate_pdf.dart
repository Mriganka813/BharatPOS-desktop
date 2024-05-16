import 'dart:io';
import 'package:flutter/services.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/checkout.dart';

Future<void> generatePdf({
  required String fileName,
  required String date,
  required String companyName,
  required Order Order,
  required User user,
  bool? convertToSale,
  String? totalPrice,
  required String gstType,
  required OrderType orderType,
  String? subtotal,
  String? gstTotal,
  String? totalAmount,
  String? discountTotal,
  String? dlNum,
  String? invoiceNum,
}) async {
  double nettotal = 0;
  final pdf = pw.Document();

  List<String> address = user.address.toString().split(',');

  final List<pw.TableRow> tableRows = [];
  bool expirydateAvailableFlag = false;
  bool hsnAvailableFlag = false;
  bool mrpAvailableFlag = false;
  bool atLeastOneItemHasGst = false;
  bool atleastOneItemHaveDiscount = false;
  Order.orderItems!.forEach((element) {
    if (element.product!.expiryDate != null &&
        element.product!.expiryDate != "null" &&
        element.product!.expiryDate != "") {
      expirydateAvailableFlag = true;
    }
    if (element.product!.hsn != null &&
        element.product!.hsn != "null" &&
        element.product!.hsn != "") {
      hsnAvailableFlag = true;
    }
    if (element.product!.mrp != null &&
        element.product!.mrp != "null" &&
        element.product!.mrp != "" &&
        element.product!.mrp != 0.0
    ) {
      mrpAvailableFlag = true;
    }
    if(element.product?.gstRate != 'null')
      atLeastOneItemHasGst = true;

    if(element.discountAmt != null && element.discountAmt != "null" && element.discountAmt != '' && double.parse(element.discountAmt!) > 0) {
      atleastOneItemHaveDiscount = true;
    }
  });

  for (var data in Order.orderItems!) {
    // double basePrice = 0.0;
    // String gstrate = '';
    //
    // if (gstType == 'WithoutGST') {
    //   if (orderType == OrderType.sale) {
    //     basePrice = data.product!.sellingPrice!;
    //   } else {
    //     basePrice = data.product!.purchasePrice.toDouble();
    //   }
    // } else {
    //   if (orderType == OrderType.sale || orderType==OrderType.estimate || orderType==OrderType.saleReturn) {
    //     if (data.product!.gstRate == "null") {
    //       basePrice = data.product!.sellingPrice!.toDouble();
    //       gstrate = "NA";
    //     } else {
    //       basePrice = double.parse(data.product!.baseSellingPriceGst!);
    //       gstrate = data.product!.gstRate!;
    //     }
    //   } else {
    //     if (data.product!.gstRate == "null" &&
    //         data.product!.purchasePrice != 0) {
    //       basePrice = data.product!.purchasePrice.toDouble();
    //       gstrate = "NA";
    //     } else if (data.product!.gstRate == "null" &&
    //         data.product!.purchasePrice == 0) {
    //       basePrice = 0;
    //       gstrate = "NA";
    //     } else if (data.product!.gstRate != "null" &&
    //         data.product!.purchasePrice != 0) {
    //       basePrice = double.parse(data.product!.basePurchasePriceGst!);
    //       gstrate = data.product!.gstRate!;
    //     } else {
    //       basePrice = 0;
    //       gstrate = data.product!.gstRate!;
    //     }
    //   }
    // }
    double baseprice = 0;
    String gstrate = "";
    OrderItemInput orderItem = data;

    if (orderItem.product!.gstRate == "null" || orderItem.product!.gstRate == null || orderItem.product!.gstRate == "0" || orderItem.product!.gstRate == "0.0") {
      double? sp =orderItem.product!.sellingPrice;
      baseprice = sp == null ? double.parse(orderItem.product!.baseSellingPriceGst.toString()) : sp;
      // String ? bspg = orderItem.baseSellingPrice;
      // baseprice = double.parse(bspg == null || bspg == "null" ? '0.0' : bspg);
      gstrate = "NA";
    } else {
      String? bspg = orderItem.baseSellingPrice;
      baseprice = double.parse(bspg == null || bspg == "null" || bspg == "0" ? orderItem.product!.baseSellingPriceGst.toString() : bspg);
      gstrate = orderItem.product!.gstRate!;
    }
    PdfColor pdfColor = PdfColor.fromInt(1);
    PdfColor pdfColor2 = PdfColor.fromInt(0xFF808080);
    String rate = ((
        ( data.quantity * baseprice +
            double.parse(data.discountAmt![0] =='-' ? '0' : data.discountAmt!))
            /data.quantity
    )).toStringAsFixed(2);
    String amount = ((data.quantity) * baseprice + double.parse(data.discountAmt![0] == '-' ? '0' : data.discountAmt!)).toStringAsFixed(2);
    print("Rate: $rate");
    print("Amount: $amount");
    final tableRow = pw.TableRow(
      children: [
        pw.Container(

          padding: EdgeInsets.all(8),
          width: 40,
          child: pw.Text(
              (data.product!.name! + "                              ")
                  .substring(0, 30),
              style: TextStyle(fontSize: 10)),
        ),
        // SizedBox(width: 10),
        Container(

          padding: EdgeInsets.all(8),
          width: 40,
          child: pw.Text(data.quantity.toString(),
              style: TextStyle(fontSize: 10)),
        ),

        if(expirydateAvailableFlag)
        data.product!.expiryDate != null
        ? Container(

          padding: EdgeInsets.all(8),
          width: 40,
          child: pw.Text('${data.product!.expiryDate!.day}/${data.product!.expiryDate!.month}/${data.product!.expiryDate!.year}', style: TextStyle(fontSize: 10)),
        )
        : SizedBox(),

        if(hsnAvailableFlag)
        data.product!.hsn != null
        ? Container(

          padding: EdgeInsets.all(8),
          width: 40,
          child: pw.Text('${data.product!.hsn == 'null'? '': data.product!.hsn}',style: TextStyle(fontSize: 10)),
        ): SizedBox(),



        ///RATE & AMOUNT
        Container(
          padding: EdgeInsets.all(8),
          width: 40,
          child: pw.Text(
              (rate + "                              ")
                  .substring(0, 30),
              style: TextStyle(fontSize: 10)),
        ),
        //AMOUNT
        Container(
          padding: EdgeInsets.all(8),
          width: 40,
          child: pw.Text(
              (amount + "                              ")
                  .substring(0, 30),
              style: TextStyle(fontSize: 10)),
        ),

        // if(atLeastOneItemHasGst)
        // SizedBox(width: 20),
        if(atleastOneItemHaveDiscount)
          Container(
            padding: EdgeInsets.all(8),
            width: 40,
            child: pw.Text(
                ((orderItem.discountAmt != null && orderItem.discountAmt != "null" && orderItem.discountAmt != ''  && orderItem.discountAmt![0] != '-' ? orderItem.discountAmt : "0.0").toString() + "                              ")
                    .substring(0, 30),
                style: TextStyle(fontSize: 10)),
          ),

        if(mrpAvailableFlag)
          data.product!.mrp != null && data.product!.mrp != "null" && data.product!.mrp != 0.0
              ? Container(
                padding: EdgeInsets.all(8),
                width: 40,
                child: pw.Center(child: Text('${data.product!.mrp}MRP',style: TextStyle(fontSize: 10))),
              ): SizedBox(),

        if(atLeastOneItemHasGst)
        Container(
          padding: EdgeInsets.all(8),
          width: 40,
            child: pw.Center(child: Text('${baseprice.toStringAsFixed(2)}', style: TextStyle(fontSize: 10))),),
        // if(atLeastOneItemHasGst)
        // SizedBox(width: 10),
        if(atLeastOneItemHasGst)
        gstType == 'WithoutGST'
            ? SizedBox()
            : (data.product!.gstRate == 'null'
                ? Container(
            padding: EdgeInsets.all(8),
            width: 40,
            child: pw.Align(alignment: Alignment.centerRight,
  child: Text("N/A", style: TextStyle(fontSize: 10))))
                : Container(
            padding: EdgeInsets.all(8),
            width: 40,
            child: pw.Align(alignment: Alignment.centerRight,
  child: Text(data.product!.saleigst!,style: TextStyle(fontSize: 10))))),
        // SizedBox(width: 10),
        orderType == OrderType.sale || orderType == OrderType.estimate || orderType == OrderType.saleReturn
            ? Container(
            padding: EdgeInsets.all(8),
            width: 40,
                child: pw.Align(alignment: Alignment.centerRight,
                    child: Text(
                    '${(data.quantity) * (data.product?.sellingPrice ?? 0)}',
                    style: TextStyle(fontSize: 10))))
            : Container(
          padding: EdgeInsets.all(8),
          width: 40,
                child: pw.Align(alignment: Alignment.centerRight,
                    child: Text(
                    '${(data.quantity) * (data.product?.purchasePrice ?? 0)}',
                    style: TextStyle(fontSize: 10))),
              )
      ],
    );
    tableRows.add(tableRow);
    // final divider = pw.Row(
    //   children: [
    //     Expanded(child: pw.Divider(color: PdfColor.fromHex('#000000'), thickness: 0.5, height: 4))
    //   ]
    // );
    // tableRows.add(divider);
    nettotal = nettotal + (data.quantity) * (data.product?.purchasePrice ?? 0);
  }

  // final pw.Column table = pw.Column(
  //   children: tableRows,
  // );

  var headerList = ["Name", "Qty", "Rate","Amount", "Total"];


  if(atLeastOneItemHasGst){
    headerList.insert(4, "GST");
    headerList.insert(4, "Taxable value");
  }
  if(mrpAvailableFlag){
    headerList.insert(4, "MRP");
  }
  if(atleastOneItemHaveDiscount) {
    headerList.insert(4, "Discount");
  }
  if (hsnAvailableFlag && orderType!=OrderType.purchase) {
    headerList.insert(2, "HSN");
  }
  if (expirydateAvailableFlag  && orderType!=OrderType.purchase) {
    headerList.insert(2, "Expiry");
  }


  final font = await rootBundle.load('assets/OpenSans-Regular.ttf');
  final ttf = await Font.ttf(font);
  PdfColor pdfColor = PdfColor.fromInt(1);
  PdfColor pdfColor2 = PdfColor.fromInt(0xFF808080);
  print("line 130 in generate pdf");
  print(date);
  String dateFormat(){
    if(date != "null" && date!= ""){
      date = date.substring(0, 10);
      DateTime dateTime = DateTime.parse(date);
      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      if(convertToSale==true){
        DateTime dateTime = DateTime.now();
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
      return formattedDate;
    }else{
      DateTime dateTime = DateTime.now();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
  pdf.addPage(
    pw.Page(build: (pw.Context context) {
      return pw.Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('$invoiceNum', style: TextStyle(font: ttf)),
          pw.Text('Date: ${dateFormat()}',
              style: TextStyle(font: ttf)),
        ]),
        pw.Divider(
          height: 10,
        ),
        pw.SizedBox(height: 10),
        pw.Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                pw.Text('From: ',
                    style: TextStyle(
                      font: ttf,
                    )),
                pw.SizedBox(height: 10),
                pw.Text('$companyName', style: TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                if(atLeastOneItemHasGst)
                pw.Text('GSTIN: ${user.GstIN}', style: TextStyle(font: ttf)),
                pw.Text('${address[0].replaceAll('{', '')}',
                    style: TextStyle(font: ttf)),
                pw.Text('${address[1].replaceAll(' ', '')}',
                    style: TextStyle(font: ttf)),
                pw.Text('${address[2].replaceAll(' ', '')}',
                    style: TextStyle(font: ttf)),
                pw.Text('${address[3].replaceAll('}', '').replaceAll(' ', '')}',
                    style: TextStyle(font: ttf)),
                pw.Text('Email: ${user.email}', style: TextStyle(font: ttf)),
                pw.Text('Phone: ${user.phoneNumber}',
                    style: TextStyle(font: ttf)),
                pw.Text('DL Number: ${user.dlNum == "null" || user.dlNum==null ? user.dlNum="": user.dlNum}',
                    style: TextStyle(font: ttf)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if ((Order.reciverName != "" &&
                        Order.reciverName != null) ||
                    (Order.businessName != "" &&
                        Order.businessName != null) ||
                    (Order.businessAddress != "" &&
                        Order.businessAddress != null) ||
                    Order.gst != "" && Order.gst != null || dlNum != null && dlNum != "")
                  pw.Text('Billed to:                        ',
                      style: TextStyle(
                        font: ttf,
                      )),
                pw.SizedBox(height: 10),
                if (Order.reciverName != "" &&
                    Order.reciverName != null)
                  pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(font: ttf),
                      children: [
                        pw.TextSpan(text: 'Name: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.TextSpan(text: Order.reciverName.toString()),
                      ],
                    ),
                  ),
                if (Order.businessName != "" &&
                    Order.businessName != null)
                  pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(font: ttf),
                      children: [
                        pw.TextSpan(text: 'Business Name: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.TextSpan(text: Order.businessName.toString()),
                      ],
                    ),
                  ),
                if (Order.businessAddress != "" &&
                    Order.businessAddress != null)
                  pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(font: ttf),
                      children: [
                        pw.TextSpan(text: 'Business Add.: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.TextSpan(text: Order.businessAddress.toString()),
                      ],
                    ),
                  ),
                if (Order.gst != "" && Order.gst != null)
                  pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(font: ttf),
                      children: [
                        pw.TextSpan(text: 'GSTIN: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10)),
                        pw.TextSpan(text: Order.gst.toString()),
                      ],
                    ),
                  ),
                if (dlNum != "" && dlNum != null)
                  pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(font: ttf),
                      children: [
                        pw.TextSpan(text: 'DL Number: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.TextSpan(text: dlNum.toString()),
                      ],
                    ),
                  ),
              ])
            ]),

        // pw.SizedBox(height: 20),
        // pw.Divider(thickness: 1, color: pdfColor2),
        pw.Table(
          border: TableBorder.all(
              color: PdfColor.fromInt(0xffc9c9c9),
            width: 2
          ), // Border for the table
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(

                children: [
              for(int i = 0; i < headerList.length; i++)
                pw.Container(
                  padding: EdgeInsets.all(8),
                  width: 40,
                  // width: 30,
                  child: pw.Text(headerList[i], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
            ]),
            ...tableRows
          ]
        ),

        // pw.Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        //   for(int i = 0; i < headerList.length; i++)
        //     pw.Container(
        //
        //       // width: 30,
        //       child: pw.Text(headerList[i]),
        //     ),
        //
        //   // pw.Container(
        //   //   width: 50,
        //   //   child: pw.Text('Name'),
        //   // ),
        //   // // SizedBox(width: 10),
        //   // pw.Container(
        //   //   width: 30,
        //   //   child: pw.Text('Qty'),
        //   // ),
        //   // // if(expirydateAvailableFlag)
        //   // // SizedBox(width: 10),
        //   //
        //   // if(expirydateAvailableFlag)
        //   // pw.Container(
        //   //   width: 55,
        //   //   child: pw.Text('Expiry'),
        //   // ),
        //   // // if(hsnAvailableFlag)
        //   // //   SizedBox(width: 10),
        //   // if(hsnAvailableFlag)
        //   //   pw.Container(
        //   //     width: 50,
        //   //     child: pw.Text('HSN'),
        //   //   ),
        //   // // if(mrpAvailableFlag)
        //   // //   SizedBox(width: 10),
        //   // if(mrpAvailableFlag)
        //   //   pw.Container(
        //   //     width: 50,
        //   //     child: pw.Text('MRP'),
        //   //   ),
        //   // // if(atLeastOneItemHasGst)
        //   // // SizedBox(width: 20),
        //   // if(atLeastOneItemHasGst)
        //   // pw.Container(
        //   //   width: 70,
        //   //   child: pw.Text('Rate/Unit'),
        //   // ),
        //   // // if(atLeastOneItemHasGst)
        //   // // SizedBox(width: 10),
        //   // if(atLeastOneItemHasGst)
        //   // gstType == 'WithoutGST'
        //   //     ? Container()
        //   //     : Container(width: 50, child: pw.Text('GST/Unit')),
        //   // // SizedBox(width: 10),
        //   // Container(width: 50, child: pw.Text('Amount'))
        // ]),
        // pw.Divider(thickness: 1, color: pdfColor2),

        ///
        // pw.Table(children: [
        //   pw.TableRow(children: [
        //     pw.Text('Name', style: TextStyle(font: ttf)),
        //     pw.Text('Qty', style: TextStyle(font: ttf)),
        //     pw.Text('Rate/Unit', style: TextStyle(font: ttf)),
        //     pw.Text('GST/Unit', style: TextStyle(font: ttf)),
        //     pw.Text('Amount', style: TextStyle(font: ttf)),
        //   ]),

        // ]),

        // table,

        // table,

        pw.SizedBox(height: 20),

        if(atleastOneItemHaveDiscount)
          pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            pw.Text('Total Amount:       ',
                style: TextStyle(
                    font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10)),
               Container(
          
                width: 50,
                child: pw.Align(alignment: Alignment.centerRight,
      child: Text(totalAmount.toString(),
                    style: TextStyle(font: ttf, fontSize: 10))))
          ]),
        if(atleastOneItemHaveDiscount)
          pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            pw.Text('Discount:       ',
                style: TextStyle(
                    font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10)),
            Container(
          
                width: 50,
                child: pw.Align(alignment: Alignment.centerRight,
      child: Text(discountTotal.toString(),
                    style: TextStyle(font: ttf, fontSize: 10))))
          ]),


        pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          pw.Text('Sub Total:       ',
              style: TextStyle(
                  font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10)),
          subtotal == null || subtotal == ''
              ? Container(
          width: 50, child: pw.Align(alignment: Alignment.centerRight,
      child: Text('0.0')))
              : Container(
          
                  width: 50,
                  child: pw.Align(alignment: Alignment.centerRight,
      child: Text(double.parse(subtotal).toStringAsFixed(2),
                      style: TextStyle(font: ttf, fontSize: 10))))
        ]),

        if(atLeastOneItemHasGst)
        pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          pw.Text('GST Total:       ',
              style: TextStyle(
                  font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10)),
          gstTotal == null || gstTotal == ''
              ? Container(
          width: 50, child: pw.Align(alignment: Alignment.centerRight,
      child: Text('0.0')))
              : Container(
          
                  width: 50,
                  child: pw.Align(alignment: Alignment.centerRight,
      child: Text(gstTotal.toString(),
                      style: TextStyle(font: ttf, fontSize: 10))))
        ]),

        pw.Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          pw.Text('Grand Total:       ',
              style: TextStyle(
                  font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10)),
          subtotal == null || subtotal == ''
              ? Container(
          width: 50, child: pw.Align(alignment: Alignment.centerRight,
      child: Text('0.0')))
              : Container(
          
                  width: 50,
                  child: pw.Align(alignment: Alignment.centerRight,
      child: Text(
                      (double.parse(subtotal) + double.parse(gstTotal!))
                          .toStringAsFixed(2),
                      style: TextStyle(font: ttf, fontSize: 10))))
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
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/Invoice.pdf';
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  print('pdf save');

  OpenAppFile.open(
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