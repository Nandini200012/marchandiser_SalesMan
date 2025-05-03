import 'dart:convert';
import 'dart:developer';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as flutterMaterial;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:marchandise/model/report_list_model.dart';
import 'package:marchandise/screens/manager_screens/api_service/manager_api_service.dart';
import 'package:marchandise/screens/model/Vendors.dart';
import 'package:marchandise/screens/salesman_screens/model/merchendiser_api_service.dart';
import 'package:marchandise/screens/salesman_screens/salesman_report_details_screen.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/urls.dart';
import 'package:marchandise/utils/willpop.dart';
import 'package:http/http.dart' as http;

class SalesmanDashboardScreen extends StatefulWidget {
  const SalesmanDashboardScreen({super.key});

  @override
  State<SalesmanDashboardScreen> createState() =>
      _SalesmanDashboardScreenState();
}

class _SalesmanDashboardScreenState extends State<SalesmanDashboardScreen> {
  final ManagerApiService apiService = ManagerApiService();
  final MerchendiserApiService merchandiserapiService =
      MerchendiserApiService();
  Faker faker = Faker();
  DateTime _selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();
  Data? reportListData;
  Status selectedStatus = Status.banding;
  late Willpop willpop;
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();

// new
  List<Vendors> vendorList = [];
  List<Map<String, dynamic>> salesPersonList = [];
  String? selectedVendor;
  int? selectedVendorID;
  String? selectedSalesPerson;
  int? selectedSalesPersonID;
  TextEditingController vendorController = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();

  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 20;
  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);

    fetchData("B");
    fetchVendors();
    fetchSalesPersonList();
  }

  void fetchData(String filterMode) async {
    try {
      final reportList = await apiService.getReportList(
        fromDate: _selectedFromDate.toString(),
        toDate: _selectedToDate.toString(),
        reportListMode: "SM",
        filterMode: filterMode,
        pageNo: 1,
      );

      setState(() {
        reportListData = reportList.data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchSalesPersonList() async {
    try {
      var response = await http.get(
        Uri.parse(Urls.getSalesPersons),
      );
      if (response.statusCode == 200) {
        log('salesperson: ${response.body}');
        var decodedResponse = jsonDecode(response.body);
        if (decodedResponse['isSuccess']) {
          List<dynamic> salesPersonsData =
              decodedResponse['data']['salesPersons'];
          final mappedList = salesPersonsData
              .map<Map<String, dynamic>>((e) => {
                    "salesPersonID": e['salesPerson'],
                    "salesPersonName": e['salesPersonName']
                  })
              .toList();
          setState(() {
            salesPersonList = mappedList; // Assign the mapped list
          });
          return mappedList;
        } else {
          throw Exception('API call was not successful');
        }
      } else {
        throw Exception('Failed to load salespersons');
      }
    } catch (e) {
      print("Error fetching salespersons: $e");
      return [];
    }
  }
  // Future<List<Map<String, dynamic>>> fetchSalesPersonList() async {
  //   Map<String, String> headers = {
  //     'IsManager': 'null',
  //     'selectedTab': '',
  //   };
  //   var response = await http.get(
  //     Uri.parse(Urls.getSalesPersons),
  //   );
  //   if (response.statusCode == 200) {
  //     log('salesperson: ${response.body}');
  //     var decodedResponse = jsonDecode(response.body);
  //     if (decodedResponse['isSuccess']) {
  //       List<dynamic> salesPersonsData =
  //           decodedResponse['data']['salesPersons'];
  //       setState(() {
  //         salesPersonList = decodedResponse['data']['salesPersons'];
  //       });
  //       return salesPersonsData
  //           .map<Map<String, dynamic>>((e) => {
  //                 "salesPersonID": e['salesPerson'],
  //                 "salesPersonName": e['salesPersonName']
  //               })
  //           .toList();
  //     } else {
  //       throw Exception('API call was not successful');
  //     }
  //   } else {
  //     throw Exception('Failed to load salespersons');
  //   }
  // }

  Future<void> fetchVendors({String query = '', int page = 1}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newVendors = await merchandiserapiService.fetchVendors(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      setState(() {
        if (page == 1) {
          vendorList = newVendors;
        } else {
          vendorList.addAll(newVendors);
        }
        currentPage = page;
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return willpop.onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFF9C4),
          automaticallyImplyLeading: false,
          elevation: 0,
          title: const Text(
            "Reports",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/excel_icon.png',
              ),
            ),
            // Icon(
            //   Icons.download,
            //   color: Colors.white,
            //   size: 8.sp,
            // ),
            SizedBox(
              width: 5.sp,
            ),
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
                  child: Text("SM"),
                ),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double fontSizeFactor = screenWidth / 1000;

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
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, Status.banding, true),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "From: ${DateFormat('dd/MM/yyyy').format(_selectedFromDate)}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeFactor * 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, Status.banding, false),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "To: ${DateFormat('dd/MM/yyyy').format(_selectedToDate)}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSizeFactor * 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: 200.w, maxHeight: 255.h),
                              child: TypeAheadFormField<Vendors>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: vendorController,
                                  decoration: InputDecoration(
                                    labelText: 'Select Customer',
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
                                                // _refreshCurrentTab();
                                              });
                                            },
                                          ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                suggestionsCallback: (pattern) {
                                  return vendorList.where((vendor) => vendor
                                      .vendorName
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()));
                                },
                                itemBuilder: (context, Vendors suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.vendorName),
                                    subtitle: Text(suggestion.vendorCode),
                                  );
                                },
                                onSuggestionSelected: (Vendors suggestion) {
                                  setState(() {
                                    selectedVendor = suggestion.vendorName;
                                    selectedVendorID = suggestion.vendorId;
                                    vendorController.text =
                                        suggestion.vendorName;
                                    // _refreshCurrentTab();
                                  });
                                },
                                noItemsFoundBuilder: (context) => Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('No Vendor found'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 500,
                              ),
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
                                                // _refreshCurrentTab();
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
                                    // _refreshCurrentTab();
                                  });
                                },
                                noItemsFoundBuilder: (context) => Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('No Salesperson found'),
                                ),
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child: ConstrainedBox(
                          //     constraints: BoxConstraints(
                          //       maxWidth: 500,
                          //     ),
                          //     child: TypeAheadFormField<Map<String, dynamic>>(
                          //       textFieldConfiguration: TextFieldConfiguration(
                          //         controller: salesPersonController,
                          //         decoration: InputDecoration(
                          //           labelText: 'Select Salesperson',
                          //           border: OutlineInputBorder(
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //           suffixIcon: salesPersonController
                          //                   .text.isEmpty
                          //               ? Icon(Icons.search)
                          //               : IconButton(
                          //                   icon: Icon(Icons.close),
                          //                   onPressed: () {
                          //                     setState(() {
                          //                       salesPersonController.clear();
                          //                       selectedSalesPerson = null;
                          //                       selectedSalesPersonID = null;
                          //                       // _refreshCurrentTab();
                          //                     });
                          //                   },
                          //                 ),
                          //           filled: true,
                          //           fillColor: Colors.white,
                          //         ),
                          //       ),
                          //       suggestionsCallback: (pattern) {
                          //         return salesPersonList.where((salesPerson) =>
                          //             salesPerson['salesPersonName']
                          //                 .toLowerCase()
                          //                 .contains(pattern.toLowerCase()));
                          //       },
                          //       itemBuilder:
                          //           (context, Map<String, dynamic> suggestion) {
                          //         return ListTile(
                          //           title: Text(suggestion['salesPersonName']),
                          //         );
                          //       },
                          //       onSuggestionSelected:
                          //           (Map<String, dynamic> suggestion) {
                          //         setState(() {
                          //           selectedSalesPerson =
                          //               suggestion['salesPersonName'];
                          //           selectedSalesPersonID =
                          //               suggestion['salesPersonID'];
                          //           salesPersonController.text =
                          //               suggestion['salesPersonName'];
                          //           // _refreshCurrentTab();
                          //         });
                          //       },
                          //       noItemsFoundBuilder: (context) => Padding(
                          //         padding: EdgeInsets.all(8.0),
                          //         child: Text('No Salesperson found'),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                        width: double.infinity,
                      ),
                      Row(
                        children: [
                          buildStatusCard(
                              Status.banding, "Banding", "B", constraints),
                          SizedBox(width: 10),
                          buildStatusCard(
                              Status.discount, "Discount", "D", constraints),
                          SizedBox(width: 10),
                          buildStatusCard(
                              Status.returning, "Return", "R", constraints),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFFFBC02D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            tileColor: Color(0xFFFBC02D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Color(0xFFFBC02D),
                                width: 1.0,
                              ),
                            ),
                            leadingAndTrailingTextStyle: TextStyle(
                              fontSize:
                                  constraints.maxWidth > 600 ? 5.sp : 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10.0, left: 10),
                              child: Text(
                                "Req No",
                                style: TextStyle(
                                  fontSize:
                                      constraints.maxWidth > 600 ? 5.sp : 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Container(
                              height: 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10.0, left: 10),
                                    child: Text(
                                      "Date",
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth > 600
                                            ? 5.sp
                                            : 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: const SizedBox(
                                      width: 10,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10.0, left: 10),
                                      child: Text(
                                        "Name",
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth > 600
                                              ? 5.sp
                                              : 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: const SizedBox(
                                      width: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: const SizedBox(
                                      width: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      buildListViewForStatus(Status.banding, constraints),
                      buildListViewForStatus(Status.discount, constraints),
                      buildListViewForStatus(Status.returning, constraints),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(
      BuildContext context, Status status, bool isFromDate) async {
    String filterMode;

    switch (status) {
      case Status.banding:
        filterMode = "B";
        break;
      case Status.discount:
        filterMode = "D";
        break;
      case Status.returning:
        filterMode = "R";
        break;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 2 * 365)),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (picked != null &&
        picked != (isFromDate ? _selectedFromDate : _selectedToDate)) {
      setState(() {
        if (isFromDate) {
          _selectedFromDate = picked;
        } else {
          _selectedToDate = picked;
        }
        fetchData(filterMode);
      });
    }
  }

  Widget buildStatusCard(Status status, String title, String filterMode,
      BoxConstraints constraints) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = status;
            fetchData(filterMode);
          });
        },
        child: flutterMaterial.Card(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFFBC02D)),
              color:
                  selectedStatus == status ? Color(0xFFFBC02D) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 5.sp : 14.sp,
                    color: selectedStatus == status
                        ? Colors.white
                        : Color(0xFFFBC02D),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  getStatusValue(status),
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 5.sp : 16.sp,
                    fontWeight: FontWeight.w700,
                    color: selectedStatus == status
                        ? Colors.white
                        : Color(0xFFFBC02D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getStatusValue(Status status) {
    switch (status) {
      case Status.banding:
        return reportListData?.cards[0].bandig.toString() ?? "0";
      case Status.discount:
        return reportListData?.cards[0].discount.toString() ?? "0";
      case Status.returning:
        return reportListData?.cards[0].cardReturn.toString() ?? "0";
      default:
        return "0";
    }
  }

  Widget buildListViewForStatus(Status status, BoxConstraints constraints) {
    return selectedStatus == status
        ? reportListData == null || reportListData!.details.isEmpty
            ? const Expanded(
                child: Center(
                  child: Text("No Data"),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reportListData?.details.length,
                  itemBuilder: (context, index) {
                    return buildListTile(
                        index, reportListData?.details[index], constraints);
                  },
                ),
              )
        : Container();
  }

  Widget buildListTile(
      int index, Detail? detailData, BoxConstraints constraints) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SalesManReportDetailsScreen(
                requestId: reportListData!.details[index].requestId,
                selectedStatus: selectedStatus,
                CustomerName: reportListData!.details[index].vendorName)));
      },
      child: flutterMaterial.Card(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              detailData?.requestId.toString() ?? "",
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 5.sp : 10.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xff023e8a),
              ),
            ),
          ),
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10.w),
                Text(
                  detailData?.date ?? "",
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 5.sp : 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff023e8a),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    detailData?.vendorName ?? "",
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 600 ? 5.sp : 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff023e8a),
                    ),
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum Status { banding, discount, returning }
