import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:shopos/src/blocs/home/home_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/AboutOptionPage.dart';
import 'package:shopos/src/pages/CreateSalesReturn.dart';
import 'package:shopos/src/pages/SwitchAccountPage.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_purchase.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/expense.dart';
import 'package:shopos/src/pages/party_list.dart';
import 'package:shopos/src/pages/reports.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:shopos/src/pages/set_pin.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/provider/billing.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/widgets/custom_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'create_estimate.dart';
import 'online_order_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;
  PinService _pinService = PinService();

  ///
  @override
  void initState() {
    // _checkUpdate();
    _homeCubit = HomeCubit()..currentUser();
    super.initState();
  }

  Future<void> _checkUpdate() async {
    final newVersion = NewVersion(androidId: "com.shopos.magicstep");
    final status = await newVersion.getVersionStatus();
    if (status!.canUpdate) {
      newVersion.showUpdateDialog(
          context: context, versionStatus: status, allowDismissal: false);
    }
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: _homeCubit,
        builder: (context, state) {
          if (state is HomeRender) {
            return Scaffold(
              appBar: AppBar(
                title: Text(state.user.businessName ?? ""),
                centerTitle: true,
              ),
              drawer: Drawer(
                child: SafeArea(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Image.asset(
                          "assets/images/bharat.png",
                          height: 30,
                        ),
                        title: Title(
                          color: Colors.black,
                          child: Text(
                            "",
                            textScaleFactor: 1.4,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Divider(),
                      /*   ListTile(
                        leading: Icon(Icons.lock),
                        title: Title(
                            color: Colors.black, child: Text("Set/Change pin")),
                        onTap: () async {
                          bool status = await _pinService.pinStatus();
                          print(status);
                          Navigator.of(context).pushNamed(SetPinPage.routeName,
                              arguments: status);
                        },
                      ),*/
                      ListTile(
                        leading: Image.asset(
                          "assets/images/shop.png",
                          height: 30,
                        ),
                        title: Title(
                          color: Colors.black,
                          child: Text(
                            state.user.businessName ?? "",
                          ),
                        ),
                        subtitle: Text(
                          state.user.email ?? "",
                          textScaleFactor: 1.2,
                        ),
                        onTap: () async {
                          Navigator.pushNamed(
                              context, SwitchAccountPage.rountName); //
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                      ),
                      ListTile(
                        leading: Image.asset(
                          "assets/images/calcicon.jpeg",
                          height: 38,
                        ),
                        title: Title(color: Colors.black, child: Text("Estimates")),
                        onTap: () async {
                          Navigator.of(context).pushNamed(CreateEstimate.routeName);
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                      ),
                      ListTile(
                        leading: Image.asset(
                          "assets/images/lock.png",
                          height: 30,
                        ),
                        title: Title(
                            color: Colors.black,
                            child: Text("Change Password")),
                        onTap: () async {
                          await Navigator.pushNamed(context, 'changepassword',
                              arguments: state.user);
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                      ),
                      ListTile(
                        leading: Image.asset(
                          "assets/images/about.png",
                          height: 30,
                        ),
                        title: Title(color: Colors.black, child: Text("About")),
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              AboutOptionPage
                                  .routeName); // Navigate to the PrivacyPolicyPage
                        },
                      ),
                      /* ListTile(
                        leading: Icon(Icons.policy_outlined),
                        title: Title(
                            color: Colors.black, child: Text("Privacy Policy")),
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(
                                'http://64.227.172.99:5000/privacy-policy'),
                            mode: LaunchMode.externalApplication,
                          );
                          Navigator.pop(context);
                        },
                      ),*/
                      Divider(
                        color: Colors.transparent,
                      ),
                      /*  ListTile(
                        leading: Icon(Icons.control_point),
                        title: Title(
                            color: Colors.black,
                            child: Text("Terms and Conditions")),
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(
                                'http://64.227.172.99:5000/terms-and-condition'),
                            mode: LaunchMode.externalApplication,
                          );
                          Navigator.pop(context);
                        },
                      ),*/

                      ListTile(
                        leading: Image.asset(
                          "assets/images/logout.png",
                          height: 30,
                        ),
                        title:
                            Title(color: Colors.black, child: Text("Logout")),
                        onTap: () async {
                           await const AuthService().signOut();
                           final provider =
                              Provider.of<Billing>(context, listen: false);
                         provider.removeAll();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            SignInPage.routeName,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GridView(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2,
                        mainAxisExtent: 166,
                      ),
                      padding: const EdgeInsets.all(10),
                      children: [
                        HomeCard(
                          color: 0XFF48AFFF,
                          icon: 'assets/images/products.png',
                          title: "Products",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SearchProductListScreen.routeName,
                              arguments: ProductListPageArgs(
                                  isSelecting: false,
                                  orderType: OrderType.none,
                                  productlist: []),
                            );
                          },
                        ),
                        HomeCard(
                          color: 0XFFFFC700,
                          icon: 'assets/images/party.png',
                          title: "Party",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PartyListPage.routeName,
                            );
                          },
                        ),
                        HomeCard(
                          color: 0XFFFF5959,
                          icon: 'assets/images/expense.png',
                          title: "Expense",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ExpensePage.routeName,
                            );
                          },
                        ),
                        HomeCard(
                          color: 0XFF5642A6,
                          icon: 'assets/images/reports.png',
                          title: "Reports",
                          onTap: () {
                            Navigator.pushNamed(context, ReportsPage.routeName);
                          },
                        ),

                        // OnlineStoreWidget(
                        //   activeOrders: 5,
                        //   onTap: () {
                        //     Navigator.pushNamed(context, ReportsPage.routeName);
                        //   },
                        // ),
                      ],
                    ),
                    const Spacer(),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Create Invoice",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              CreatePurchase.routeName,
                            );
                          },
                          child: Column(
                            children: [
                              Card(
                                color: Color.fromARGB(255, 255, 101, 122)
                                    .withOpacity(0.5),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Color.fromARGB(255, 175, 76,
                                        76), // Set the border color
                                    width: 2.0, // Set the border width
                                  ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      "assets/images/purchase.png",
                                      height: 100,
                                      width: 110,
                                    )),
                              ),
                              Text(
                                "Purchase",
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, CreateSale.routeName,
                                arguments: BillingPageArgs(
                                    id: "", orderId: "", editOrders: []));
                          },
                          onLongPress: () {
                            Navigator.pushNamed(
                              context,
                              CreateSaleReturn.routeName,
                            );
                          },
                          child: Column(
                            children: [
                              Card(
                                color: const Color.fromARGB(255, 101, 255, 106)
                                    .withOpacity(0.5),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.green, // Set the border color
                                    width: 2.0, // Set the border width
                                  ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      "assets/images/sale.png",
                                      height: 100,
                                      width: 110,
                                    )),
                              ),
                              Text(
                                "Sale",
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: ColorsConst.primaryColor,
            ),
          );
        },
      ),
    );
  }
}

// class OnlineStoreWidget extends StatelessWidget {
//   final int activeOrders;
//   final VoidCallback onTap;

//   const OnlineStoreWidget({
//     Key? key,
//     this.activeOrders = 0,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, OnlineOrderList.routeName);
//       },
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 30.0), // Add vertical padding
//           child: Column(
//             children: [
//               // SizedBox(width: 20.0),
//               Icon(
//                 Icons.storefront_rounded,
//                 size: 50.0,
//                 color: ColorsConst.primaryColor,
//               ),
//               SizedBox(width: 35.0),
//               // Text(
//               //   "Online Orders",
//               //   style: Theme.of(context).textTheme.headline6,
//               //   textAlign: TextAlign.center,
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class HomeCard extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final String title;
  final int color;
  const HomeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          Card(
            color: Color(color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    icon,
                    height: 100,
                    width: 200,
                  ),
                ],
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
