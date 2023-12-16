import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/services/api_v1.dart';
import 'package:url_launcher/url_launcher.dart';

class Openpdffrombackend {
  Future<void> getpdf(
    Order input,
    User user,
    String invoiceNum,
  ) async {
    final Response response = await ApiV1Service.postRequest("/invoice", data: {
      "Order": input.toMap(OrderType.sale),
      "invoice": invoiceNum,
      "address": user.address,
      "companyName": user.businessName,
      "email": user.email,
      "phone": user.phoneNumber,
      "date": DateTime.now().toString(),
    });
    try {
      if (await canLaunchUrl(
          Uri.parse('http://65.0.7.20:8001/api/v1/genrate/${response.data}'))) {
        await launchUrl(
            Uri.parse('http://65.0.7.20:8001/api/v1/genrate/${response.data}'));
      } else {
        throw 'Could not launch';
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
