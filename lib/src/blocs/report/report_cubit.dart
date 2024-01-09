import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/expense.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/input/report_input.dart';

import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/models/report.dart';
import 'package:shopos/src/pages/reports.dart';
import 'package:shopos/src/services/report.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportService _reportService = const ReportService();
  ReportCubit() : super(ReportInitial());

  ///
  void downloadReport(ReportInput input) async {
    emit(ReportLoading());
    final res = await _reportService.getAllReport(input);
    if (input.type == ReportType.sale) {
      _emitSalesReport(res, true);
    }
    if (input.type == ReportType.purchase) {
      _emitPurchaseReport(res, true);
    }
    if (input.type == ReportType.expense) {
      _emitExpenseReport(res, true);
    }
    if(input.type == ReportType.estimate){
      _emitEstimatesReport(res,true);
    }
    if(input.type == ReportType.saleReturn){
      _emitSalesReturnReport(res,true);
    }
  }

  ///
  void getReport(ReportInput input) async {
    emit(ReportLoading());
    print("line 44 in report cubit");
    if (input.type == ReportType.sale) {
    print("line 46 in report cubit");
      final res = await _reportService.getAllReport(input);
      _emitSalesReport(res);
    }
    if (input.type == ReportType.purchase) {
      final res = await _reportService.getAllReport(input);
      _emitPurchaseReport(res);
    }
    if (input.type == ReportType.expense) {
      final res = await _reportService.getAllReport(input);
      _emitExpenseReport(res);
    }
    if (input.type == ReportType.stock) {
      final res = await _reportService.getStockReport();
      _emitStockReport(res);
    }
    if(input.type == ReportType.estimate){
      print("line 66 in report cubit");
      final res = await _reportService.getAllReport(input);
      _emitEstimatesReport(res);
    }
    if(input.type == ReportType.saleReturn){
      print("line 75 in report cubit");
      final res = await _reportService.getAllReport(input);
      _emitSalesReturnReport(res);
    }
  }
  _emitSalesReturnReport(Response res, [bool isDownload = false]) {
    final data = res.data['sales'];
    final orders = data.map<Order>((item) {
      print("line 84 in");
      // print(Order.fromMap(item).toString());
      return Order.fromMap(item);
    }).toList();
    emit(isDownload
        ? ReportsDownload(orders: orders)
        : ReportsView(orders: orders));
  }
  _emitEstimatesReport(Response res, [bool isDownload = false]){
    final data = res.data['estimates'];
    print("--line 87 in report_cubit");
    print(data);
    final orders = data.map<Order>((item){
      return Order.fromMap(item);
    }).toList();
    emit(isDownload
        ? ReportsDownload(orders: orders)
        : ReportsView(orders: orders));
  }
  _emitSalesReport(Response res, [bool isDownload = false]) {
    final data = res.data['sales'];
    final orders = data.map<Order>((item) => Order.fromMap(item)).toList();
    emit(isDownload
        ? ReportsDownload(orders: orders)
        : ReportsView(orders: orders));
  }

  _emitPurchaseReport(Response res, [bool isDownload = false]) {
    final data = res.data['purchase'];
    final orders =
        List.generate(data.length, (index) => Order.fromMap(data[index]));
    emit(isDownload
        ? ReportsDownload(orders: orders)
        : ReportsView(orders: orders));
  }

  _emitExpenseReport(Response res, [bool isDownload = false]) {
    final data = res.data['expense'] as List;
    final expenses =
        List.generate(data.length, (index) => Expense.fromMap(data[index]));
    emit(isDownload
        ? ReportsDownload(expenses: expenses)
        : ReportsView(expenses: expenses));
  }

  _emitStockReport(Response res, [bool isDownload = false]) {
    final products = List.generate(
      res.data['inventories'].length,
      (int index) => Product.fromMap(
        res.data['inventories'][index],
      ),
    );
    emit(isDownload
        ? ReportsDownload(product: products)
        : ReportsView(product: products));
  }
}
