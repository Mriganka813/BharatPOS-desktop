import 'dart:async';

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
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  BuildContext context;
  SplashScreen(this.context, {Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  late String _latestVersion = '';
  String _currentVersion = '1.0.2';
  ///
  @override
  void initState() {
    super.initState();
    // authStatus();
    checkForUpdates();
 //   getDataFromDatabase();
  }
  Future<void> checkForUpdates() async {
    try {
      final response = await ApiV1Service.getRequest('/version/latest/bharatPos');

      if (response.statusCode == 200) {
        _latestVersion = response.data['data']['version'];
        print("latestVersion: = $_latestVersion");
        if(_currentVersion != _latestVersion){
          alertUpdate();
        }
        else{
          authStatus();
        }
      } else {
        print('Failed to fetch latest version. Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching latest version: $e');
    }
  }
  Future<void> alertUpdate() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(

          title: const Text('Update Available'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('A new version of BharatPOS is available.'),
                const Text('Please update to the latest version.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                _launchURL();
                _startUpdateCheck();
              },
            ),
          ],

        );
      },
    );
  }

  void _startUpdateCheck() {
    // Start a timer to check for updates every 5 seconds
    Timer.periodic(Duration(seconds: 3), (timer) {
      if(_currentVersion == _latestVersion){
        authStatus();
      }
    });
  }
  Future<void> _launchURL() async {
    final Uri _url = Uri.parse(
        'https://bharatpos.xyz');

    if (await canLaunchUrl(_url)) {
      await launchUrl(_url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $_url');
    }

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
