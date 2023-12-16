import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/services/SalesReturnService.dart';
import 'package:shopos/src/services/purchase.dart';
import 'package:shopos/src/services/sales.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  Future<void> createSalesOrder(Order input, String date) async {
    emit(CheckoutLoading());
    try {
      await SalesService.createSalesOrder(input, date);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Something went wrong"));
      return;
    }
  }

  Future<void> createPurchaseOrder(Order input, String date) async {
    emit(CheckoutLoading());
    try {
      await PurchaseService.createPurchaseOrder(input, date);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Purchase order creation failed"));
      return;
    }
  }

  Future<void> createSalesReturn(Order input, String invoiceNum,String total) async {
    emit(CheckoutLoading());
    try {
      await SalesReturnService.createSalesReturnOrder(input, invoiceNum,total);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Purchase order creation failed"));
      return;
    }
  }
}
