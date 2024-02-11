import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_state.dart';
import 'package:shopos/src/models/input/order.dart';

import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/specific_party.dart';

class SpecificPartyCubit extends Cubit<SpecificPartyState> {
  final List<Order> _specificsaleParties = [];
  final List<Order> _specificpurchaseParties = [];
  final SpecificPartyService _partyService = SpecificPartyService();
  late final Party _partyDetails;
  SpecificPartyCubit() : super(SpecificPartyInitial());

  ///
  void getInitialCreditHistory(String id) async {
    emit(SpecificPartyLoading());
    try {
      final sales = await _partyService.getSalesCreditHistory(id);
      _partyDetails = await _partyService.getCreditSaleParty(id);
      _specificsaleParties.clear();
      _specificpurchaseParties.clear();
      _specificsaleParties.addAll(sales);
      emit(
        SpecificPartyListRender(
          specificparty: sales,
          partyDetails: _partyDetails,
        ),
      );
    } catch (err) {
      log("$err");
      SpecificPartyError("Error fetching parties");
    }
  }

  ///
  void getInitialpurchasedHistory(String id) async {
    emit(SpecificPartyLoading());
    try {
      final purchase = await _partyService.getpurchaseCreditHistory(id);
      _partyDetails = await _partyService.getCreditPurchaseParty(id);
      _specificsaleParties.clear();
      _specificpurchaseParties.clear();
      _specificpurchaseParties.addAll(purchase);
      emit(SpecificPartyListRender(
        specificparty: purchase,
        partyDetails: _partyDetails,
      ));
    } catch (err) {
      log("$err");
      SpecificPartyError("Error fetching parties");
    }
  }

  ///
  void updateCreditHistory(Party p) async {
    final response = await _partyService.updateSalesCredit(p);
    final sales = await _partyService.getSalesCreditHistory(p.id!);
    if ((response.statusCode ?? 400) > 300) {
      emit(SpecificPartyError("Error updating party"));
      return;
    }
    final _partyDetail = await _partyService.getCreditSaleParty(p.id!);
    return emit(SpecificPartyListRender(
      partyDetails: _partyDetail,
      specificparty: sales,
    ));
  }

  ///
  void updatepurchaseHistory(Party p) async {
    final response = await _partyService.updatepurchasedCredit(p);
    final purchase = await _partyService.getpurchaseCreditHistory(p.id!);
    if ((response.statusCode ?? 400) > 300) {
      emit(SpecificPartyError("Error updating party"));
      return;
    }
    final _partyDetail = await _partyService.getCreditPurchaseParty(p.id!);
    return emit(SpecificPartyListRender(
      partyDetails: _partyDetail,
      specificparty: purchase,
    ));
  }

  ///
  void updateAmountCustomer(String id, double total, String partyId) async {
    final response = await _partyService.updateSaleAmount(id, total);
    if ((response.statusCode ?? 400) > 300) {
      emit(SpecificPartyError("Error updating party"));
      return;
    }
    final sales = await _partyService.getSalesCreditHistory(partyId);
    final _partyDetail = await _partyService.getCreditSaleParty(partyId);
    return emit(SpecificPartyListRender(
        partyDetails: _partyDetail, specificparty: sales));
  }

  ///
  void updateAmountSupplier(String id, double amount, String partyId) async {
    final response = await _partyService.updatepurchasedAmount(id, amount);
    if ((response.statusCode ?? 400) > 300) {
      emit(SpecificPartyError("Error updating party"));
      return;
    }
    final purchase = await _partyService.getpurchaseCreditHistory(partyId);
    final _partyDetail = await _partyService.getCreditPurchaseParty(partyId);
    return emit(SpecificPartyListRender(
        partyDetails: _partyDetail, specificparty: purchase));
  }

  ///
  void deleteCustomerExpense(String id, String partyId) async {
    try {
      final response = await _partyService.deletesaleAmount(id);
      if ((response.statusCode ?? 400) > 300) {
        emit(SpecificPartyError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(SpecificPartyError(err.message.toString()));
    }
    final sales = await _partyService.getSalesCreditHistory(partyId);
    final _partyDetail = await _partyService.getCreditSaleParty(partyId);
    return emit(SpecificPartyListRender(
        partyDetails: _partyDetail, specificparty: sales));
  }

  ///
  void deleteSupplierExpense(String id, String partyId) async {
    try {
      final response =
      await _partyService.deletepurchaseAmount(id);
      if ((response.statusCode ?? 400) > 300) {
        emit(SpecificPartyError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(SpecificPartyError(err.message.toString()));
    }
    final purchase = await _partyService.getpurchaseCreditHistory(partyId);
    final _partyDetail = await _partyService.getCreditPurchaseParty(partyId);
    return emit(SpecificPartyListRender(
        partyDetails: _partyDetail, specificparty: purchase));
  }
}
