import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/provider/billing.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/api_v1.dart';

class SplashScreen extends StatefulWidget {
  BuildContext context;
  SplashScreen(this.context, {Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  ///
  @override
  void initState() {
    super.initState();
    authStatus();
 //   getDataFromDatabase();
  }

  Future<void> authStatus() async {
    final cj = await const ApiV1Service().initCookiesManager();
    final cookies = await cj.loadForRequest(Uri.parse(Const.apiUrl));
    final isAuthenticated = cookies.isNotEmpty;
    print("isAuthenticated:");
    print(isAuthenticated);
    Future.delayed(
      const Duration(milliseconds: 6000),
      () => Navigator.pushReplacementNamed(
        context,
        isAuthenticated ? HomePage.routeName : SignInPage.routeName,
      ),
    );
  }


  getDataFromDatabase() async {

   /*// DatabaseHelper().DeleteDatabase();
    final provider = Provider.of<Billing>(
      widget.context,
    );
    var data = await DatabaseHelper().getOrderItems();


    provider.removeAll();

    data.forEach((element) {
      provider.addSalesBill(element, element.id.toString());
    });*/
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: /*Color.fromARGB(255, 81, 163, 251)*/Colors.white,
        ),
        backgroundColor: /*Color.fromARGB(255, 81, 163, 251)*/Colors.white,
      ),
      backgroundColor: /*Color.fromARGB(255, 81, 163, 251)*/Colors.white,
      body: Center(
        child: Container(
          width: 700,
          child: SvgPicture.asset("assets/icon/BharatPos.svg",fit: BoxFit.cover,)),
      ),
    );
  }
}
