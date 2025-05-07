import 'dart:convert';
import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marchandise/provider/split_provider.dart';
import 'package:marchandise/screens/model/comment_model.dart';
import 'package:marchandise/screens/salesman_screens/api_service/salesman_api_service.dart';
import 'package:marchandise/screens/salesman_screens/model/salesman_request_by_id_model.dart';
import 'package:marchandise/screens/salesman_screens/model/salesman_request_list_model.dart';
import 'package:marchandise/screens/salesman_screens/salesman_bottom_navbar.dart';
import 'package:marchandise/screens/salesman_screens/split_screen.dart';
import 'package:marchandise/utils/comment_box.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/show_success_pop_up.dart';
import 'package:marchandise/utils/urls.dart';
import 'package:marchandise/utils/willpop.dart';
import 'package:provider/provider.dart';
import 'package:marchandise/screens/salesman_screens/model/salesman_info_model.dart'
    as info;
import 'package:marchandise/provider/salesman_request_provider.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../salesman_screens/model/discount_mode.dart';

enum MyButton {
  bandingButton,
  discountButton,
  returnButton,
  splitButton,
  noActionButton
}

class Product {
  String name;
  dynamic productId;
  String status;
  String discountValue;
  bool editingDiscount;
  int siNo;
  dynamic uom;
  dynamic expiryDate;
  dynamic cost;
  dynamic qty;
  dynamic reason;
  dynamic notes;
  DiscountMode discountMode;
  double discountAmount;
  double discountPercentage;
  dynamic itemID;
  dynamic QtysplitSiNo;
  dynamic requestID;
  dynamic uomID;
  bool isValid = true;

  Product(this.name, this.productId, this.status,
      {this.discountValue = '',
      this.editingDiscount = true,
      required this.siNo,
      this.uom,
      this.expiryDate,
      this.cost,
      this.qty,
      this.reason,
      this.notes,
      this.discountMode = DiscountMode.percentage,
      this.discountAmount = 0.0,
      this.discountPercentage = 0.0,
      this.itemID,
      this.QtysplitSiNo,
      this.requestID,
      this.uomID = 0});
}

class RequestDetailsScreen extends StatefulWidget {
  final String vendorName;
  final String vendorId;
  final int requestId;
  const RequestDetailsScreen({
    Key? key,
    required this.vendorName,
    required this.vendorId,
    required this.requestId,
  }) : super(key: key);

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  List<Product> products = [];
  Set<Product> selectedProducts = {};
  List<Map<String, dynamic>> detailsList = [];
  SalesManApiService salesManApiService = SalesManApiService();
  MyButton currentButton = MyButton.bandingButton;
  String vendorName = "";
  late Willpop willpop;
  late Future<SalesmanRequestListModel> salesRequestList;
  final SalesManApiService apiService = SalesManApiService();
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _discountController;
  bool _isEditingQty = false;
  Product? _editingProduct;
  TextEditingController _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    salesRequestList = apiService.getSalesmanRequestList();
    _discountController = TextEditingController();
    willpop = Willpop(context);
    vendorName = widget.vendorName;
    _fetchSalesmanData();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _discountController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _discountController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      salesRequestList = apiService.getSalesmanRequestList();
    });
  }

  Future<void> _fetchSalesmanData() async {
    try {
      EasyLoading.show(
        status: 'Loading...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );
      SalesmanRequestById salesmanData =
          await salesManApiService.getSalesManRequestById(widget.requestId);

      setState(() {
        products = salesmanData.data.map((datum) {
          return Product(
            datum.prdouctName,
            datum.prdouctId,
            datum.status,
            editingDiscount: true,
            siNo: datum.siNo,
            uom: datum.uom,
            expiryDate: datum.date,
            cost: datum.cost,
            qty: datum.qty,
            reason: datum.reason,
            notes: datum.notes,
            itemID: datum.itemID,
            uomID: datum.uomID,
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<dynamic?> getLoggedEmployeeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('EmployeeId');
  }

  void updateRequest() async {
    try {
      EasyLoading.show(
        status: 'Please wait...',
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );

      var apiUrl = Uri.parse(Urls.requestUpdate);
      dynamic? userId = await getLoggedEmployeeID();

      // Extract SplitDetails
      List<Map<String, dynamic>> splitDetailsList = [];
      for (var product in products) {
        List<Map<String, dynamic>> splitDetailsMaps =
            getSplitDetailsMapsByItemId(product.itemID, product.siNo);
        if (splitDetailsMaps.isNotEmpty) {
          splitDetailsList.addAll(splitDetailsMaps);
        }
      }
      // Debug print for splitDetailsList
      print("Split Details List: $splitDetailsList");
      print("Details List: $detailsList");

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': Constants.token,
      };

      final Map<String, dynamic> requestBody = {
        "RequestID": widget.requestId,
        "RequestUpdationMode": "S",
        "UserID": userId,
        "Details": detailsList,
        "QtySplit": splitDetailsList,
      };

      // Convert requestBody to JSON string and print it
      var requestBodyJson = jsonEncode(requestBody);
      print("Request Body JSON: $requestBodyJson");

      var response = await http.post(
        apiUrl,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("Response Body Template: ${response.body}");

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['isSuccess'] == true) {
          _showSnackbar('Request updated successfully.');
          Provider.of<SplitProvider>(context, listen: false)
              .clearAllSplitDetails();
        } else {
          _showSnackbar(jsonResponse['message']);
        }
      } else {
        _showSnackbar(jsonResponse['message']);
      }
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _showErrorPopup(String message) {
    ShowSuccessPopUp().errorPopup(context: context, errorMessage: message);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message, style: const TextStyle(fontSize: 8)),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: Colors.blue),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  void _validateAndUpdateRequest() {
    bool allProductsUpdated = true;
    List<String> invalidProducts = [];

    // Iterate through the products to validate them
    setState(() {
      for (var product in products) {
        if (product.status == "Initial" ||
            product.status.isEmpty ||
            product.cost == 0) {
          product.isValid = false; // Mark product as invalid
          allProductsUpdated = false;
        } else {
          product.isValid = true; // Mark product as valid
        }
      }
    });

    if (detailsList.isEmpty) {
      Flushbar(
        message: 'Please select at least one product to update.',
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
        duration: Duration(seconds: 3),
      ).show(context);
    } else if (!allProductsUpdated) {
      // Show error message with the list of products that are not updated
      String invalidProductNames = invalidProducts.join(', ');
      Flushbar(
        message: 'Please update the status for the highlighted products.',
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
        duration: Duration(seconds: 3),
      ).show(context);
    } else {
      _showUpdateDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    return WillPopScope(
      onWillPop: () async => _onBackPressed(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildProductList(constraints),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: _buildSaveButton(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFF9C4),
      leading: IconButton(
        onPressed: () async {
          bool shouldExit = await _onBackPressed(); // ✅
          if (shouldExit) {
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: Text(
        "${widget.vendorId} - ${widget.vendorName}",
        style: const TextStyle(color: Colors.black),
      ),
      centerTitle: true,
      actions: [_buildLogoutButton()],
    );
  }

  Padding _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () {
          DynamicAlertBox().logOut(context, "Do you Want to Logout", () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SplashScreen()));
          });
        },
        child: CircleAvatar(radius: 22, child: Text("SM")),
      ),
    );
  }

  Widget _buildProductList(BoxConstraints constraints) {
    if (products.isEmpty) {
      return Center(child: Text('No Requests available'));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 600
            ? 3
            : 1, // Display 2 cards in a row for web
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
        childAspectRatio:
            constraints.maxWidth > 600 ? 2.5 : 1.5, // Adjust this for card size
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], constraints);
      },
    );
  }

  Widget _buildProductCard(Product product, BoxConstraints constraints) {
    return Card(
      color: product.isValid ? Colors.grey[100] : Colors.red[100],
      margin: EdgeInsets.symmetric(
        vertical:
            constraints.maxWidth > 600 ? 4.h : 4.h, // Reduced vertical margin
        horizontal:
            constraints.maxWidth > 600 ? 6.w : 4.w, // Reduced horizontal margin
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: product.isValid
              ? Colors.transparent
              : Colors.red, // Add red border if product is invalid
          width: 2.0,
        ),
      ),
      elevation: 4,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: constraints.maxWidth > 600
                  ? 5.w
                  : 6.w, // Reduced left padding
              right: constraints.maxWidth > 600
                  ? 5.w
                  : 6.w, // Reduced right padding
              top:
                  constraints.maxWidth > 600 ? 8.h : 6.h, // Reduced top padding
              bottom: constraints.maxWidth > 600
                  ? 8.h
                  : 6.h, // Reduced bottom padding
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar(
                    //   backgroundColor: Color(0xFFFBC02D),
                    //   child: Text(
                    //     product.name.substring(0, 1),
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: constraints.maxWidth > 600 ? 5.sp : 5.sp,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                        width: constraints.maxWidth > 600
                            ? 8.w
                            : 6.w), // Reduced gap between avatar and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600
                                  ? 4.h
                                  : 2.h), // Reduced gap between lines
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ItemCode : ${product.productId.toString()}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Exp Date : ${_formattedExpiryDate(product.expiryDate)}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600
                                  ? 6.h
                                  : 2.h), // Reduced gap between rows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showEditQuantityDialog(product);
                                },
                                child: Text(
                                  'Qty : ${product.qty.toString()}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              Text(
                                'Unit : ${product.uom.toString()}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showEditPriceDialog(product);
                                },
                                child: Text(
                                  'Price : ${product.cost.toStringAsFixed(3)}',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600
                                  ? 6.h
                                  : 2.h), // Reduced gap between lines
                          Text(
                            'Reason : ${product.reason}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600
                                  ? 6.h
                                  : 2.h), // Reduced gap between lines
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Notes : ${product.notes}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Gross Total : ${_calculateGrossTotal(product).toStringAsFixed(3)}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600
                                  ? 6.h
                                  : 2.h), // Reduced gap between lines
                          // Status and discount section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Status
                              Text(
                                product.status,
                                style: TextStyle(
                                  color: _getStatusColor(product.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // Discount Information (if applicable)
                              if (!product.editingDiscount &&
                                  double.parse(product.discountValue.isNotEmpty
                                          ? product.discountValue
                                          : '0') >
                                      0)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: InkWell(
                                    onTap: () {
                                      _showDiscountDialog(product);
                                    },
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: constraints.maxWidth > 600
                                                ? 2.h
                                                : 2.h,
                                            horizontal:
                                                constraints.maxWidth > 600
                                                    ? 4.w
                                                    : 4.w,
                                          ),
                                          child: Text(
                                            '${product.discountMode == DiscountMode.percentage ? 'Percentage' : 'Amount'}: ${double.parse(product.discountValue).toStringAsFixed(product.discountMode == DiscountMode.percentage ? 2 : 3)}',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10
                .h, // Reduced the gap between the button and the bottom of the card
            left: 0,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    log('req id: ${widget.requestId}, pro id: ${product.productId},pro name: ${product.name} ');
                    showCommentPopup(context,
                        requestID: int.parse(widget.requestId.toString()),
                        productID: product.productId,
                        productName: product.name,
                        uomID: product.uomID);
                  },
                  icon: Icon(Icons.message),
                ),
              ],
            ),
          ),
          Positioned(
            bottom:
                10, // Reduced the gap between the button and the bottom of the card
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => _showUpdateOptions(product),
                child: Text("Update"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 107, 95, 95),
                  backgroundColor: Color(0xFFFBC02D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void showCommentPopup(BuildContext context) {
  //   List<String> comments = ['Nice post!', 'Interesting!', 'Well said!'];

  //   void showAddCommentDialog() {
  //     TextEditingController _commentController = TextEditingController();
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text('Add Comment'),
  //           content: TextField(
  //             controller: _commentController,
  //             maxLines: 3,
  //             decoration: InputDecoration(
  //               hintText: 'Enter your comment',
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 if (_commentController.text.isNotEmpty) {
  //                   comments.add(_commentController.text);
  //                 }
  //                 Navigator.pop(context);
  //               },
  //               child: Text('Submit'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text('Comments'),
  //             content: Container(
  //               width: double.maxFinite,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Expanded(
  //                     child: ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: comments.length,
  //                       itemBuilder: (context, index) {
  //                         return ListTile(
  //                           leading: Icon(Icons.comment),
  //                           title: Text(comments[index]),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                   Align(
  //                     alignment: Alignment.centerRight,
  //                     child: IconButton(
  //                       icon: Icon(Icons.add_comment),
  //                       onPressed: () {
  //                         showAddCommentDialog();
  //                       },
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: Text('Close'),
  //               )
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  String _formattedExpiryDate(String expiryDateString) {
    try {
      // Assuming expiryDateString is in the format 'DD/MM/YYYY'
      List<String> parts = expiryDateString.split('/');
      if (parts.length == 3) {
        // Parse the expiry date manually
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        DateTime expiryDate = DateTime(year, month, day);

        // Get the current date
        DateTime currentDate = DateTime.now();

        // Calculate the difference in days (can be negative if expiry date is in the past)
        int daysDifference = expiryDate.difference(currentDate).inDays;

        // Return the formatted date with the days difference (negative if expired)
        return "$expiryDateString (${daysDifference} Days)";
      } else {
        // If the format is not correct, return the original string with a warning
        return 'Invalid date format';
      }
    } catch (e) {
      // Handle the error and return a default message
      return 'Error in date format';
    }
  }

  double _calculateGrossTotal(Product product) {
    double price = product.cost;
    double qty = product.qty;
    double discountValue = product.discountValue.isNotEmpty
        ? double.parse(product.discountValue)
        : 0;

    if (product.discountMode == DiscountMode.percentage) {
      // If discount is in percentage, reduce the percentage from the price
      double discountAmount = price * (discountValue / 100);
      return (price - discountAmount) * qty;
    } else {
      // If discount is a fixed amount, subtract the amount from the price
      return (price - discountValue) * qty;
    }
  }

  void _showEditQuantityDialog(Product product) {
    TextEditingController _qtyController =
        TextEditingController(text: product.qty.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            String errorMessage = '';

            return AlertDialog(
              title: Text('Edit Quantity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _qtyController,
                    decoration: InputDecoration(
                      hintText: "Enter Qty",
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    int? enteredQty = int.tryParse(_qtyController.text);

                    if (enteredQty == null || enteredQty <= 0) {
                      setState(() {
                        Flushbar(
                          message: 'Quantity must be greater than zero',
                          backgroundColor: Colors.red,
                          flushbarPosition: FlushbarPosition.TOP,
                          duration: Duration(seconds: 3),
                        ).show(context);
                      });
                    } else {
                      // Close the dialog and update the parent widget
                      Navigator.of(context).pop();
                      setState(() {
                        product.qty = enteredQty;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUpdateButton(Product product, BoxConstraints constraints) {
    return ElevatedButton(
      onPressed: () => _showUpdateOptions(product),
      child: Text("Update",
          style:
              TextStyle(fontSize: constraints.maxWidth > 600 ? 6.sp : 12.sp)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Color(0xFFFBC02D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEditButton(Product product, BoxConstraints constraints) {
    return ElevatedButton(
      onPressed: () => _editSplitDetails(product),
      child: Text("Edit Split",
          style:
              TextStyle(fontSize: constraints.maxWidth > 600 ? 5.sp : 12.sp)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.brown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _validateAndUpdateRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFBC02D),
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Save',
          style: TextStyle(color: Colors.black, fontSize: 5.sp),
        ),
      ),
    );
  }

  void _showUpdateOptions(Product product) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.add, color: Color(0xFFFBC02D)),
                  title: Text("Banding", style: TextStyle(fontSize: 5.sp)),
                  onTap: () {
                    _updateProductStatus(MyButton.bandingButton, product);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_offer, color: Color(0xFFFBC02D)),
                  title: Text("Discount", style: TextStyle(fontSize: 5.sp)),
                  onTap: () {
                    setState(() {
                      product.isValid = true;
                      // product.status = 'Discount';
                      product.editingDiscount = true;
                    });
                    Navigator.pop(context);
                    _showDiscountDialog(product);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.reply, color: Color(0xFFFBC02D)),
                  title: Text("Return", style: TextStyle(fontSize: 5.sp)),
                  onTap: () {
                    _updateProductStatus(MyButton.returnButton, product);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.call_split, color: Color(0xFFFBC02D)),
                  title: Text("Split", style: TextStyle(fontSize: 5.sp)),
                  onTap: () {
                    _updateProductStatus(MyButton.splitButton, product);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplitScreen(
                          product: product,
                          onSplitSave: (updatedProduct) {
                            setState(() {
                              products[products.indexOf(product)] =
                                  updatedProduct;
                              createDataList();
                            });
                          },
                          screenMode: 'SalesMan',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel, color: Color(0xFFFBC02D)),
                  title: Text("No Actions", style: TextStyle(fontSize: 5.sp)),
                  onTap: () {
                    _updateProductStatus(MyButton.noActionButton, product);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDiscountDialog(Product product) {
    TextEditingController _discountController = TextEditingController(
      text: product.discountValue.isEmpty ? '' : product.discountValue,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
              ),
              title: Center(
                child: Text(
                  'Set Discount',
                  style: TextStyle(
                    fontSize: 5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Highlight the title
                  ),
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 400.w : 300.w,
                  minHeight: 100.h,
                ),
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              product.discountMode == DiscountMode.percentage
                                  ? 'Percentage'
                                  : 'Amount',
                              style: TextStyle(
                                fontSize: 5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87, // Darker text
                              ),
                            ),
                            Switch(
                              activeColor: Colors.blueAccent, // Switch color
                              value:
                                  product.discountMode == DiscountMode.amount,
                              onChanged: (value) {
                                setState(() {
                                  product.discountMode = value
                                      ? DiscountMode.amount
                                      : DiscountMode.percentage;
                                  _discountController.text = '';
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h), // Increased spacing for clarity
                        TextField(
                          controller: _discountController,
                          onChanged: (value) {
                            double discount = double.tryParse(value) ?? 0;
                            if (product.discountMode ==
                                    DiscountMode.percentage &&
                                (discount < 0 || discount > 100)) {
                              Flushbar(
                                message:
                                    'Discount percentage must be between 0 and 100',
                                backgroundColor: Colors.red,
                                flushbarPosition: FlushbarPosition.TOP,
                                duration: Duration(seconds: 3),
                              ).show(context);
                              setState(() {
                                _discountController.clear();
                              });
                            } else if (product.discountMode ==
                                    DiscountMode.amount &&
                                discount > product.cost) {
                              Flushbar(
                                message:
                                    'Discount amount cannot be greater than the product Price',
                                backgroundColor: Colors.red,
                                flushbarPosition: FlushbarPosition.TOP,
                                duration: Duration(seconds: 3),
                              ).show(context);
                              setState(() {
                                _discountController.clear();
                              });
                            } else {
                              setState(() {
                                product.discountValue = value;
                                if (product.discountMode ==
                                    DiscountMode.percentage) {
                                  product.discountPercentage = discount;
                                  product.discountAmount =
                                      (product.cost ?? 0) * (discount / 100);
                                  product.status = 'Discount';
                                } else {
                                  product.discountAmount = discount;
                                  product.discountPercentage =
                                      (discount / (product.cost ?? 1)) * 100;
                                  product.status = 'Discount';
                                }
                              });
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded borders
                            ),
                            labelText:
                                product.discountMode == DiscountMode.percentage
                                    ? 'Enter Discount %'
                                    : 'Enter Discount Amount',
                            labelStyle: TextStyle(
                              color: Colors.blue, // Blue for focus
                              fontSize: 4.sp,
                            ),
                            hintText: '0.000',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                double discount =
                                    double.tryParse(_discountController.text) ??
                                        0;
                                if (product.discountMode ==
                                        DiscountMode.percentage &&
                                    (discount < 0 || discount > 100)) {
                                  Flushbar(
                                    message:
                                        'Discount percentage must be between 0 and 100',
                                    backgroundColor: Colors.red,
                                    flushbarPosition: FlushbarPosition.TOP,
                                    duration: Duration(seconds: 3),
                                  ).show(context);
                                  setState(() {
                                    _discountController.clear();
                                  });
                                }

                                if (product.discountMode ==
                                        DiscountMode.amount &&
                                    discount > product.cost) {
                                  Flushbar(
                                    message:
                                        'Discount amount cannot be greater than the product Price',
                                    backgroundColor: Colors.red,
                                    flushbarPosition: FlushbarPosition.TOP,
                                    duration: Duration(seconds: 3),
                                  ).show(context);
                                  setState(() {
                                    _discountController.clear();
                                  });
                                }
                                if (_discountController.text.isNotEmpty) {
                                  setState(() {
                                    product.editingDiscount = false;
                                  });
                                  Navigator.pop(context);

                                  // Trigger the rebuild of the parent widget to reflect the changes
                                  this.setState(() {
                                    createDataList(); // Assuming this triggers the UI update
                                  });
                                } else {
                                  _showConfirmationDialog(context, product);
                                }
                              },
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Added rounded corners
          ),
          title: Text(
            'No Discount Entered',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 5.sp,
              color: Colors.redAccent,
            ),
          ),
          content: Text(
            'Do you want to proceed with a 0% discount?',
            style: TextStyle(
              fontSize: 5.sp,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.red), // Red for clarity
              ),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    product.discountValue = '';
                    product.discountAmount = 0.00;
                    product.discountPercentage = 0.00;
                    product.editingDiscount = false;
                  });
                }
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.green), // Green for approval
              ),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    if (product.discountValue.isEmpty) {
                      product.discountValue = '';
                      product.discountAmount = 0.00;
                      product.discountPercentage = 0.00;
                    }
                    product.editingDiscount = false;
                  });
                }
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close discount dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showDiscountValidationError() {
    Flushbar(
      message: 'Please apply a discount percentage or amount first',
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(seconds: 3),
    ).show(context);
  }

  void _updateProductStatus(MyButton buttonType, Product product) {
    String newStatus = _getButtonTitle(buttonType);

    // Special validation for Discount status
    if (newStatus == "Discount") {
      // Check if discount value is empty or zero
      if (product.discountValue.isEmpty ||
          double.tryParse(product.discountValue) == 0.0) {
        _showDiscountValidationError();
        return; // Exit without changing status
      }
    }

    if (newStatus != "Split" && product.status == "Split") {
      setState(() {
        final splitProvider =
            Provider.of<SplitProvider>(context, listen: false);
        splitProvider.clearSplitDetails(product.productId, product.siNo);
        _updateProductDirectly(product, _getButtonTitle(buttonType));
      });
    } else {
      _updateProductDirectly(product, newStatus);
    }
  }

  void _showClearSplitDialog(Product product, MyButton buttonType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Split Quantity'),
          content: Text('Do you want to clear the split quantity?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                final splitProvider =
                    Provider.of<SplitProvider>(context, listen: false);
                splitProvider.clearSplitDetails(
                    product.productId, product.siNo);
                _updateProductDirectly(product, _getButtonTitle(buttonType));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateProductDirectly(Product product, String newStatus) {
    setState(() {
      if (newStatus != "Split") {
        product.status = newStatus;
      }
      product.isValid = true;
      if (newStatus == "Banding" ||
          newStatus == "Return" ||
          newStatus == "No Actions") {
        product.discountValue = '';
        product.editingDiscount = false;
        product.discountAmount = 0.00;
        product.discountPercentage = 0.00;
        product.isValid = true;
      }
      selectedProducts.add(product);
      createDataList();
    });
  }

  void _editSplitDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitScreen(
          product: product,
          onSplitSave: (updatedProduct) {
            setState(() {
              products[products.indexOf(product)] = updatedProduct;
              createDataList();
            });
          },
          screenMode: 'SalesMan',
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Banding':
        return Colors.purple;
      case 'Discount':
        return Colors.purple;
      case 'Return':
        return Colors.purple;
      case 'Split':
        return Colors.purple;
      case 'No Actions':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  void _updateStatusAndRefresh(Product product, String status) {
    setState(() {
      if (status == "Banding" || status == "Return" || status == "No Actions") {
        product.discountValue = '';
        product.editingDiscount = false;
        product.discountAmount = 0.00;
        product.discountPercentage = 0.00;
      }
      product.status = status;
      selectedProducts.add(product);
      createDataList();
    });
  }

  String _getButtonTitle(MyButton buttonType) {
    switch (buttonType) {
      case MyButton.bandingButton:
        return "Banding";
      case MyButton.discountButton:
        return "Discount";
      case MyButton.returnButton:
        return "Return";
      case MyButton.splitButton:
        return "Split";
      case MyButton.noActionButton:
        return "No Actions";
      default:
        return "";
    }
  }

  void createDataList() {
    detailsList.clear();
    // final splitProvider = Provider.of<SplitProvider>(context, listen: false);

    for (var product in products) {
      if (product.status != "Initial") {
        double discountValue = 0.0;
        if (product.status == 'Discount') {
          try {
            discountValue = double.parse(product.discountValue);
          } catch (e) {
            print('Error parsing discount value: $e');
          }
        }

        detailsList.add({
          "Id": product.itemID,
          "SiNo": product.siNo,
          "Qty": product.qty,
          "Banding": product.status == 'Banding' ? true : false,
          "Discount": product.status == 'Discount' ? true : false,
          "Return": product.status == 'Return' ? true : false,
          "Split": product.status == 'Split' ? true : false,
          "NoAction": product.status == 'No Actions' ? true : false,
          "DiscountMode": product.discountMode == DiscountMode.percentage
              ? 'Percentage'
              : 'Amount',
          "DiscountAmount": product.discountAmount,
          "DiscountPercentage": product.discountPercentage,
          "Approved": false,
          "Rejected": false,
          "DiscPerc": product.discountPercentage,
        });
      }
    }
    print("DetailsList: $detailsList");
  }

  List<Map<String, dynamic>> getSplitDetailsMapsByItemId(
      dynamic itemId, dynamic SiNo) {
    final splitProvider = Provider.of<SplitProvider>(context, listen: false);

    return splitProvider
            .getSplitDetails(itemId, SiNo)
            ?.map((splitDetail) => splitDetail.toMap())
            .toList() ??
        [];
  }

  void _showErrorBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 200.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                style: TextStyle(fontSize: 5.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFBC02D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 5.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 16,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 200.w, // Adjust the maxWidth as needed
            ),
            child: Container(
              padding: EdgeInsets.all(30.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Do you want to Update",
                    style: TextStyle(
                      fontSize: 5.sp, // Adjust the fontSize as needed
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          updateRequest();
                          _refreshData();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => SalesManBottomNavBar()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFBC02D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 10.h,
                          ),
                        ),
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 5.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 10.h,
                          ),
                        ),
                        child: Text(
                          "No",
                          style: TextStyle(
                            fontSize: 5.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(info.Datum detail) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Quantity : ${detail.qty}",
                  style: TextStyle(fontSize: 11.sp)),
              SizedBox(height: 4.h),
              Text('Reason: ${detail.reason}',
                  style: TextStyle(fontSize: 11.sp)),
              SizedBox(height: 4.h),
              Text('Note: ${detail.note}', style: TextStyle(fontSize: 11.sp)),
              SizedBox(height: 4.h),
              Text("Expiry Date : ${detail.date ?? "N/A"}",
                  style: TextStyle(fontSize: 11.sp)),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit without saving?'),
            content: Text('Are you sure you want to exit without saving?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Block back
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Allow back
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _showEditPriceDialog(Product product) {
    TextEditingController _priceController =
        TextEditingController(text: product.cost.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            String errorMessage = '';

            return AlertDialog(
              title: Text('Edit Price'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      hintText: "Enter Price",
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    double? enteredPrice =
                        double.tryParse(_priceController.text);

                    if (enteredPrice == null || enteredPrice <= 0) {
                      setStateDialog(() {
                        errorMessage = 'Price must be greater than zero';
                      });
                      Flushbar(
                        message: 'Price must be greater than zero',
                        backgroundColor: Colors.red,
                        flushbarPosition: FlushbarPosition.TOP,
                        duration: Duration(seconds: 3),
                      ).show(context);
                    } else {
                      Navigator.of(context).pop();
                      setState(() {
                        product.cost = enteredPrice;
                        createDataList(); // Update the data list when price changes
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
