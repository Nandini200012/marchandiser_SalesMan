import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:marchandise/screens/salesman_screens/request_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marchandise/screens/manager_screens/api_service/manager_api_service.dart';
import 'package:marchandise/screens/manager_screens/manager_bottom_navbar.dart';
import 'package:marchandise/screens/manager_screens/model/manager_request_model.dart';
import 'package:marchandise/screens/salesman_screens/api_service/salesman_api_service.dart';
import 'package:marchandise/screens/salesman_screens/split_screen.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/urls.dart';
import 'package:marchandise/utils/willpop.dart';
import '../salesman_screens/model/discount_mode.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

final ManagerApiService apiService = ManagerApiService();
late Future<MangerRequestListModel> managerRequestListDiscount;
late Future<MangerRequestListModel> managerRequestListBanding;
late Future<MangerRequestListModel> managerRequestListReturn;
final SalesManApiService salesManApiService = SalesManApiService();

class _ManagerHomeScreenState extends State<ManagerHomeScreen>
    with SingleTickerProviderStateMixin {
  List<ProductDetailsModel> modelList = [];
  late Willpop willpop;
  late TabController _tabController;
  bool _isExpanded = false;

  String? selectedVendor;
  int? selectedVendorID;
  String? selectedSalesPerson;
  int? selectedSalesPersonID;
  List<Map<String, dynamic>> vendorList = [];
  List<Map<String, dynamic>> salesPersonList = [];
  List<Datum> bandingData = [];
  List<Datum> discountData = [];
  List<Datum> returnData = [];
  bool isPercentage = true;
  double discountPercentage = 0.0;
  double discountAmount = 0.0;

  TextEditingController vendorController = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchData("B", 114, selectedVendorID, selectedSalesPersonID);
    fetchFilters();
  }

  Future<List<Map<String, dynamic>>> fetchVendorList() async {
    // Define the headers
    Map<String, String> headers = {
      'PageNo': '1',
      'PageSize': '10',
      'FilteText': '',
      'IsManager': 'true',
    };

    var response = await http.get(
      Uri.parse(Urls.getVendors),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      if (decodedResponse['isSuccess']) {
        List<dynamic> vendorsData = decodedResponse['data'];
        return vendorsData
            .map<Map<String, dynamic>>((e) =>
                {"vendorID": e['vendorId'], "vendorName": e['vendorName']})
            .toList();
      } else {
        throw Exception('API call was not successful');
      }
    } else {
      throw Exception('Failed to load vendors');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSalesPersonList() async {
    Map<String, String> headers = {
      'IsManager': 'true',
    };
    var response =
        await http.get(Uri.parse(Urls.getSalesPersons), headers: headers);
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      if (decodedResponse['isSuccess']) {
        List<dynamic> salesPersonsData =
            decodedResponse['data']['salesPersons'];
        return salesPersonsData
            .map<Map<String, dynamic>>((e) => {
                  "salesPersonID": e['salesPerson'],
                  "salesPersonName": e['salesPersonName']
                })
            .toList();
      } else {
        throw Exception('API call was not successful');
      }
    } else {
      throw Exception('Failed to load salespersons');
    }
  }

  void fetchFilters() async {
    vendorList = await fetchVendorList();
    salesPersonList = await fetchSalesPersonList();
    setState(() {});
  }

  void fetchData(String filterMode, int flag, int? vendorID, int? salesPerson) {
    switch (filterMode) {
      case "D":
        apiService
            .managerRequestListByDiscount(
                pageNo: 1,
                filterMode: filterMode,
                flag: flag,
                vendorID: selectedVendorID,
                salesPersonID: selectedSalesPersonID)
            .then((result) {
          setState(() {
            discountData = result.data;
          });
        });
        break;
      case "B":
        apiService
            .managerRequestListByDiscount(
                pageNo: 1,
                filterMode: filterMode,
                flag: flag,
                vendorID: selectedVendorID,
                salesPersonID: selectedSalesPersonID)
            .then((result) {
          setState(() {
            bandingData = result.data;
          });
        });
        break;
      case "RT":
        apiService
            .managerRequestListByDiscount(
                pageNo: 1,
                filterMode: filterMode,
                flag: flag,
                vendorID: selectedVendorID,
                salesPersonID: selectedSalesPersonID)
            .then((result) {
          setState(() {
            returnData = result.data;
          });
        });
        break;
    }
  }

  Future<void> _refreshData(String filterMode, int flag) async {
    switch (filterMode) {
      case "D":
        apiService
            .managerRequestListByDiscount(
                pageNo: 1,
                filterMode: filterMode,
                flag: flag,
                salesPersonID: selectedSalesPersonID,
                vendorID: selectedVendorID)
            .then((result) {
          setState(() {
            discountData = result.data;
          });
        });
        break;
      case "B":
        apiService
            .managerRequestListByDiscount(
                pageNo: 1,
                filterMode: filterMode,
                flag: flag,
                salesPersonID: selectedSalesPersonID,
                vendorID: selectedVendorID)
            .then((result) {
          setState(() {
            bandingData = result.data;
          });
        });
        break;
      case "RT":
        apiService
            .managerRequestListByDiscount(
                pageNo: 1,
                filterMode: filterMode,
                flag: flag,
                salesPersonID: selectedSalesPersonID,
                vendorID: selectedVendorID)
            .then((result) {
          setState(() {
            returnData = result.data;
          });
        });
        break;
    }
  }

  Future<void> _refreshDataByBanding() async {
    await _refreshData("B", 114);
  }

  Future<void> _refreshDataByDiscount() async {
    await _refreshData("D", 113);
  }

  Future<void> _refreshDataByReturn() async {
    await _refreshData("RT", 115);
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      _refreshCurrentTab();
    }
  }

  void _filterRequests() {
    // Add your logic to filter the requests based on selectedVendor and selectedSalesPerson
  }

  @override
  void dispose() {
    _tabController.dispose();
    vendorController.dispose();
    salesPersonController.dispose();
    super.dispose();
  }

  void _editQuantity(Datum requestData) {
    TextEditingController qtyController =
        TextEditingController(text: requestData.qty.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Quantity"),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter new quantity",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  requestData.qty = double.parse(qtyController.text);
                });
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return willpop.onWillPop();
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 207, 68, 18),
            automaticallyImplyLeading: false,
            elevation: 0.0,
            title: const Text(
              "Home",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    DynamicAlertBox().logOut(context, "Do you Want to Logout",
                        () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => SplashScreen()));
                    });
                  },
                  child: CircleAvatar(
                    radius: 22,
                    child: Text("MGR"),
                  ),
                ),
              ),
            ],
          ),
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
                )),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TypeAheadFormField<Map<String, dynamic>>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: vendorController,
                                  decoration: InputDecoration(
                                    labelText: 'Select Vendor',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    suffixIcon: vendorController.text.isEmpty
                                        ? Icon(Icons.search)
                                        : IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              setState(() {
                                                vendorController.clear();
                                                selectedVendor = null;
                                                selectedVendorID = null;
                                                _refreshCurrentTab();
                                              });
                                            },
                                          ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                suggestionsCallback: (pattern) {
                                  return vendorList.where((vendor) =>
                                      vendor['vendorName']
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()));
                                },
                                itemBuilder:
                                    (context, Map<String, dynamic> suggestion) {
                                  return ListTile(
                                    title: Text(suggestion['vendorName']),
                                  );
                                },
                                onSuggestionSelected:
                                    (Map<String, dynamic> suggestion) {
                                  setState(() {
                                    selectedVendor = suggestion['vendorName'];
                                    selectedVendorID = suggestion['vendorID'];
                                    vendorController.text =
                                        suggestion['vendorName'];
                                    _refreshCurrentTab();
                                  });
                                },
                                noItemsFoundBuilder: (context) => Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('No Vendor found'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TypeAheadFormField<Map<String, dynamic>>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: salesPersonController,
                                  decoration: InputDecoration(
                                    labelText: 'Select Salesperson',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    suffixIcon: salesPersonController
                                            .text.isEmpty
                                        ? Icon(Icons.search)
                                        : IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              setState(() {
                                                salesPersonController.clear();
                                                selectedSalesPerson = null;
                                                selectedSalesPersonID = null;
                                                _refreshCurrentTab();
                                              });
                                            },
                                          ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                suggestionsCallback: (pattern) {
                                  return salesPersonList.where((salesPerson) =>
                                      salesPerson['salesPersonName']
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()));
                                },
                                itemBuilder:
                                    (context, Map<String, dynamic> suggestion) {
                                  return ListTile(
                                    title: Text(suggestion['salesPersonName']),
                                  );
                                },
                                onSuggestionSelected:
                                    (Map<String, dynamic> suggestion) {
                                  setState(() {
                                    selectedSalesPerson =
                                        suggestion['salesPersonName'];
                                    selectedSalesPersonID =
                                        suggestion['salesPersonID'];
                                    salesPersonController.text =
                                        suggestion['salesPersonName'];
                                    _refreshCurrentTab();
                                  });
                                },
                                noItemsFoundBuilder: (context) => Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('No Salesperson found'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Requests",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 10),
                        TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          tabs: [
                            Tab(text: 'Banding'),
                            Tab(text: 'Discount'),
                            Tab(text: 'Return'),
                          ],
                          indicatorColor: Color.fromARGB(255, 207, 68, 18),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildTabContent(
                                  bandingData, _refreshDataByBanding),
                              _buildTabContent(
                                  discountData, _refreshDataByDiscount),
                              _buildTabContent(
                                  returnData, _refreshDataByReturn),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
      List<Datum> requestData, Future<void> Function() refreshData) {
    if (requestData.isEmpty) {
      return Center(child: Text("No Requests Available"));
    }
    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: requestData.length,
        itemBuilder: (context, index) {
          if (index >= 0 && index < requestData.length) {
            Datum requestDataItem = requestData[index];
            return _buildRequestCard(requestDataItem, context);
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildRequestCard(Datum requestData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(),
        ),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Color.fromARGB(255, 207, 68, 18),
                child: Center(
                  child: Text(
                    requestData.vendorName.substring(0, 1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              title: Text(
                requestData.vendorName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    requestData.salesPerson,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    requestData.date,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              title: Text(
                requestData.prdouctName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ItemCode : ${requestData.prdouctId.toString()}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        requestData.isExpanded = !requestData.isExpanded;
                      });
                    },
                    child: Icon(
                      requestData.isExpanded
                          ? Icons.expand_less
                          : Icons.info_outline_rounded,
                    ),
                  ),
                ],
              ),
            ),
            if (_tabController.index ==
                1) // Check if the current tab is "Discount"
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    _showDiscountEditDialog(context, requestData, () {
                      setState(() {}); // Update parent state
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(requestData.discountMode == 'percentage'
                          ? "Discount Percentage: "
                          : "Discount Amount: "),
                      Text(
                        requestData.discountMode == 'percentage'
                            ? "${requestData.DiscPerc.toStringAsFixed(3)}%"
                            : "${requestData.discountAmount.toStringAsFixed(3)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                      Icon(Icons.edit, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildUpdateButton(context, requestData),
            ),
            if (requestData.isExpanded)
              Column(
                children: [
                  Divider(),
                  GestureDetector(
                    onTap: () => _editQuantity(requestData),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Qty :",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            requestData.qty.toStringAsFixed(2),
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Unit :",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          requestData.uom,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price :",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${requestData.cost.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Expiry Date :",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          requestData.date,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reason :",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          requestData.reason,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, Datum requestData) {
    return ElevatedButton(
      onPressed: () {
        _showUpdateActions(context, requestData);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 207, 68, 18), // text color
      ),
      child: Text("Update"),
    );
  }

  void _showDiscountEditDialog(
      BuildContext context, Datum requestData, Function() onUpdate) {
    bool isPercentage = requestData.discountMode == 'percentage';
    TextEditingController discountController = TextEditingController(
      text: isPercentage
          ? requestData.DiscPerc.toStringAsFixed(3)
          : requestData.discountAmount.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isPercentage
                  ? "Edit Discount Percentage"
                  : "Edit Discount Amount"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Percentage"),
                      Switch(
                        value: isPercentage,
                        onChanged: (value) {
                          setState(() {
                            isPercentage = value;
                            discountController.text = isPercentage
                                ? requestData.DiscPerc.toStringAsFixed(3)
                                : requestData.discountAmount.toStringAsFixed(2);
                          });
                        },
                      ),
                      Text("Amount"),
                    ],
                  ),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: isPercentage ? "0.000" : "0.000",
                    ),
                    onChanged: (value) {
                      double discount = double.tryParse(value) ?? 0;
                      if (isPercentage) {
                        if (discount < 0 || discount > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Discount percentage must be between 0 and 100'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            discountController.text = '';
                          });
                        } else {
                          requestData.DiscPerc = discount;
                        }
                      } else {
                        requestData.discountAmount = discount;
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      requestData.discountMode =
                          isPercentage ? 'percentage' : 'amount';
                    });
                    Navigator.of(context).pop();
                    onUpdate(); // Call the callback to update parent state
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateActions(BuildContext context, Datum requestData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.add_box),
                title: Text('Banding'),
                onTap: () {
                  Navigator.pop(context);
                  _updateRequest(
                      requestData.requestId,
                      requestData.itemID,
                      "Banding",
                      requestData.prdouctSiNo,
                      requestData.QtySplitSiNo);
                },
              ),
              ListTile(
                leading: Icon(Icons.discount),
                title: Text('Discount'),
                onTap: () {
                  Navigator.pop(context);
                  _updateRequest(
                      requestData.requestId,
                      requestData.itemID,
                      "Discount",
                      requestData.prdouctSiNo,
                      requestData.QtySplitSiNo);
                },
              ),
              ListTile(
                leading: Icon(Icons.reply),
                title: Text('Return'),
                onTap: () {
                  Navigator.pop(context);
                  _updateRequest(
                      requestData.requestId,
                      requestData.itemID,
                      "Return",
                      requestData.prdouctSiNo,
                      requestData.QtySplitSiNo);
                },
              ),
              ListTile(
                leading: Icon(Icons.call_split),
                title: Text('Split'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSplitScreen(requestData);
                },
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Approve'),
                onTap: () {
                  Navigator.pop(context);
                  _updateRequest(
                      requestData.requestId,
                      requestData.itemID,
                      "Approve",
                      requestData.prdouctSiNo,
                      requestData.QtySplitSiNo);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Reject'),
                onTap: () {
                  Navigator.pop(context);
                  _showRejectReasonDialog(
                      context,
                      requestData.requestId,
                      requestData.itemID,
                      requestData.prdouctSiNo,
                      requestData.QtySplitSiNo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRejectReasonDialog(BuildContext context, int requestId,
      dynamic productId, dynamic productSiNo, dynamic QtySplit_Item_SINo) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reject Reason"),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: "Enter reason for rejection",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateRequest(requestId, productId, "Reject", productSiNo,
                    QtySplit_Item_SINo,
                    reason: reasonController.text);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic?> getLoggedEmployeeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('EmployeeId');
  }

  void _updateRequest(int requestId, dynamic productId, String action,
      dynamic productSiNo, dynamic QtySplit_Item_SINo,
      {String reason = ""}) async {
    try {
      EasyLoading.show(
          status: 'Please wait...',
          dismissOnTap: false,
          maskType: EasyLoadingMaskType.black);

      var apiUrl = Uri.parse(Urls.requestUpdate);
      dynamic? userId = await getLoggedEmployeeID();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': Constants.token,
      };

      Map<String, dynamic> requestBody = {
        "RequestID": requestId,
        "updateAction": action,
        "UserID": userId,
        "rejectReason": action == "Reject" ? reason : "",
        "RequestUpdationMode": "M",
        "QtySplit_Item_SINo": QtySplit_Item_SINo,
        "Details": [
          {
            "Id": productId,
            "SiNo": productSiNo,
            "Banding": action == "Banding",
            "Discount": action == "Discount",
            "Return": action == "Return",
            "Split": action == "Split", // Added Split field
            "Approved": action == "Approve",
            "Rejected": action == "Reject",
            "DiscPerc":
                action == "Discount" && isPercentage ? discountPercentage : 0,
            "DiscountAmount":
                action == "Discount" && !isPercentage ? discountAmount : 0,
            "DiscountMode": isPercentage ? "percentage" : "amount",
          }
        ],
      };

      var requestBodyJson = jsonEncode(requestBody);
      var response =
          await http.post(apiUrl, headers: headers, body: requestBodyJson);

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        successPopup(context, () {
          _refreshCurrentTab();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred while updating the request."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  double _getDiscountPercentage(dynamic productId, dynamic productSiNo) {
    for (Datum requestData in _getCurrentRequestListData()) {
      if (requestData.prdouctId == productId &&
          requestData.prdouctSiNo == productSiNo) {
        return requestData.DiscPerc;
      }
    }
    return 0.0;
  }

  List<Datum> _getCurrentRequestListData() {
    switch (_tabController.index) {
      case 0:
        return bandingData;
      case 1:
        return discountData;
      case 2:
        return returnData;
      default:
        return [];
    }
  }

  Future<void> _refreshCurrentTab() async {
    switch (_tabController.index) {
      case 0:
        fetchData("B", 114, selectedVendorID, selectedSalesPersonID);
        break;
      case 1:
        fetchData("D", 113, selectedVendorID, selectedSalesPersonID);
        break;
      case 2:
        fetchData("RT", 115, selectedVendorID, selectedSalesPersonID);
        break;
    }
  }

  void successPopup(BuildContext context, VoidCallback onSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Request Updated Successfully",
              style: TextStyle(fontSize: 12),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSuccess(); // Call the callback function
                },
                child: Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }

  static DiscountMode parseDiscountMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'amount':
        return DiscountMode.amount;
      case 'percentage':
      default:
        return DiscountMode.percentage;
    }
  }

  void _navigateToSplitScreen(Datum requestData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitScreen(
          product: Product(
              requestData.prdouctName, requestData.prdouctId, 'split',
              siNo: requestData.prdouctSiNo,
              uom: requestData.uom,
              expiryDate: requestData.date,
              cost: requestData.cost,
              qty: requestData.qty,
              reason: requestData.reason,
              notes: requestData.note,
              discountMode: parseDiscountMode(requestData.discountMode),
              discountAmount: requestData.discountAmount,
              discountPercentage: requestData.DiscPerc,
              itemID: requestData.itemID,
              QtysplitSiNo: requestData.QtySplitSiNo,
              requestID: requestData.requestId),
          onSplitSave: (updatedProduct) {
            setState(() {
              _refreshCurrentTab();
            });
          },
          screenMode: 'Manager',
        ),
      ),
    );
  }
}

class ProductDetailsModel {
  final double qty;
  final String date;
  final String reason;
  final String note;

  ProductDetailsModel({
    required this.qty,
    required this.date,
    required this.reason,
    required this.note,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      qty: json['qty'].toDouble(),
      date: json['date'],
      reason: json['reason'],
      note: json['note'],
    );
  }
}
