import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marchandise/provider/split_provider.dart';
import 'package:marchandise/screens/salesman_screens/request_details_screen.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/show_success_pop_up.dart';
import 'package:marchandise/utils/urls.dart';
import 'package:provider/provider.dart';
import 'package:marchandise/screens/salesman_screens/model/discount_mode.dart';
import 'package:http/http.dart' as http;

class SplitScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onSplitSave;
  final String screenMode;

  const SplitScreen({
    Key? key,
    required this.product,
    required this.onSplitSave,
    required this.screenMode,
  }) : super(key: key);

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  TextEditingController _splitQtyController = TextEditingController();
  TextEditingController _discountController = TextEditingController();
  DiscountMode _splitDiscountMode = DiscountMode.percentage;
  String _splitStatus = 'Banding';
  List<SplitDetail> splitDetails = [];
  dynamic totalSplitQty = 0;
  dynamic availableQty = 0;
  String? _discountErrorMessage;

  @override
  void initState() {
    super.initState();
    availableQty = widget.product.qty;
    final splitProvider = Provider.of<SplitProvider>(context, listen: false);
    splitDetails = splitProvider.getSplitDetails(
            widget.product.itemID, widget.product.siNo) ??
        [];
    totalSplitQty =
        splitDetails.fold(0, (sum, detail) => sum + detail.splitQty);
    availableQty = widget.product.qty - totalSplitQty;
    _discountController.addListener(_validateDiscount);
  }

  @override
  void dispose() {
    // Dispose controllers and listeners
    _splitQtyController.dispose();
    _discountController.removeListener(_validateDiscount);
    _discountController.dispose();
    super.dispose();
  }

  // Method to validate discount amount
  void _validateDiscount() {
    double discountValue = double.tryParse(_discountController.text) ?? 0;

    if (_splitDiscountMode == DiscountMode.amount &&
        discountValue > widget.product.cost) {
      setState(() {
        _discountErrorMessage = 'Discount amount cannot exceed product cost';
      });
    } else {
      setState(() {
        _discountErrorMessage = null; // Clear error message if valid
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Split Quantity'),
          backgroundColor: widget.screenMode == 'SalesMan'
              ? Color(0xFFFFF9C4)
              : Color.fromARGB(255, 207, 68, 18),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.all(constraints.maxWidth > 600 ? 20.0 : 16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          constraints.maxWidth > 600 ? 20.0 : 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize:
                                  constraints.maxWidth > 600 ? 6.sp : 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price: ${widget.product.cost.toStringAsFixed(3)}',
                                style: TextStyle(
                                  fontSize:
                                      constraints.maxWidth > 600 ? 6.sp : 12.sp,
                                ),
                              ),
                              Text(
                                'Total Amount: ${(widget.product.qty * widget.product.cost).toStringAsFixed(3)}',
                                style: TextStyle(
                                  fontSize:
                                      constraints.maxWidth > 600 ? 6.sp : 12.sp,
                                ),
                              ),
                              Text(
                                'Available Quantity: $availableQty',
                                style: TextStyle(
                                  fontSize:
                                      constraints.maxWidth > 600 ? 6.sp : 12.sp,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          TextField(
                            controller: _splitQtyController,
                            decoration: InputDecoration(
                              labelText: 'Enter split quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontSize:
                                    constraints.maxWidth > 600 ? 6.sp : 12.sp),
                          ),
                          SizedBox(height: 16.h),
                          DropdownButton<String>(
                            value: _splitStatus,
                            items: <String>['Banding', 'Discount', 'Return']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        fontSize: constraints.maxWidth > 600
                                            ? 6.sp
                                            : 12.sp)),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _splitStatus = newValue!;
                              });
                            },
                          ),
                          if (_splitStatus == 'Discount')
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _splitDiscountMode == DiscountMode.amount
                                          ? 'Amount'
                                          : 'Percentage',
                                      style: TextStyle(
                                          fontSize: constraints.maxWidth > 600
                                              ? 6.sp
                                              : 12.sp),
                                    ),
                                    Switch(
                                      value: _splitDiscountMode ==
                                          DiscountMode.amount,
                                      onChanged: (value) {
                                        setState(() {
                                          _splitDiscountMode = value
                                              ? DiscountMode.amount
                                              : DiscountMode.percentage;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                TextField(
                                  controller: _discountController,
                                  decoration: InputDecoration(
                                    labelText: _splitDiscountMode ==
                                            DiscountMode.percentage
                                        ? 'Enter Discount %'
                                        : 'Enter Discount Amount',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: constraints.maxWidth > 600
                                          ? 6.sp
                                          : 12.sp),
                                ),
                              ],
                            ),
                          SizedBox(height: 16.h),
                          Center(
                            child: FloatingActionButton(
                              onPressed: _handleAddSplit,
                              child: Icon(Icons.add, color: Colors.white),
                              backgroundColor: Color(0xFFFBC02D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: splitDetails.length,
                      itemBuilder: (context, index) {
                        final split = splitDetails[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: constraints.maxWidth > 600 ? 8.h : 8.h,
                              horizontal:
                                  constraints.maxWidth > 600 ? 8.w : 8.w),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              'Qty: ${split.splitQty}, Status: ${split.splitStatus}',
                              style: TextStyle(
                                  fontSize: constraints.maxWidth > 600
                                      ? 6.sp
                                      : 12.sp),
                            ),
                            subtitle: split.splitStatus == 'Discount'
                                ? Text(
                                    '${split.discountMode == DiscountMode.percentage ? 'Discount Percentage: ${split.discountPercentage.toStringAsFixed(3)}%' : 'Discount Amount: ${split.discountAmount.toStringAsFixed(3)}'}',
                                    style: TextStyle(
                                        fontSize: constraints.maxWidth > 600
                                            ? 6.sp
                                            : 10.sp),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeSplit(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.all(constraints.maxWidth > 600 ? 15.0 : 16.0),
              child: ElevatedButton(
                onPressed: _handleSplitSave,
                child: Text('Save Splits',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: constraints.maxWidth > 600 ? 6.sp : 12.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFBC02D),
                  padding: EdgeInsets.symmetric(
                      vertical: constraints.maxWidth > 600 ? 8.0 : 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void updateRequest() async {
    try {
      EasyLoading.show(
        status: 'Please wait...',
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );

      var apiUrl = Uri.parse(Urls.requestUpdate);
      dynamic? userId = 1;

      // Extract SplitDetails
      List<Map<String, dynamic>> splitDetailsList = [];

      List<Map<String, dynamic>> splitDetailsMaps = getSplitDetailsMapsByItemId(
          widget.product.itemID, widget.product.siNo);
      if (splitDetailsMaps.isNotEmpty) {
        splitDetailsList.addAll(splitDetailsMaps);
      }

      print("Split Details List: $splitDetailsList");
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': Constants.token,
      };

      final Map<String, dynamic> requestBody = {
        "RequestID": widget.product.requestID,
        "RequestUpdationMode": "M",
        "UserID": userId,
        "Details": [],
        "QtySplit": splitDetailsList,
        "IsSplit": "Y",
        "QtySplit_Item_SINo": widget.product.QtysplitSiNo
      };

      var requestBodyJson = jsonEncode(requestBody);
      print("Request Body JSON: $requestBodyJson");

      var response = await http.post(
        apiUrl,
        headers: headers,
        body: requestBodyJson,
      );

      print("Response Body Template: ${response.body}");

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['isSuccess'] == true) {
          _showSnackbar('Request updated successfully.');
          Provider.of<SplitProvider>(context, listen: false)
              .clearAllSplitDetails();
          Navigator.of(context).pop(); // Close the screen if success
        } else {
          _showErrorPopup(jsonResponse['message']);
        }
      } else {
        _showErrorPopup(jsonResponse['message']);
      }
    } catch (e) {
      _showErrorPopup(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
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

  void _handleAddSplit() {
    int splitQty = int.tryParse(_splitQtyController.text) ?? 0;
    double discountValue = double.tryParse(_discountController.text) ?? 0;

    if (splitQty <= 0) {
      _showError('Split quantity must be greater than zero.');
      return;
    }

    if (totalSplitQty + splitQty > widget.product.qty) {
      _showError('Total split quantity cannot exceed available quantity.');
      return;
    }

    // Check if discount amount exceeds product cost
    if (_splitDiscountMode == DiscountMode.amount &&
        discountValue > widget.product.cost) {
      _showError('Discount amount cannot be greater than the product Price.');
      return;
    }

    if (_splitStatus == 'Discount' &&
        _splitDiscountMode == DiscountMode.percentage &&
        (discountValue < 0 || discountValue > 100)) {
      _showError('Discount percentage must be between 0 and 100.');
      return;
    }

    if (_splitStatus == 'Discount' &&
        _splitDiscountMode == DiscountMode.percentage &&
        (discountValue == 0)) {
      _showError('Discount percentage cannot be zero.');
      return;
    }

    if (_splitStatus == 'Discount' &&
        _splitDiscountMode == DiscountMode.amount &&
        (discountValue == 0)) {
      _showError('Discount amount  cannot be zero.');
      return;
    }

    double discountAmount = _splitDiscountMode == DiscountMode.percentage
        ? (widget.product.cost ?? 0) * (discountValue / 100)
        : discountValue;
    double discountPercentage = _splitDiscountMode == DiscountMode.percentage
        ? discountValue
        : (discountValue / (widget.product.cost ?? 1)) * 100;

    setState(() {
      splitDetails.add(SplitDetail(
        widget.product.itemID,
        widget.product.siNo,
        splitQty,
        _splitStatus,
        discountValue: _splitStatus == 'Discount' ? discountValue : 0,
        discountMode: _splitDiscountMode,
        discountAmount: _splitStatus == 'Discount' ? discountAmount : 0,
        discountPercentage: _splitStatus == 'Discount' ? discountPercentage : 0,
      ));
      totalSplitQty += splitQty;
      availableQty -= splitQty;
      _splitQtyController.clear();
      _discountController.clear();
      _splitDiscountMode = DiscountMode.percentage;
      _splitStatus = 'Banding';
    });
  }

  void _removeSplit(int index) {
    setState(() {
      totalSplitQty -= splitDetails[index].splitQty;
      availableQty += splitDetails[index].splitQty;
      splitDetails.removeAt(index);
    });
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

  void _showErrorPopup(String message) {
    ShowSuccessPopUp().errorPopup(context: context, errorMessage: message);
  }

  void _handleSplitSave() {
    if (availableQty > 0) {
      _showError('Available quantity must be zero before saving the split.');
      return;
    }
    final splitProvider = Provider.of<SplitProvider>(context, listen: false);
    splitProvider.updateSplitDetails(
        widget.product.itemID, widget.product.siNo, splitDetails);
    setState(() {
      widget.product.status = 'Split';
    });

    widget.onSplitSave(widget.product);
    if (widget.screenMode == 'Manager') {
      updateRequest();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onBackPressed() async {
    // Get the split provider
    final splitProvider = Provider.of<SplitProvider>(context, listen: false);

    // Check if split details are available for the current product
    List<SplitDetail> currentProductSplits = splitProvider.getSplitDetails(
            widget.product.itemID, widget.product.siNo) ??
        [];

    // If no splits are available, ask for confirmation before exiting
    if (currentProductSplits.isEmpty) {
      bool? exitConfirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit without saving?'),
          content: Text('No split quantity found. Do you want to exit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel exit
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                widget.product.status =
                    ''; // Revert the product status to empty
                Navigator.of(context).pop(true); // Confirm exit
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );

      // If the user confirms, exit the screen and return true
      return exitConfirmed ?? false;
    }

    // If split details exist, allow back navigation without asking
    return true;
  }
}
