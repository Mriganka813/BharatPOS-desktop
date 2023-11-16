import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/KotModel.dart';
import 'package:shopos/src/models/input/party_input.dart';
import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/party.dart';

class KotCubit extends Cubit<List<KotModel>> {
  KotCubit() : super([]);

  void insertKot(List<KotModel> list) {
    var data = state;
  
    list.forEach((element) {

      bool flag=false;
      for(int i=0;i<data.length;i++)
      {
        if(data[i].orderId==element.orderId&&data[i].isPrinted=="no"&&data[i].name==element.name)
        {
          if(data[i].qty>0)
          {
              data[i].qty=element.qty+data[i].qty;

          }
          flag=true;
        
        }
      }

      if(flag==false)
      {
        data.add(element);
      }
    });
    emit(data);
  }

  void deleteKot(String OrderId, String itemName) {
    var data = state;

    for (int i = 0; i < data.length; i++) {
      if (data[i].orderId == OrderId &&
          data[i].isPrinted == "no" &&
          data[i].name == itemName) {
        if (data[i].qty > 1) {
          data[i].qty = data[i].qty - 1;
        } else {
          data.removeAt(i);
        }
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
