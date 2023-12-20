// import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
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

import '../services/product.dart';

class BillingPageArgs {
  final String? orderId;
  final List<OrderItemInput>? editOrders;
  final id;

  BillingPageArgs({this.orderId, this.editOrders, this.id});
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
  // late final AudioCache _audioCache;
  List<OrderItemInput>? newAddedItems = [];
  List<Product> Kotlist = [];
  bool isLoading = false;
  double discount = 0;
  List<String> sellingPriceListForShowinDiscountTextBOX = [];
  @override
  void initState() {
    super.initState();
    // _audioCache = AudioCache(
    //   fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    // );
    _Order = Order(
      id: widget.args == null ? "" : widget.args!.id,
      orderItems: widget.args == null ? [] : widget.args?.editOrders,
    );
  }

  void _onAdd(OrderItemInput orderItem) {
    final qty = orderItem.quantity + 1;
    final availableQty = orderItem.product?.quantity ?? 0;
    if (qty > availableQty) {
      locator<GlobalServices>().infoSnackBar("Quantity not available");
      return;
    }
    setState(() {
      orderItem.quantity += 1;
    });
  }

  _onSubtotalChange(Product product, String? localSellingPrice) async {
    product.baseSellingPriceGst = localSellingPrice;
    double newGStRate = (double.parse(product.baseSellingPriceGst!) * double.parse(product.gstRate!) / 100);
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

  void insertToDatabase(Billing provider) async {
    DateTime date = DateTime.now();
    print("value of orderid=${_Order.id}");
    _Order.id = _Order.id == "" ? date.toString() : _Order.id.toString();
    provider.addSalesBill(
      _Order,
      _Order.id == "" ? date.toString() : _Order.id!,
    );
    print("idddddddd=$date");
    List<KotModel> kotItemlist = [];
    var tempMap = CountNoOfitemIsList(Kotlist);

    print(Kotlist);
    Kotlist.forEach((element) {
      var model = KotModel(_Order.id == "" ? date.toString() : _Order.id!, element.name!, tempMap['${element.id}'], "no");
      kotItemlist.add(model);
    });

    context.read<KotCubit>().insertKot(kotItemlist);
    //  DatabaseHelper().insertKot(kotItemlist);
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                         basesellingprice = double.parse(_orderItems[index].product!.baseSellingPriceGst ?? "0.0");
                        return GestureDetector(
                          onLongPress: () {
                            showaddDiscountDialouge(basesellingprice, _orderItems, index);
                          },
                          child: ProductCardPurchase(
                            type: "sale",
                            product: _orderItems[index].product!,
                            discount: _orderItems[index].discountAmt,
                            onAdd: () {
                              print("toched");
                              Kotlist.add(_Order.orderItems![index].product!);
                              _onAdd(_orderItems[index]);
                              setState(() {});
                            },
                            onDelete: () {
                              context.read<KotCubit>().deleteKot(_Order.id.toString(), _Order.orderItems![index].product!.name!);

                              setState(
                                () {
                                  _orderItems[index].quantity == 1 ? _Order.orderItems?.removeAt(index) : _orderItems[index].quantity -= 1;
                                },
                              );

                              for (int i = 0; i < Kotlist.length; i++) {
                                if (Kotlist[i].id == _Order.orderItems![index].product!.id) {
                                  Kotlist.removeAt(i);

                                  break;
                                }
                              }

                              if (widget.args!.orderId == null) setState(() {});
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
             
                      final provider =
                          Provider.of<Billing>(context, listen: false);
                            print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj ${_Order.id}");
                      if (_orderItems.isNotEmpty) {
                        provider.addSalesBill(
                            _Order,
                            widget.args?.orderId == ""
                                ? DateTime.now().toString()
                                : widget.args!.orderId!);
                      }

                      Navigator.pushNamed(context, BillingListScreen.routeName,
                          arguments: OrderType.sale);
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
    );
  }

  //
  Future<void> _searchProductByBarcode() async {
    locator<GlobalServices>().showBottomSheetLoader();
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      "#000000",
      "Cancel",
      false,
      ScanMode.BARCODE,
    );
    const _type = FeedbackType.success;
    Vibrate.feedback(_type);
    // await _audioCache.play('audio/beep.mp3');
    try {
      /// Fetch product by barcode
      final res = await const ProductService().getProductByBarcode(barcode);
      final product = Product.fromMap(res.data['inventory']);
      final order = OrderItemInput(product: product, quantity: 1, price: 0);
      final hasProduct = _Order.orderItems?.any((e) => e.product?.id == product.id);

      /// Check if product already exists
      if (hasProduct ?? false) {
        final i = _Order.orderItems?.indexWhere((e) => e.product?.id == product.id);

        /// Increase quantity if product already exists
        setState(() {
          _Order.orderItems![i!].quantity += 1;
        });
      } else {
        setState(() {
          _Order.orderItems?.add(order);
        });
      }
    } catch (_) {}
    Navigator.pop(context);
  }

  Map CountNoOfitemIsList(List<Product> temp) {
    var tempMap = {};

    for (int i = 0; i < temp.length; i++) {
      int count = 1;
      if (!tempMap.containsKey("${temp[i].id}")) {
        for (int j = i + 1; j < temp.length; j++) {
          if (temp[i].id == temp[j].id) {
            count++;
            print("count =$count");
          }
        }
        tempMap["${temp[i].id}"] = count;
      }
    }

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

    temp.forEach((element) {
     sellingPriceListForShowinDiscountTextBOX.add(element.sellingPrice.toString());
    });

    Kotlist.addAll(temp);

    var tempMap = CountNoOfitemIsList(temp);
    final orderItems = temp
        .map((e) => OrderItemInput(
              product: e,
              quantity: tempMap["${e.id}"],
              price: 0,
            ))
        .toList();

    var tempOrderitems = _Order.orderItems;

    for (int i = 0; i < tempOrderitems!.length; i++) {
      for (int j = 0; j < orderItems.length; j++) {
        if (tempOrderitems[i].product!.id == orderItems[j].product!.id) {
          tempOrderitems[i].product!.quantity = tempOrderitems[i].product!.quantity! - orderItems[j].quantity;
          tempOrderitems[i].quantity = tempOrderitems[i].quantity + orderItems[j].quantity;
          orderItems.removeAt(j);
        }
      }
    }

    _Order.orderItems = tempOrderitems;

    setState(() {
      _Order.orderItems?.addAll(orderItems);
 
      newAddedItems!.addAll(orderItems);
    });
  }

  void showaddDiscountDialouge(double basesellingprice, List<OrderItemInput> _orderItems, int index) {
    final _orderItem = _orderItems[index];

    double discount = double.parse(_orderItem.discountAmt);
    final product = _orderItems[index].product!;
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
                        localSellingPrice = val;
                      },
                      hintText: 'Enter Taxable Value   (${basesellingprice + discount})',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('or'),
                    ),
                    CustomTextField(
                      inputType: TextInputType.number,
                      onChanged: (val) {
                        discountedPrice = val;
                      },
                      hintText: 'Enter total value   (${sellingPriceListForShowinDiscountTextBOX[index]})',
                      validator: (val) {
                        if (val!.isNotEmpty && localSellingPrice!.isNotEmpty) {
                          return 'Do not fill both fields';
                        }
                        return null;
                      },
                    ),
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

                            discount = (double.parse(_orderItem.product!.baseSellingPriceGst!) + double.parse(_orderItem.discountAmt) - int.parse(localSellingPrice!).toDouble()) * _orderItem.quantity;

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
                            discount = (realBaseSellingPrice + discount - double.parse(_orderItem.product!.baseSellingPriceGst!)) * _orderItem.quantity;
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
