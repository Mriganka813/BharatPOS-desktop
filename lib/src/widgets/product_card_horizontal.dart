import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/services/product_availability_service.dart';
import 'package:shopos/src/widgets/custom_button.dart';

import '../services/global.dart';
import '../services/locator.dart';

class ProductCardHorizontal extends StatefulWidget {
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback? reduceQuantity;
  final VoidCallback? addQuantity;
  final int selectQuantity;
  final bool? isSelecting;
  OrderType type;
  Function onAdd;
  Function onRemove;
  Function onTap;
  bool isAvailable;
  Function onQuantityFieldChange;
  double noOfQuatityadded;

  ProductCardHorizontal({
    Key? key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.onCopy,
    this.isSelecting = false,
    required this.type,
    this.addQuantity,
    this.reduceQuantity,
    this.selectQuantity = 0,
    this.isAvailable = true,
    this.noOfQuatityadded = 0,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
    required this.onQuantityFieldChange
  }) : super(key: key);
  @override
  State<ProductCardHorizontal> createState() => _ProductCardHorizontalState();
}

class _ProductCardHorizontalState extends State<ProductCardHorizontal> {
  double itemQuantity = 0;
  TextEditingController _itemQuantityController = TextEditingController();
  String? errorText;
  ProductAvailabilityService productAvailability = ProductAvailabilityService();
  bool onTapOutsideWillWork = false;
  bool tapflag = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemQuantity = widget.noOfQuatityadded;
    _itemQuantityController.text = itemQuantity.toString();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(itemQuantity<=1){//on tap function will only work if item quantity less than equal to 1
          //This entire logi below is written add the functionality of
          //this logic is done becasue when we press the card only the (+-) button should show and should add item
          //then when we again press the card the opposite should happen
          print("itemQuantity on tap= $itemQuantity");

          print("tap flag is $tapflag");
          widget.onTap(itemQuantity);
          if (tapflag) if (itemQuantity <= 1) {
            itemQuantity = 0;
            _itemQuantityController.text = itemQuantity.toString();
          }

          if (!tapflag) {
            if (widget.product.quantity! >= 99000 && widget.type == OrderType.purchase) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "Total quantity can't exceed 99999",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
              tapflag = !tapflag;
              itemQuantity = 1;
              _itemQuantityController.text = itemQuantity.toString();
              widget.onTap(itemQuantity);
              itemQuantity = 0;
              _itemQuantityController.text = itemQuantity.toString();
            } else{
              print("in else part 107 line ");
              if(widget.type == OrderType.sale && widget.product.quantity == 0){

              }else{
                itemQuantity = 1;
                _itemQuantityController.text = itemQuantity.toString();
              }

            }
          }

          tapflag = !tapflag;
          setState(() {});
          print("no of quantity added is ${widget.noOfQuatityadded}");
          print("item quantity value after set state on tap is $itemQuantity");
        }

      },
      child: SizedBox(
        height: 250,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: widget.product.image != null
                        ? CachedNetworkImage(
                            imageUrl: widget.product.image!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset('assets/images/image_placeholder.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.25,
                        alignment: Alignment.center,
                        child: Text(
                          widget.product.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Divider(color: Colors.black54),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Available'),
                          Text(
                            widget.product.quantity == null || widget.product.quantity! > 9999 ? 'Unlimited' : '${widget.product.quantity?.toStringAsFixed(3)}',
                          ),
                        ],
                      ),
                      Visibility(
                        visible: widget.product.gstRate != "null",
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Price'),
                                Text('₹ ${widget.product.baseSellingPriceGst}'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('GST @${widget.product.gstRate}%'),
                                Text('₹ ${widget.product.saleigst}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Net Price'),
                          Text('₹ ${widget.product.sellingPrice}'),
                        ],
                      ),

                      Visibility(
                        visible:
                            (itemQuantity > 0 && widget.isSelecting == true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                               bool flag = true;
                                bool flag2 = true;
                                if (widget.product.quantity! >= 99000&&widget.type==OrderType.purchase) {

                                    ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                       "Total quantity can't exceed 99999",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),);
                                 /* _showError(
                                     "Total quantity can't exceed 99999");*/

                                  flag = false;
                                }

                                if (itemQuantity >= 999&&widget.type==OrderType.purchase) {

                                  
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "Total quantity can't exceed 999",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),);
                                 /* _showError(
                                      "Total quantity can't exceed 999");*/
                                  flag2 = false;
                                }

                               if (flag && flag2) {
                                 setState(() {
                                   itemQuantity = itemQuantity + 1;
                                   itemQuantity = roundToDecimalPlaces(itemQuantity, 4);

                                   _itemQuantityController.text = itemQuantity.toString();
                                 });
                                 widget.onAdd(itemQuantity);
                               }
                              },
                              icon:
                                  const Icon(Icons.add_circle_outline_rounded),
                            ),
                            Container(
                              width: 80,
                              child: TextFormField(
                                controller: _itemQuantityController,
                                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                                decoration: InputDecoration(
                                  fillColor: Colors.grey[200], // Light grey background color
                                  filled: true,  // Fill the background
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15), // Set your desired corner radius
                                    borderSide: BorderSide.none, // Make the border invisible
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                                ),
                                onTapOutside: (e){
                                  if(onTapOutsideWillWork){
                                    print("tapped out side");
                                    print(e);
                                    if(_itemQuantityController.text.isNotEmpty){
                                      print("double.parse(controller text) is ${double.parse(_itemQuantityController.text)}");
                                      itemQuantity = double.parse(_itemQuantityController.text);
                                      print("item quantity on tap outside is $itemQuantity");
                                      widget.onQuantityFieldChange(itemQuantity);
                                    }
                                    onTapOutsideWillWork = false;
                                  }
                                },
                                onFieldSubmitted: (e){
                                  if(e.isNotEmpty){
                                    // _itemQuantityController.text = e;
                                    itemQuantity = double.parse(_itemQuantityController.text);
                                    widget.onQuantityFieldChange(itemQuantity);
                                  }
                                },
                                onChanged: (e){
                                  //TODO: implement validation
                                  onTapOutsideWillWork = true;
                                  if(e.contains('-')){
                                    print("negative value");
                                    locator<GlobalServices>().errorSnackBar("Negative quantity not allowed");
                                    // errorText = "negative value";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (itemQuantity <= 1) {
                                  tapflag = !tapflag;
                                }

                                setState(() {
                                  if(itemQuantity <= 1){
                                    itemQuantity = 0;
                                  }else{
                                    itemQuantity = itemQuantity - 1;
                                    itemQuantity = roundToDecimalPlaces(itemQuantity, 4);
                                  }
                                  _itemQuantityController.text = itemQuantity.toString();
                                  widget.onRemove(itemQuantity);
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline_rounded),
                            ),
                          ],
                        ),
                      ),

                      // previous version (will use after sometime)
                      // Text('${product.quantity} pcs'),
                      // // const SizedBox(height: 2),
                      // // Text(color),
                      // const SizedBox(height: 2),
                      // product.purchasePrice != 0
                      //     ? Text('Purchase Price ${product.purchasePrice}')
                      //     : Container(),
                      // const SizedBox(height: 2),
                      // Text('Sale Price ${product.sellingPrice}'),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PopupMenuButton<int>(
                      child: const Icon(Icons.more_vert_rounded),
                      onSelected: (int e) {
                        if (e == 0) {
                          widget.onEdit();
                        } else if (e == 1) {
                          widget.onDelete();
                        } else if(e == 2) {
                          widget.onCopy();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuItem<int>>[
                          const PopupMenuItem<int>(
                            value: 0,
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<int>(
                            value: 2,
                            child: Text('Copy'),
                          ),
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        ];
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
  Future<bool?> _showError(String error) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              content: Text(error),
              title: Row(
                children: [
                  Expanded(child: Text('Alert')),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Icon(Icons.close))
                ],
              ),
              actions: [
                Center(
                    child: Container(
                  width: 200,
                  height: 40,
                  child: CustomButton(
                      title: 'Ok',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      onTap: () async {
                        Navigator.of(ctx).pop(false);
                      }),
                ))
              ],
            ));
  }
}

class ProductCardPurchase extends StatefulWidget {
  final Product product;
  double productQuantity;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final String? type;
  String discount;
  Function? onQuantityFieldChange;
  ProductCardPurchase(
      {Key? key,
      required this.product,
      required this.onAdd,
      required this.productQuantity,
      required this.onDelete,
      this.discount="",
        this.onQuantityFieldChange,
      this.type})
      : super(key: key);

  @override
  State<ProductCardPurchase> createState() => _ProductCardPurchaseState();
}

class _ProductCardPurchaseState extends State<ProductCardPurchase> {
  double baseSellingPrice = 0;
  double Sellinggstvalue = 0;
  double SellingPrice = 0;
  bool onTapOutSideWillWork=false;
  double basePurchasePrice = 0;
  double Purchasegstvalue = 0;
  double PurchasePrice = 0;
  TextEditingController _itemQuantityController = TextEditingController();
  String? errorText;


  @override
  void initState() {
    super.initState();
    print(widget.product.quantityToBeSold);
    print(widget.productQuantity);

  }
  double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }

  @override
  Widget build(BuildContext context) {
    _itemQuantityController.text = widget.productQuantity.toString();

    if (widget.type == "sale" || widget.type == "estimate") {
      if (widget.product.gstRate != "null") {
        baseSellingPrice = double.parse((double.parse(widget.product.baseSellingPriceGst!) * widget.productQuantity).toStringAsFixed(2));
        Sellinggstvalue = double.parse((double.parse(widget.product.saleigst!) * widget.productQuantity).toStringAsFixed(2));
      }
      if (widget.product.gstRate == "null") {
        baseSellingPrice = double.parse((widget.product.sellingPrice! * widget.productQuantity).toDouble().toStringAsFixed(2));
      }
      SellingPrice = (widget.product.sellingPrice! * widget.productQuantity);
    }

    if (widget.type == "purchase") {
      if (widget.product.purchasePrice != 0 && widget.product.gstRate != "null") {
        basePurchasePrice = double.parse((double.parse(widget.product.basePurchasePriceGst!) * widget.productQuantity).toStringAsFixed(2));
        Purchasegstvalue = double.parse((double.parse(widget.product.purchaseigst!) * widget.productQuantity).toStringAsFixed(2));
      } else {
        basePurchasePrice = double.parse((widget.product.purchasePrice * widget.productQuantity).toDouble().toStringAsFixed(2));
      }
      PurchasePrice = widget.product.purchasePrice * widget.productQuantity;
    }

    return SizedBox(
      height: 200,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: widget.product.image != null
                        ? Container(
                            height: 120,
                            child: CachedNetworkImage(
                              imageUrl: widget.product.image!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset('assets/images/image_placeholder.png'),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.onAdd();
                          _itemQuantityController.text = (double.parse(_itemQuantityController.text)+1).toString();
                          _itemQuantityController.text = roundToDecimalPlaces(double.parse(_itemQuantityController.text), 4).toString();
                          setState(() {});
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                      Container(
                        width: 70,
                        child: TextFormField(
                          controller: _itemQuantityController,
                          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                          decoration: InputDecoration(
                            fillColor: Colors.grey[200], // Light grey background color
                            filled: true,  // Fill the background
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), // Set your desired corner radius
                              borderSide: BorderSide.none, // Make the border invisible
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                          ),
                          onFieldSubmitted: (e){
                            if(e.isNotEmpty)
                              print("double.parse is ${double.parse(_itemQuantityController.text)}");
                            widget.productQuantity = double.parse(_itemQuantityController.text);
                            print("item quantity on field submitted is ${widget.productQuantity}");
                            if(widget.onQuantityFieldChange != null)
                              widget.onQuantityFieldChange!(widget.productQuantity);
                          },
                          onTapOutside: (e){
                            if(onTapOutSideWillWork){
                              print("tapped out side");
                              print(e);
                              if(_itemQuantityController.text.isNotEmpty){
                                print("double.parse(controller text) is ${double.parse(_itemQuantityController.text)}");
                                widget.productQuantity = double.parse(_itemQuantityController.text);
                                print("item quantity on tap outside is ${widget.productQuantity}");
                                if(widget.onQuantityFieldChange != null)
                                  widget.onQuantityFieldChange!(widget.productQuantity);
                              }
                              onTapOutSideWillWork=false;
                            }
                          },
                          onChanged: (e){
                            onTapOutSideWillWork=true;
                            if(e.contains('-')){
                              print("negative value");
                              locator<GlobalServices>().errorSnackBar("Negative quantity not allowed");
                              // errorText = "negative value";
                            }

                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          widget.onDelete();
                          _itemQuantityController.text = (double.parse(_itemQuantityController.text)-1).toString();
                          _itemQuantityController.text = roundToDecimalPlaces(double.parse(_itemQuantityController.text), 4).toString();
                          setState(() {});
                        },
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                    ],
                  ),
                  // Text('Available : ${product.quantity ?? 0}'),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 3.0,
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              widget.product.name ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black54,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text('Amount'),
                        (widget.type == "sale" ||widget.type == "estimate") ? Text('₹ ${(baseSellingPrice + double.parse(widget.discount)).toStringAsFixed(2)}') : Text('₹ ${basePurchasePrice}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Tax GST @${widget.product.gstRate == "null" ? "0" : widget.product.gstRate}%'),
                        widget.type == "sale" || widget.type == "estimate"
                            ? Text('₹ ${Sellinggstvalue}')
                            : Text('₹ ${Purchasegstvalue}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text('Discount @0%'),
                        Text('₹ ${widget.discount}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Total'),
                        widget.type == "sale" || widget.type == "estimate"
                            ? Text(
                                '₹ ${SellingPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : Text(
                                '₹ ${PurchasePrice.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                      ],
                    ),
                    // const SizedBox(height: 10),

                    // // const SizedBox(height: 2),
                    // // Text(color),
                    // const SizedBox(height: 2),
                    // Text('Purchase Price ${product.purchasePrice}'),
                    // const SizedBox(height: 2),
                    // Text('Sale Price ${product.sellingPrice}'),
                    // const SizedBox(height: 2),
                    // Text('Qty ${product.quantity ?? 0}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
