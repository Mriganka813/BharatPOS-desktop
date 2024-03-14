import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/AboutOptionPage.dart';
import 'package:shopos/src/pages/CreateSalesReturn.dart';
import 'package:shopos/src/pages/SwitchAccountPage.dart';
import 'package:shopos/src/pages/billing_list.dart';
import 'package:shopos/src/pages/change_password.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_estimate.dart';
import 'package:shopos/src/pages/create_expense.dart';
import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/pages/create_product.dart';
import 'package:shopos/src/pages/create_purchase.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/expense.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/online_order_list.dart';
import 'package:shopos/src/pages/party_credit.dart';
import 'package:shopos/src/pages/party_list.dart';
import 'package:shopos/src/pages/pdf_preview.dart';
import 'package:shopos/src/pages/preferences_page.dart';
import 'package:shopos/src/pages/reports.dart';
import 'package:shopos/src/pages/report_table.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:shopos/src/pages/select_products_screen.dart';
import 'package:shopos/src/pages/set_pin.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/pages/splash.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      navigatorKey: locator<GlobalServices>().navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      theme: ThemeData(
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: SplashScreen(context),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case SignInPage.routeName:
                return const SignInPage();
              //case SignUpPage.routeName:
              //return const SignUpPage();
              case HomePage.routeName:
                return const HomePage();
              /*  case ProductsListPage.routeName:
                return ProductsListPage(
                  args: settings.arguments as ProductListPageArgs?,
                );*/
              case CreateProduct.routeName:
                return CreateProduct(args: settings.arguments as CreateProductArgs);

              case PartyListPage.routeName:
                return const PartyListPage();
              case SearchProductListScreen.routeName:
                return SearchProductListScreen(  args: settings.arguments as ProductListPageArgs);

           case AboutOptionPage.routeName:
                return AboutOptionPage();
              case ReportsPage.routeName:
                return const ReportsPage();
              case ExpensePage.routeName:
                return const ExpensePage();
              case DefaultPreferences.routeName:
                return const DefaultPreferences();
              case OnlineOrderList.routeName:
                return const OnlineOrderList();
              case CreateExpensePage.routeName:
                return CreateExpensePage(id: settings.arguments as String?);
              case CreatePartyPage.routeName:
                return CreatePartyPage(
                    args: settings.arguments as CreatePartyArguments);
              case CreateSale.routeName:
                return CreateSale(
                  args: settings.arguments as BillingPageArgs?,
                );
              case CreateEstimate.routeName:
                return CreateEstimate(
                  args: settings.arguments as EstimateBillingPageArgs,
                );
              case CreatePurchase.routeName:
                return CreatePurchase(
                    args: settings.arguments as BillingPageArgs?);
              case CheckoutPage.routeName:
                return CheckoutPage(
                  args: settings.arguments as CheckoutPageArgs,
                );
                 case CreateSaleReturn.routeName:
                return CreateSaleReturn();
                 case SwitchAccountPage.rountName:
                return SwitchAccountPage();
              case PartyCreditPage.routeName:
                return PartyCreditPage(
                  args: settings.arguments as ScreenArguments,
                );
              case PdfPreviewPage.routeName:
                return PdfPreviewPage(
                  args: settings.arguments as PdfPreviewPageArgs,
                );
              case ChangePassword.routeName:
                return ChangePassword(user: settings.arguments as User?);
              // case ShowPdfScreen.routeName:
              //   String htmlContent = settings.arguments as String;
              //   return ShowPdfScreen(
              //     htmlContent: htmlContent,
              //   );
              //case Forgotpassword.routeName:
              //return Forgotpassword();

              case BillingListScreen.routeName:
                return BillingListScreen(
                  orderType: settings.arguments as OrderType,
                );
                case SetPinPage.routeName:
                bool status = settings.arguments as bool;
                return SetPinPage(
                  isPinSet: status,
                );

              case ReportTable.routeName:
                return ReportTable(
                  args: settings.arguments as tableArg,
                );
              default:
                return  SplashScreen(context);
            }
          },
        );
      },
    );
  }
}
