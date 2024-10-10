import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marchandise/provider/create_request_vendor_detals.dart';
import 'package:marchandise/provider/salesperson_provider.dart';
import 'package:marchandise/screens/marchandiser_screens/add_product_list_screen.dart';
import 'package:marchandise/screens/salesman_screens/model/merchendiser_api_service.dart';
import 'package:marchandise/screens/model/vendor_and_salesperson_model.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/willpop.dart';
import 'package:provider/provider.dart';

class SalesPersonDetailsModel {
  final int id;
  final String name;

  SalesPersonDetailsModel({required this.id, required this.name});
}

class SelectSalesmanScreen extends StatefulWidget {
  const SelectSalesmanScreen({super.key});

  @override
  State<SelectSalesmanScreen> createState() => _SelectSalesmanScreenState();
}

class _SelectSalesmanScreenState extends State<SelectSalesmanScreen> {
  GlobalKey _expansionKey = GlobalKey();
  String selectedCustomer = "";
  bool _isExpanded = false;
  String selectedSalesManName = "";
  int? selectedSalesPersonId;
  final TextEditingController _remarksController = TextEditingController();

  final MerchendiserApiService apiService = MerchendiserApiService();
  late Future<VendorAndSalesPersonModel> salesmanData;
  late Willpop willpop;

  List<SalesPerson> _allSalesPersons = [];
  List<SalesPerson> _filteredSalesPersons = [];

  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var vendorDetailsProvider =
          Provider.of<CreateRequestVendorDetailsProvider>(context,
              listen: false);
      _fetchSalesmanData(vendorDetailsProvider.vendorId);
    });
  }

  void _fetchSalesmanData(int? vendorID) {
    salesmanData = apiService.getVendorAndSalesPersonData(vendorID);
    salesmanData.then((data) {
      setState(() {
        _allSalesPersons = data.data.salesPersons;
        _filteredSalesPersons = _allSalesPersons;
        // Set initial selected sales person
        var vendorDetailsProvider =
            Provider.of<CreateRequestVendorDetailsProvider>(context,
                listen: false);
        selectedSalesManName = vendorDetailsProvider.salesPersonName ??
            _allSalesPersons.first.salesPersonName;
        selectedSalesPersonId = vendorDetailsProvider.salesPerson ??
            _allSalesPersons.first.salesPerson;
        selectedCustomer = selectedSalesManName;
      });
    });
  }

  void _filterSalesPersons(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSalesPersons = _allSalesPersons;
      } else {
        _filteredSalesPersons = _allSalesPersons
            .where((person) => person.salesPersonName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var salesPersonDetailsProvider =
        Provider.of<SalesPersonDetailsProvider>(context);

    var vendorDetailsProvider =
        Provider.of<CreateRequestVendorDetailsProvider>(context);
    int? salesPerson = vendorDetailsProvider.salesPerson;
    String? salesPersonName = vendorDetailsProvider.salesPersonName;
    print("Selected Vendor  SalesPerson ID : $salesPerson");
    print("Selected Vendor  SalesPerson Name : $salesPersonName");

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return willpop.onWillPop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
            ),
          ),
          elevation: 0,
          title: Text(
            "Choose Sales Person",
            style: TextStyle(
              fontWeight: FontWeight.w700,
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
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    "MR",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey[100]!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Container(
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.purple,
                              child: Center(
                                child: Text(
                                  selectedCustomer.isNotEmpty
                                      ? selectedCustomer.substring(0, 1)
                                      : "S",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            title: Text(
                              selectedCustomer.isEmpty
                                  ? "SalesPerson"
                                  : selectedCustomer,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: _filteredSalesPersons.isNotEmpty
                                ? Icon(
                                    _isExpanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: Colors.black,
                                  )
                                : null,
                            onTap: () {
                              if (_filteredSalesPersons.isNotEmpty) {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              }
                            },
                          ),
                          if (_isExpanded)
                            Column(
                              children: [
                                Container(
                                  height: screenHeight * 0.07,
                                  child: TextField(
                                    onChanged: _filterSalesPersons,
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: screenHeight * 0.3,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _filteredSalesPersons.length,
                                    itemBuilder: (context, index) {
                                      String salesManName =
                                          _filteredSalesPersons[index]
                                              .salesPersonName;
                                      String firstLetterofSalesMan =
                                          salesManName.substring(0, 1);
                                      return ListTile(
                                        onTap: () {
                                          setState(() {
                                            selectedCustomer = salesManName;
                                            selectedSalesManName = salesManName;
                                            selectedSalesPersonId =
                                                _filteredSalesPersons[index]
                                                    .salesPerson;
                                            _isExpanded = false;
                                          });
                                        },
                                        title: Text(salesManName),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.purple,
                                          child: Center(
                                            child: Text(
                                              firstLetterofSalesMan,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Remarks",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _remarksController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter your remarks here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.purple,
          onPressed: () {
            if (selectedSalesManName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content:
                      const Center(child: Text('Please choose a sales person')),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              );
            } else {
              salesPersonDetailsProvider.setSalesPersonDetails(
                selectedSalesManName,
                selectedSalesPersonId!,
                _remarksController.text,
              );
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddProductListViewScreen()));
            }
          },
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
