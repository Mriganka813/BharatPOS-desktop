// import 'package:audioplayers/audioplayers.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/blocs/Kot/KotCubit.dart';
import 'package:shopos/src/models/KotModel.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/billing_list.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:shopos/src/pages/select_products_screen.dart';
import 'package:shopos/src/provider/billing.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_continue_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/product_card_horizontal.dart';

import '../blocs/billing/billing_cubit.dart';
import '../models/input/kot_model.dart';
import '../services/kot_services.dart';
import '../services/product.dart';
import '../widgets/barcode_listener.dart';

class BillingPageArgs {
  // final String? orderId;
  final List<OrderItemInput>? editOrders;
  // final id;
  final String? kotId;
  final String? tableNo;
  BillingPageArgs({this.editOrders, this.kotId, this.tableNo});
}

class CreateSale extends StatefulWidget {
  static const routeName = '/create_sale';

  CreateSale({Key? key, this.args}) : super(key: key);

  BillingPageArgs? args;

  @override
  State<CreateSale> createState() => _CreateSaleState();
}

class _CreateSaleState extends State<CreateSale> {
  late Order _Order;
  late final Order _prevOrder;
  // late final AudioCache _audioCache;
  List<OrderItemInput>? newAddedItems = [];
  List<Product> Kotlist = [];
  bool isLoading = false;
  late SharedPreferences prefs;
  bool skipPendingOrdersPref = false;
  bool barcodePref = true;
  bool _isPercentPref = false;
  @override
  void initState() {
    super.initState();
    // _audioCache = AudioCache(
    //   fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    // );
    List<OrderItemInput>? orderItems = [];
    if(widget.args != null){
      widget.args?.editOrders?.forEach((element) {
        orderItems.add(OrderItemInput.fromMap(element.toMapCopy()));
      });
    }
    _Order = Order(
        kotId: widget.args!.kotId ?? "",
        orderItems: widget.args == null ? [] : orderItems,
        // orderItems: widget.args == null ? [] : widget.args?.editOrders,
        tableNo: (widget.args!.tableNo == null || widget.args!.tableNo=='null') ? "" : widget.args!.tableNo!
    );
    //for comparing purpose
    _prevOrder = Order.fromMap(_Order.toMapForCopy());
    init();
  }
  void init() async {
    prefs = await SharedPreferences.getInstance();
    skipPendingOrdersPref = (await prefs.getBool('pending-orders-preference'))!;
    barcodePref = (await prefs.getBool('barcode-button-preference'))!;
    _isPercentPref = (await prefs.getBool('discount-type-preference'))!;
    if(!barcodePref && widget.args!.editOrders!.isEmpty){
      _onAddManually(context);
    }

  }
  void _onAdd(OrderItemInput orderItem) {
    final qty = orderItem.quantity + 1;
    double discountForOneItem = double.parse(orderItem.discountAmt ?? "0") / orderItem.quantity;
    orderItem.discountAmt = (double.parse(orderItem.discountAmt ?? "0") + discountForOneItem).toStringAsFixed(2);
    final availableQty = orderItem.product?.quantity ?? 0;
    if (qty > availableQty) {
      locator<GlobalServices>().infoSnackBar("Quantity not available");
      return;
    }
    setState(() {
      orderItem.quantity = orderItem.quantity + 1;
      orderItem.quantity = roundToDecimalPlaces(orderItem.quantity, 4);
      orderItem.product?.quantityToBeSold = orderItem.quantity;
    });
  }
  void setQuantityToBeSold(OrderItemInput orderItem, double value,int index){
    final availableQty = orderItem.product?.quantity ?? 0;
    print("setting quantity to be sold: value is $value and available is $availableQty");
    if (value > availableQty) {
      locator<GlobalServices>().infoSnackBar("Quantity not available");
      return;
    }

    setState(() {
      if(value <=0 ){
        orderItem.quantity = 0;
        _Order.orderItems?[index].product?.quantityToBeSold = 0;
        _removeOrderItemFromKotList(index);//to remove product from kot list if value set to 0
        _Order.orderItems?.removeAt(index);
      }else{
        orderItem.quantity = value;
        orderItem.product?.quantityToBeSold = value;
        //check kotList if the product is not present then add it
        if(!Kotlist.any((element) => orderItem.product?.id == element.id)){
          Kotlist.add(orderItem.product!);
        }
      }
    });
  }
  void _removeOrderItemFromKotList(int index){
    for (int i = 0; i < Kotlist.length; i++) {
      if (Kotlist[i].id == _Order.orderItems![index].product!.id) {
        print("_Order.orderItems![index].product!.quantityToBeSold : ${_Order.orderItems![index].product!.quantityToBeSold}");
        if(_Order.orderItems![index].product!.quantityToBeSold! <= 0){
          print("removing kot from kotlist");
          Kotlist.removeAt(i);
        }
        break;
      }
    }
  }
  _onSubtotalChange(Product product, String? localSellingPrice) async {
    product.baseSellingPriceGst = localSellingPrice;
    double newGStRate = (double.parse(product.baseSellingPriceGst!) * double.parse(product.gstRate == 'null' ? '0' : product.gstRate!) / 100);
    product.saleigst = newGStRate.toStringAsFixed(2);

    product.salecgst = (newGStRate / 2).toStringAsFixed(2);
    print(product.salecgst);

    product.salesgst = (newGStRate / 2).toStringAsFixed(2);
    print(product.salesgst);

    product.sellingPrice = double.parse(product.baseSellingPriceGst!) + newGStRate;
  }

  _onTotalChange(Product product, String? discountedPrice) {
    product.sellingPrice = double.parse(discountedPrice!);
    print(product.gstRate);

    double newBasePrice = (product.sellingPrice! * 100.0) / (100.0 + double.parse(product.gstRate == 'null' ? '0.0' : product.gstRate!));

    print(newBasePrice);

    product.baseSellingPriceGst = newBasePrice.toString();

    double newGst = product.sellingPrice! - newBasePrice;

    print(newGst);

    product.saleigst = newGst.toStringAsFixed(2);

    product.salecgst = (newGst / 2).toStringAsFixed(2);
    print(product.salecgst);

    product.salesgst = (newGst / 2).toStringAsFixed(2);
    print(product.salesgst);
  }

  insertToDatabase(Billing provider) async {
    String kotId = DateTime.now().toString();
    if(widget.args!.kotId == null){//means it is a new order
      _Order.kotId = kotId;//so assigning new kot id
    }
    Kot _kot = Kot(kotId: _Order.kotId,items: []);
    List<Item> kotItems = [];
    // int id = await DatabaseHelper().InsertOrder(_Order, provider, newAddedItems!);

    //remove all from kotList, add all products from _Order to kotList while comparing to _currOrder
    // if(_prevOrder.orderItems!.length != 0){//no matter we can clear kot list anyway
    Kotlist.clear();
    // }
    for(int i = 0; i < _Order.orderItems!.length; i++){
      Product? product = _Order.orderItems?[i].product;
      product?.quantityToBeSold = _Order.orderItems?[i].quantity;
      // print("product name is ${product!.name} and quantity to be sold is ${product.quantityToBeSold}");
      String? productId = _Order.orderItems?[i].product?.id;
      //todo: all the working will be done by orderItems.quantity
      if(_prevOrder.orderItems!.any((element) => element.product!.id == productId)){//checks if product(with id 'productId') is present in _prevOrder.orderItems or not
        //check quantity
        //if increased then find how much quantity is increased and add that value
        //if decreased update it
        double quantityBefore = 0;
        for(int i = 0;i<_prevOrder.orderItems!.length;i++){//loop for getting what was the quantity before
          if(_prevOrder.orderItems?[i].product?.id == productId){
            quantityBefore = _prevOrder.orderItems![i].quantity;
          }
        }

        if((product!.quantityToBeSold! - quantityBefore)>0){//this means user have increased quantity of this product
          product.quantityToBeSold = product.quantityToBeSold! - quantityBefore;
          Kotlist.add(product);
        }else if ((product.quantityToBeSold! - quantityBefore)<0){//means user have decreased the quantity
          // DatabaseHelper().updateKotQuantity(widget.args!.id!, product.name!,product.quantityToBeSold!);
          //todo: user decreased the quantity here
          Item item = Item(name: product.name!, quantity: (product.quantityToBeSold! - quantityBefore), createdAt: DateTime.now());
          kotItems.add(item);
        }
      }else{
        //add the product as it is because it is new product added
        Kotlist.add(_Order.orderItems![i].product!);
      }
    }

    //if user is editing the order and have removed any products
    //checks from Previously saved Order and compares
    for(int i = 0;i<_prevOrder.orderItems!.length;i++){
      if(!_Order.orderItems!.any((element) => element.product?.id == _prevOrder.orderItems?[i].product?.id)){
        Item item = Item(name: _prevOrder.orderItems![i].product!.name!, quantity: -_prevOrder.orderItems![i].quantity, createdAt: DateTime.now());
        kotItems.add(item);
        // DatabaseHelper().deleteKot(widget.args!.id!, _prevOrder.orderItems![i].product!.name!);
      }
    }


    var tempMap = CountNoOfitemIsList(Kotlist);
    Kotlist.forEach((element) {
      if(tempMap['${element.id}'] > 0){//to remove those items which has 0 quantity in kotList
        //Making Item object for kot api
        Item item = Item(name: element.name, quantity: tempMap['${element.id}'], createdAt: DateTime.now());
        kotItems.add(item);

        // var model = KotModel(id, element.name!, tempMap['${element.id}'], "no");//for local database
        // kotItemlist.add(model);//for local database
      }
    });

    BillingCubit billingCubit = BillingCubit();
    //adding items to _kot object
    _kot.items = kotItems;
    if(widget.args!.kotId == null){
      await KOTService.createKot(_kot);
      await billingCubit.createBillingOrder(_Order);
    }else{
      await KOTService.updateKot(_kot);
      await billingCubit.updateBillingOrder(_Order);
    }
    // billingCubit.getBillingOrders();
    // print(resp);
    // DatabaseHelper().insertKot(kotItemlist);
  }

  @override
  Widget build(BuildContext context) {
    final _orderItems = _Order.orderItems ?? [];
    final provider = Provider.of<Billing>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          print("---sale page popped---");
          // if(widget.args?.id! != ""){//if user is editing a sale by billing page
          //   print("--deleting and adding sales bill in provider--");
          //   provider.removeSalesBillItems(_Order.id!);
          //   provider.addSalesBill(_prevOrder, _Order.id!);
          // }
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BarcodeKeyboardListener(
            useKeyDownEvent: true,
            bufferDuration: Duration(seconds: 4),
            onBarcodeScanned: (barcode) async {
              try{
                await _searchProductByBarcode(barcode);
              }catch(e){
                print(e);
              }
              setState(() {});
            },
            child: Column(
              children: [
                Expanded(
                  child: _orderItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No products added yet',
                          ),
                        )
                      : GridView.builder(
                          physics: ClampingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 200),
                          itemCount: _orderItems.length,
                          itemBuilder: (context, index) {
                            var basesellingprice = 0.0;
                            if (_orderItems[index].product!.baseSellingPriceGst != null && _orderItems[index].product!.baseSellingPriceGst != "null")
                             basesellingprice = double.parse(_orderItems[index].product!.baseSellingPriceGst!);
                            return GestureDetector(
                              onLongPress: () {
                                showaddDiscountDialouge(_orderItems, index);
                              },
                              child: ProductCardPurchase(
                                type: "sale",
                                product: _orderItems[index].product!,
                                discount: _orderItems[index].discountAmt ?? "0.0",
                                onQuantityFieldChange: (double value){

                                  setState(() {
                                    setQuantityToBeSold(_orderItems[index], value, index);
                                  });
                                },
                                onAdd: () {
                                  print("toched");
                                  Kotlist.add(_Order.orderItems![index].product!);
                                  _onAdd(_orderItems[index]);
                                  setState(() {});
                                },
                                onDelete: () {
                                  // context.read<KotCubit>().deleteKot(_Order.id.toString(), _Order.orderItems![index].product!.name!);

                                  setState(() {
                                    double discountForOneItem = double.parse(_orderItems[index].discountAmt!) / _orderItems[index].quantity;
                                    _orderItems[index].discountAmt = (double.parse(_orderItems[index].discountAmt!) - discountForOneItem).toStringAsFixed(2);
                                    if(_orderItems[index].quantity <= 1){
                                      _orderItems[index].quantity = 0;
                                      _Order.orderItems?[index].product?.quantityToBeSold = 0;

                                      for (int i = 0; i < Kotlist.length; i++) {
                                        if (Kotlist[i].id == _Order.orderItems![index].product!.id) {
                                          if((_Order.orderItems![index].product!.quantityToBeSold ?? 0) <= 0){
                                            Kotlist.removeAt(i);
                                          }
                                          break;
                                        }
                                      }

                                      _Order.orderItems?.removeAt(index);
                                    }else{
                                      _orderItems[index].quantity = _orderItems[index].quantity - 1;
                                      _orderItems[index].quantity = roundToDecimalPlaces(_orderItems[index].quantity, 4);
                                      _orderItems[index].product?.quantityToBeSold = _orderItems[index].quantity;
                                    }
                                  },);
                                },
                                productQuantity: _orderItems[index].quantity,
                              ),
                            );
                          },
                        ),
                ),
                const Divider(color: Colors.transparent),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      title: "Add manually",
                      onTap: () async {
                       _onAddManually(context);
                      },
                    ),
                      CustomButton(
                      title: "Continue",
                      onTap: () async {
                        print("skip pending order value $skipPendingOrdersPref");
                          if (_orderItems.isNotEmpty && skipPendingOrdersPref==false) {
                            // print('orderid: ${widget.args?.orderId}');
                            await insertToDatabase(provider);
                            Navigator.pushNamed(context, BillingListScreen.routeName, arguments: OrderType.sale);
                          }else if(_orderItems.isEmpty && skipPendingOrdersPref==false){
                            Navigator.pushNamed(context, BillingListScreen.routeName, arguments: OrderType.sale);
                          }else if(_orderItems.isNotEmpty && skipPendingOrdersPref){
                            Navigator.pushNamed(
                                context,
                                CheckoutPage.routeName,
                                arguments: CheckoutPageArgs(invoiceType: OrderType.sale, order: _Order)
                            );
                          }else{
                            locator<GlobalServices>().errorSnackBar('No products added !');
                          }
                      },
                    ),
                    CustomButton(
                      title: "Scan barcode",
                      onTap: () async {},
                      type: ButtonType.outlined,
                    ),
                  ],
                ),
                const Divider(color: Colors.transparent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //
  Future<void> _searchProductByBarcode(String barcode) async {
    print("executing search product by barcode");
    // locator<GlobalServices>().showBottomSheetLoader();
    // final barcode = await FlutterBarcodeScanner.scanBarcode(
    //   "#000000",
    //   "Cancel",
    //   false,
    //   ScanMode.BARCODE,
    // );
    // const _type = FeedbackType.success;
    // Vibrate.feedback(_type);
    // await _audioCache.play('audio/beep.mp3');

      /// Fetch product by barcode
      String barcodeTrimmed = barcode.replaceAll(RegExp(r"\s"), "");//removes blank spaces from the barcode
      print("barcode in function is $barcodeTrimmed");
      final res = await ProductService().getProductByBarcode(barcodeTrimmed);
      final product = Product.fromMap(res.data['inventory']);
      final order = OrderItemInput(product: product, quantity: 1, price: 0);
      bool? hasProduct = _Order.orderItems?.any((e) => e.product?.id == product.id);
      /// Check if product already exists
      if (hasProduct ?? false) {
        // final i = _Order.orderItems?.indexWhere((e) => e.product?.id == product.id);
        //
        // /// Increase quantity if product already exists
        // setState(() {
        //   _Order.orderItems![i!].quantity += 1;
        // });
        locator<GlobalServices>().infoSnackBar("Product already present");
      } else {
        setState(() {
          _Order.orderItems?.add(order);
        });
      }
      hasProduct=false;


  }

  Map CountNoOfitemIsList(List<Product> temp) {
    var tempMap = {};

    for (int i = 0; i < temp.length; i++) {
      // int count = 1;
      print("---countNoofItemisLlist---");
      print(temp[i].name);
      print(temp[i].id);
      print(temp[i].quantityToBeSold);
      print(temp[i].quantity);
      if (!tempMap.containsKey("${temp[i].id}")) {
        temp[i].quantityToBeSold = roundToDecimalPlaces(temp[i].quantityToBeSold!, 4);
        if(temp[i].quantityToBeSold != 0)
          tempMap["${temp[i].id}"] = temp[i].quantityToBeSold;
      }
    }
    print("temp map is $tempMap");

    for (int i = 0; i < temp.length; i++) {
      for (int j = i + 1; j < temp.length; j++) {
        if (temp[i].id == temp[j].id) {
          temp.removeAt(j);
          j--;
        }
      }
    }

    return tempMap;
  }

  void _onAddManually(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      SearchProductListScreen.routeName,
      arguments: ProductListPageArgs(isSelecting: true, orderType: OrderType.sale, productlist: _Order.orderItems!),
    );
    if (result == null && result is! List<Product>) {
      return;
    }

    var temp = result as List<Product>;

    Kotlist.addAll(temp);

    var tempMap = CountNoOfitemIsList(temp);
    final orderItems = temp
        .map((e) => OrderItemInput(
              product: e,
              quantity: tempMap["${e.id}"].toDouble(),
              price: 0,
            ))
        .toList();

    var tempOrderItems = _Order.orderItems;//tempOrderItems contains the existing add orders in create sale page

    for (int i = 0; i < tempOrderItems!.length; i++) {
      for (int j = 0; j < orderItems.length; j++) {
        if (tempOrderItems[i].product!.id == orderItems[j].product!.id) {
          // tempOrderItems[i].product!.quantity = tempOrderItems[i].product!.quantity! - orderItems[j].quantity;
          tempOrderItems[i].quantity = tempOrderItems[i].quantity + orderItems[j].quantity;
          tempOrderItems[i].quantity = roundToDecimalPlaces(tempOrderItems[i].quantity, 4);
          tempOrderItems[i].product?.quantityToBeSold = (tempOrderItems[i].product?.quantityToBeSold ?? 0) + (orderItems[j].product?.quantityToBeSold ?? 0);
          tempOrderItems[i].product?.quantityToBeSold = roundToDecimalPlaces(tempOrderItems[i].product!.quantityToBeSold!, 4);
          orderItems.removeAt(j);
        }
      }
    }

    _Order.orderItems = tempOrderItems;

    setState(() {
      _Order.orderItems?.addAll(orderItems);
 
      newAddedItems!.addAll(orderItems);
    });
  }
  double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
  void showaddDiscountDialouge(List<OrderItemInput> _orderItems, int index) async {
    final _orderItem = _orderItems[index];

    double discount = double.parse(_orderItem.discountAmt!);
    final product = _orderItems[index].product!;
    final tappedProduct = await ProductService().getProduct(_orderItems[index].product!.id!);
    final productJson = Product.fromMap(tappedProduct.data['inventory']);
    final baseSellingPriceToShow = productJson.baseSellingPriceGst;
    final sellingPriceToShow = productJson.sellingPrice;
    showDialog(
        useSafeArea: true,
        useRootNavigator: true,
        context: context,
        builder: (ctx) {
          String? localSellingPrice;
          String? discountedPrice;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlertDialog(
                content: Column(
                  children: [
                    Text(
                      "Discount",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      inputType: TextInputType.number,
                        onChanged: (val) {
                          if(_isPercentPref) {
                            double? taxableValue = ((_orderItem.product!
                                .gstRate != "null" && _orderItem.product!
                                .gstRate != "")
                                ? double.parse(baseSellingPriceToShow as String)
                                : sellingPriceToShow);
                            localSellingPrice = (taxableValue! - double.parse(
                                val) / 100 * taxableValue).toString();
                          }
                          else localSellingPrice = val;
                          print("LOCAL SELLING PRICE: $localSellingPrice");
                        },
                        suffixIcon: _isPercentPref ?Icon(Icons.percent) : null,
                        hintText: 'Enter Taxable Value   (${_orderItem.product!.gstRate != "null"  && _orderItem.product!.gstRate!="" ?
                        baseSellingPriceToShow : sellingPriceToShow})'
                    ),
                    _orderItem.product!.gstRate != "null" && _orderItem.product!.gstRate!=""?
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('or'),
                    ) : SizedBox.shrink(),
                    _orderItem.product!.gstRate != "null"  && _orderItem.product!.gstRate!="" ?
                    CustomTextField(
                      suffixIcon: _isPercentPref ? Icon(Icons.percent) : null,
                      inputType: TextInputType.number,
                      onChanged: (val) {
                        if(_isPercentPref) {
                          discountedPrice = (sellingPriceToShow! - double.parse(
                              val) / 100 * sellingPriceToShow).toString();
                        }
                        else discountedPrice = val;
                        print("DISCOUNTED PRICE: $discountedPrice");
                      },
                      hintText: 'Enter total value   (${sellingPriceToShow})',
                      validator: (val) {
                        if (val!.isNotEmpty && localSellingPrice!.isNotEmpty) {
                          return 'Do not fill both fields';
                        }
                        return null;
                      },
                    ) : SizedBox.shrink(),
                  ],
                ),
                actions: [
                  Center(
                    child: CustomButton(
                        title: 'Submit',
                        onTap: () {
                          if (localSellingPrice != null) {
                            print(localSellingPrice);
                            print(discountedPrice);
                            // print("----line 463---in createsale.dart");
                            // print(basesellingprice);
                            // print(_orderItem.product!.baseSellingPriceGst!);
                            if(_orderItem.product!.baseSellingPriceGst =="null"){
                              print("---line 467 in createsale.dart");
                              discount = (_orderItem.product!.sellingPrice!  + double.parse(_orderItem.discountAmt!) - double.parse(localSellingPrice!).toDouble()) * _orderItem.quantity;

                            }else{
                              print("---line 470 in createsale.dart");
                              discount = (double.parse(_orderItem.product!.baseSellingPriceGst!) + double.parse(_orderItem.discountAmt!) - double.parse(localSellingPrice!).toDouble()) * _orderItem.quantity;
                            }

                            _orderItems[index].discountAmt = discount.toStringAsFixed(2);
                            setState(() {});
                          }

                          if (localSellingPrice != null && localSellingPrice!.isNotEmpty) {
                            _onSubtotalChange(product, localSellingPrice);
                            setState(() {});
                          } else if (discountedPrice != null) {
                            print('s$discountedPrice');

                            double realBaseSellingPrice = double.parse(_orderItem.product!.baseSellingPriceGst!);

                            _onTotalChange(product, discountedPrice);
                            print("realbase selling price=${realBaseSellingPrice}");
                            print("discount=${discount}");
                            discount = (realBaseSellingPrice + (discount/_orderItem.quantity) - double.parse(_orderItem.product!.baseSellingPriceGst!)) * _orderItem.quantity;
                            _orderItems[index].discountAmt = discount.toStringAsFixed(2);

                            setState(() {});
                          }

                          Navigator.of(ctx).pop();
                        }),
                  )
                ],
              ),
            ],
          );
        });
  }
}
