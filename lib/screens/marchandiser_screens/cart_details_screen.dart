import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:marchandise/provider/product_details_provider.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/willpop.dart';
import 'package:marchandise/model/cart_details_model.dart';
import 'package:marchandise/provider/cart_provider.dart';
import 'package:marchandise/screens/marchandiser_screens/cart_screen.dart';

class CartDetailsScreen extends StatefulWidget {
  const CartDetailsScreen({super.key});

  @override
  State<CartDetailsScreen> createState() => _CartDetailsScreenState();
}

class _CartDetailsScreenState extends State<CartDetailsScreen> {
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonTextController = TextEditingController();
  List<CartDetailsItem> itemList = [];
  DateTime? _selectedDate;
  late Willpop willpop;
  bool _isQuantityValid = true;
  bool _isExpiryDateValid = true;
  String? _selectedReason;
  bool _showReasonText = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    willpop = Willpop(context);
    _quantityController.dispose();
    _expiryDateController.dispose();
    _reasonTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var productDetailsProvider = Provider.of<ProductDetailsProvider>(context);
    dynamic? productId = productDetailsProvider.productId;
    dynamic? productName = productDetailsProvider.productName;
    dynamic? UOM = productDetailsProvider.UOM;
    dynamic? productCost = productDetailsProvider.Cost;

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return willpop.onWillPop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.purple,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
          title: Text(
            "Details",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: screenWidth * 0.05,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.04),
              child: GestureDetector(
                onTap: () {
                  DynamicAlertBox().logOut(context, "Do you Want to Logout",
                      () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => SplashScreen(),
                    ));
                  });
                },
                child: CircleAvatar(
                  radius: screenWidth * 0.06,
                  child: Text("MR"),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productDetailsProvider.productName ?? "",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'ItemCode : ${productDetailsProvider.productId.toString()}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                'UOM : ${productDetailsProvider.UOM.toString()}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                'Price : ${productDetailsProvider.Cost.toString()}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quantity",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _isQuantityValid
                                      ? Colors.grey
                                      : Colors.red),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _quantityController,
                              decoration: InputDecoration(
                                hintText: "Enter quantity",
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _isQuantityValid = value.isNotEmpty;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Expiry Date",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _isExpiryDateValid
                                      ? Colors.grey
                                      : Colors.red),
                            ),
                            child: TextButton(
                              onPressed: () {
                                _selectDate(context);
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _selectedDate == null
                                      ? "Select Date"
                                      : DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate!),
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reason",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              hint: Text("Select Reason"),
                              value: _selectedReason,
                              items: [
                                DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text("Excess Stock"),
                                    ],
                                  ),
                                  value: "EXCESS STOCK",
                                ),
                                DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text("Expired Goods"),
                                    ],
                                  ),
                                  value: "EXPIRED GOODS",
                                ),
                                DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text("Near Expiry Goods"),
                                    ],
                                  ),
                                  value: "NEAR EXPIRY GOODS",
                                ),
                                DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text("Damage"),
                                    ],
                                  ),
                                  value: "DAMAGE",
                                ),
                                DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text("Promo Returns"),
                                    ],
                                  ),
                                  value: "PROMO RETURNS",
                                ),
                                DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text("Other"),
                                    ],
                                  ),
                                  value: "Other",
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedReason = value;
                                  _showReasonText = value == "Other";
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_showReasonText)
                        SizedBox(height: screenHeight * 0.02),
                      if (_showReasonText)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Please specify reason",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: TextFormField(
                                controller: _reasonTextController,
                                decoration: InputDecoration(
                                  hintText: "Reason here...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notes",
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextFormField(
                              maxLines: 3,
                              keyboardType: TextInputType.multiline,
                              controller: _notesController,
                              decoration: InputDecoration(
                                hintText: "Write some notes about the product",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        height: screenHeight * 0.06,
                        width: screenHeight * 0.06,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_quantityController.text.isEmpty) {
                              setState(() {
                                _isQuantityValid = false;
                              });
                            } else {
                              setState(() {
                                _isQuantityValid = true;
                              });
                            }

                            if (_selectedDate == null) {
                              setState(() {
                                _isExpiryDateValid = false;
                              });
                            } else {
                              setState(() {
                                _isExpiryDateValid = true;
                              });
                            }

                            if (_quantityController.text.isNotEmpty &&
                                _selectedDate != null) {
                              _addItemToList();
                            }
                          },
                          icon: Icon(
                            Icons.add,
                            size: screenWidth * 0.05,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Added Items",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DynamicHeightGridView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: itemList.length,
                          crossAxisCount: 2,
                          crossAxisSpacing: screenWidth * 0.03,
                          mainAxisSpacing: screenWidth * 0.03,
                          builder: (ctx, index) {
                            CartDetailsItem item = itemList[index];
                            String pickedDate = DateFormat('dd/MM/yyyy')
                                .format(item.selectedDate);

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${item.quantity} ${UOM.toString()} $pickedDate",
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.03),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _removeItemFromList(index);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: screenWidth * 0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                          height: screenHeight *
                              0.12), // Placeholder for sticky button
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: itemList.isEmpty
                        ? null
                        : () {
                            _showAddToCartDialog(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          itemList.isEmpty ? Colors.grey : Colors.purple,
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add to Bin",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Do you want to add to Cart?",
            style: TextStyle(fontSize: screenWidth * 0.045),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _addToCart();
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.blue)),
                    ),
                    child: Text(
                      "Yes",
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.blue)),
                    ),
                    child: Text(
                      "No",
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Set the initial date to January 1, 1990
      firstDate:
          DateTime(1990), // Set the first selectable date to January 1, 1990
      lastDate: DateTime(DateTime.now().year +
          10), // Set the last selectable date to 10 years from now
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
        _expiryDateController.text = picked.toLocal().toString().split(' ')[0];
      });
      return picked;
    }
    return null;
  }

  void _addItemToList() {
    var productDetailsProvider =
        Provider.of<ProductDetailsProvider>(context, listen: false);
    dynamic? productId = productDetailsProvider.productId;
    String? productName = productDetailsProvider.productName;
    dynamic? ItemID = productDetailsProvider.ItemId;
    dynamic? UomId = productDetailsProvider.UOMId;
    dynamic? UOM = productDetailsProvider.UOM;
    dynamic? Cost = productDetailsProvider.Cost;

    if (_quantityController.text.isNotEmpty && _selectedDate != null) {
      int quantity = int.parse(_quantityController.text);
      String notes = _notesController.text;
      String reason = _selectedReason ?? '';
      CartDetailsItem newItem = CartDetailsItem(
          productName.toString(),
          productId.toString(),
          quantity,
          _selectedDate!,
          notes,
          reason,
          ItemID,
          UomId,
          UOM,
          Cost);

      setState(() {
        itemList.add(newItem);
        _quantityController.clear();
        _selectedDate = null;
        _notesController.clear();
        _reasonTextController.clear();
        _selectedReason = null;
        _showReasonText = false;
      });
    }
  }

  void _addToCart() {
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    for (CartDetailsItem item in itemList) {
      cartProvider.addToCart(item);
    }
  }

  void _removeItemFromList(int index) {
    setState(() {
      itemList.removeAt(index);
    });
  }
}

class CartDetailsItem {
  String productName;
  String productIndex;
  int quantity;
  DateTime selectedDate;
  String note;
  String reason;
  dynamic itemId;
  dynamic uomId;
  dynamic UOM;
  dynamic Cost;

  CartDetailsItem(
    this.productName,
    this.productIndex,
    this.quantity,
    this.selectedDate,
    this.note,
    this.reason,
    this.itemId,
    this.uomId,
    this.UOM,
    this.Cost,
  );
}
