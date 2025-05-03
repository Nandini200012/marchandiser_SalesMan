import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as flutterMaterial;
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marchandise/model/report_list_model.dart';
import 'package:marchandise/screens/manager_screens/api_service/manager_api_service.dart';
import 'package:marchandise/screens/marchandiser_screens/create_request_screen.dart';
import 'package:marchandise/screens/marchandiser_screens/murchandiser_report_details_screen.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/willpop.dart';

class MarchendiserDashboardScreen extends StatefulWidget {
  const MarchendiserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MarchendiserDashboardScreen> createState() =>
      _MarchendiserDashboardScreenState();
}

class _MarchendiserDashboardScreenState
    extends State<MarchendiserDashboardScreen> {
  final ManagerApiService apiService = ManagerApiService();

  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;
  DateTime _fromDate = DateTime.now().subtract(Duration(days: 7)); // From date
  DateTime _toDate = DateTime.now(); // To date
  bool showRequestList = true;
  DateTime currentDate = DateTime.now();
  Status selectedStatus = Status.request;
  late Future<ReportListModel> reportFutureAll;
  late Future<ReportListModel> reportFuturePending;
  late Future<ReportListModel> reportFutureRejected;
  late Willpop willpop;
  Data? reportListData;
  ReportListModel? reportList;
  String filterMode = "All";

  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    fetchData(filterMode);
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible) {
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (!_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      }
    });
  }

  Future<void> _refresh() async {
    fetchData("All");
  }

  void fetchData(String filterMode) async {
    try {
      final reportList = await apiService.getReportList(
        fromDate: _fromDate.toString(),
        toDate: _toDate.toString(),
        reportListMode: "MR",
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

  Future<ReportListModel> _loadReportList(
    String filterMode,
  ) async {
    try {
      EasyLoading.show();
      final managerApiService = ManagerApiService();
      return managerApiService.getReportList(
        fromDate: _fromDate.toString(),
        toDate: _toDate.toString(),
        reportListMode: "MR",
        filterMode: "All",
        pageNo: 1,
      );
    } catch (e) {
      print("Error fetching data: $e");
      throw e; // Rethrow the error to be handled by the FutureBuilder
    } finally {
      EasyLoading.dismiss();
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
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.purple,
            title: const Text(
              "Reports",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
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
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            title: Column(
                              children: [
                                Text(
                                  "Do you want to Logout",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.all(
                                          const BorderSide(
                                              color: Colors.purple,
                                              width:
                                                  2.0), // Set the border color and width
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SplashScreen()));
                                      },
                                      child: Text("Yes")),
                                  const SizedBox(width: 15),
                                  TextButton(
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.all(
                                          const BorderSide(
                                              color: Colors.blue,
                                              width:
                                                  2.0), // Set the border color and width
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("No")),
                                ],
                              )
                            ],
                          );
                        });
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    child: Text("MR"),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.h,
                        width: double.infinity,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _selectFromDate(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    TextButton(
                                      child: Text(
                                        _fromDate == null
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(DateTime.now())
                                                .toString()
                                            : DateFormat('dd/MM/yyyy')
                                                .format(_fromDate),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.sp),
                                      ),
                                      onPressed: () {
                                        _selectFromDate(context);
                                      },
                                    ),
                                    const Spacer(),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.calendar_month,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _selectToDate(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    TextButton(
                                      child: Text(
                                        _toDate == null
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(DateTime.now())
                                                .toString()
                                            : DateFormat('dd/MM/yyyy')
                                                .format(_toDate),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.sp),
                                      ),
                                      onPressed: () {
                                        _selectToDate(context);
                                      },
                                    ),
                                    const Spacer(),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.calendar_month,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStatus = Status.request;
                                  filterMode = "All";
                                  fetchData(filterMode);
                                  print("Status:>>>$selectedStatus");
                                });
                              },
                              child: flutterMaterial.Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Color(0xff023e8a)),
                                      color: selectedStatus == Status.request
                                          ? Colors.purple
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 5.h),
                                      Text(
                                        "Request",
                                        style: TextStyle(
                                          color:
                                              selectedStatus == Status.request
                                                  ? Colors.white
                                                  : Colors.purple,
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        reportListData?.cards[0].requests
                                                .toString() ??
                                            "0",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              selectedStatus == Status.request
                                                  ? Colors.white
                                                  : Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStatus = Status.pending;
                                  filterMode = "P";
                                  fetchData(filterMode);
                                  print("Status:>>>$selectedStatus");
                                });
                              },
                              child: flutterMaterial.Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Color(0xff023e8a)),
                                      color: selectedStatus == Status.pending
                                          ? Colors.purple
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(
                                        "Pending",
                                        style: TextStyle(
                                          color:
                                              selectedStatus == Status.pending
                                                  ? Colors.white
                                                  : Colors.purple,
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        reportListData?.cards[0].pending
                                                .toString() ??
                                            "0",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              selectedStatus == Status.pending
                                                  ? Colors.white
                                                  : Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStatus = Status.rejected;
                                  filterMode = "RJ";
                                  fetchData(filterMode);
                                  print("Status:>>>$selectedStatus");
                                });
                              },
                              child: flutterMaterial.Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Color(0xff023e8a)),
                                      color: selectedStatus == Status.rejected
                                          ? Colors.purple
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(
                                        "Reject",
                                        style: TextStyle(
                                          color:
                                              selectedStatus == Status.rejected
                                                  ? Colors.white
                                                  : Colors.purple,
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        reportListData?.cards[0].reject
                                                .toString() ??
                                            "0",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              selectedStatus == Status.rejected
                                                  ? Colors.white
                                                  : Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: ListTile(
                              tileColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Color(
                                      0xff023e8a), // Adjust border color as needed
                                  width: 1.0, // Set border width
                                ),
                              ),
                              leadingAndTrailingTextStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff023e8a),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "Req No",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              title: Container(
                                height: 40,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 30.w),
                                    Text(
                                      "Name",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (selectedStatus == Status.request)
                        reportListData == null ||
                                reportListData!.details.isEmpty
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
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MarchendiserReportDetailsScreen(
                                                        requestId:
                                                            reportListData!
                                                                .details[index]
                                                                .requestId,
                                                        selectedStatus:
                                                            selectedStatus,
                                                      )));
                                        },
                                        child: flutterMaterial.Card(
                                          color: Colors.white,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            leading: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text(
                                                reportListData?.details[index]
                                                        .requestId
                                                        .toString() ??
                                                    "",
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff023e8a),
                                                ),
                                              ),
                                            ),
                                            title: Container(
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 10),
                                                  Text(
                                                    reportListData
                                                            ?.details[index]
                                                            .date ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff023e8a),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                      child: Text(
                                                    reportListData
                                                            ?.details[index]
                                                            .vendorName ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff023e8a),
                                                    ),
                                                    maxLines: null,
                                                  )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })),
                      if (selectedStatus == Status.pending)
                        reportListData!.details.isEmpty
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
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MarchendiserReportDetailsScreen(
                                                        requestId:
                                                            reportListData!
                                                                .details[index]
                                                                .requestId,
                                                        selectedStatus:
                                                            selectedStatus,
                                                      )));
                                        },
                                        child: flutterMaterial.Card(
                                          color: Colors.white,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            leading: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text(
                                                reportListData?.details[index]
                                                        .requestId
                                                        .toString() ??
                                                    "",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff023e8a),
                                                ),
                                              ),
                                            ),
                                            title: Container(
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    reportListData
                                                            ?.details[index]
                                                            .date ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff023e8a),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                      child: Text(
                                                    reportListData
                                                            ?.details[index]
                                                            .vendorName ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff023e8a),
                                                    ),
                                                    maxLines: null,
                                                  )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })),
                      if (selectedStatus == Status.rejected)
                        reportListData!.details.isEmpty
                            ? const Expanded(
                                child: Center(
                                  child: Text("No Data"),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: reportListData?.details.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MarchendiserReportDetailsScreen(
                                                    requestId: reportListData!
                                                        .details[index]
                                                        .requestId,
                                                    selectedStatus:
                                                        selectedStatus,
                                                  )));
                                    },
                                    child: flutterMaterial.Card(
                                      color: Colors.white,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        leading: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            reportListData
                                                    ?.details[index].requestId
                                                    .toString() ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff023e8a),
                                            ),
                                          ),
                                        ),
                                        title: Container(
                                          child: Row(
                                            children: [
                                              SizedBox(width: 10),
                                              Text(
                                                reportListData
                                                        ?.details[index].date ??
                                                    "",
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff023e8a),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                  child: Text(
                                                reportListData?.details[index]
                                                        .vendorName ??
                                                    "",
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff023e8a),
                                                ),
                                                maxLines: null,
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: FloatingActionButton(
              shape: CircleBorder(),
              elevation: 2,
              backgroundColor: Colors.purple,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateRequestScreen()));
              },
              child: Icon(Icons.add, color: Colors.white),
            ),
          )),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime.now().subtract(Duration(days: 2 * 365)),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
      fetchData(filterMode);
      return picked;
    }

    return null;
  }

  Future<DateTime?> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime.now().subtract(Duration(days: 2 * 365)),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
      fetchData(filterMode);
      return picked;
    }

    return null;
  }
}

enum Status { request, pending, rejected }
