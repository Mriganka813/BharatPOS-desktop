import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/KotModel.dart';
import 'package:shopos/src/models/input/party_input.dart';

import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/party.dart';

class KotCubit extends Cubit<List<KotModel>> {
  KotCubit() : super([]);

  void insertKot(List<KotModel> list) {
    var data = state;
  
    list.forEach((element) {
      bool flag=false;
      for(int i=0;i<data.length;i++){
        if(data[i].orderId==element.orderId&&data[i].isPrinted=="no"&&data[i].name==element.name){
          if(data[i].qty>0){
              data[i].qty=element.qty+data[i].qty;
          }
          flag=true;
        }
      }
      if(flag==false){
        data.add(element);
      }
    });
    emit(data);
  }

  void deleteKotWhenDismissed(String orderId){
    //TODO: i thought that this function will accept order id from billing page and it will remove the KOT
    var data = state;

    print("data.length is ${data.length}");
    for (int i = data.length - 1; i >= 0; i--) {
      print(data[i].orderId);
      print(data[i].name);
      // print(data[i+1].name);
      if (data[i].orderId == orderId) {
        data.removeAt(i);
      }
      print("data.length: ${data.length}");
    }


    emit(data);
  }

  void deleteKot(String OrderId, String itemName) {
    var data = state;

    for (int i = 0; i < data.length; i++) {
      if (data[i].orderId == OrderId && data[i].isPrinted == "no" && data[i].name == itemName) {
        data.removeAt(i);
        break;
      }
    }

    emit(data);
  }

  void updateKotQuantity(String orderId, String itemName, double itemQuantity){
    var data = state;
    for (int i = 0; i < data.length; i++) {
      if(data[i].orderId == orderId && data[i].isPrinted == "no" && data[i].name == itemName){
        data[i].qty = itemQuantity;
        break;
      }
    }

    emit(data);
  }
  void updateKot(String orderId) {
    var data = state;
    for (int i = 0; i < data.length; i++) {
      if (data[i].orderId == orderId) {
        data[i].isPrinted = "yes";
      }
    }

    emit(data);
  }

  List<Map<String,dynamic>> getKot()
  {
     List<Map<String,dynamic>> list=[];
     state.forEach((element) { 

      var map=element.toMap();
      if(element.isPrinted=="no")
      list.add(map);
     });

     return list;
  }
}
