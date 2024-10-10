import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marchandise/model/report_list_model.dart' as model;
import 'package:marchandise/screens/manager_screens/api_service/manager_api_service.dart';
import 'package:marchandise/screens/manager_screens/manager_report_details.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/willpop.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final ManagerApiService apiService = ManagerApiService();

  DateTime _selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();
  model.Data? reportListData; // Aliased Data class
  Status selectedStatus = Status.approved;
  late Willpop willpop;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    fetchData("A");
  }

  void fetchData(String filterMode) async {
    setState(() {
      isLoading = true;
    });

    try {
      final reportList = await apiService.getReportList(
        fromDate: _selectedDate.toString() ?? currentDate.toString(),
        toDate: _selectedDate.toString() ?? currentDate.toString(),
        reportListMode: "MG",
        filterMode: filterMode,
        pageNo: 1,
      );

      setState(() {
        reportListData = reportList.data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
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
          backgroundColor: Color.fromARGB(255, 207, 68, 18),
          elevation: 0,
          automaticallyImplyLeading: false,
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
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () {
                  DynamicAlertBox().logOut(context, "Do you Want to Logout", () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SplashScreen()));
                  });
                },
                child: CircleAvatar(
                  radius: 20,
                  child: Text("MGR"),
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;
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
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02),
                child: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      InkWell(
                        onTap: () {
                          _selectDate(context, selectedStatus);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: screenHeight * 0.05,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              TextButton(
                                child: Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: fontSizeFactor * 16),
                                ),
                                onPressed: () {
                                  _selectDate(context, selectedStatus);
                                },
                              ),
                              const Spacer(),
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.calendar_month,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Wrap(
                        spacing: screenWidth * 0.02,
                        runSpacing: screenHeight * 0.02,
                        children: [
                          buildStatusCard(Status.approved, "Approved", "A",
                              fontSizeFactor),
                          buildStatusCard(Status.reject, "Reject", "R",
                              fontSizeFactor),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        height: screenHeight * 0.06,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 207, 68, 18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          tileColor: Color.fromARGB(255, 207, 68, 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xff023e8a),
                              width: 1.0,
                            ),
                          ),
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 10),
                          dense: true,
                          leading: Padding(
                            padding: EdgeInsets.only(
                                bottom: 10.0, left: screenWidth * 0.02),
                            child: Text(
                              "Req No",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeFactor * 14,
                              ),
                            ),
                          ),
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: SizedBox(
                              height: screenHeight * 0.04,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      fontSize: fontSizeFactor * 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                      fontSize: fontSizeFactor * 14,
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
                      SizedBox(height: screenHeight * 0.02),
                      Expanded(
                          child:
                          buildListViewForStatus(selectedStatus)),
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

  Future<DateTime?> _selectDate(BuildContext context, Status status) async {
    String filterMode;

    switch (status) {
      case Status.approved:
        filterMode = "A";
        break;
      case Status.reject:
        filterMode = "R";
        break;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 2 * 365)),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
      });
      fetchData(filterMode);
      return picked;
    }
    return null;
  }

  Widget buildStatusCard(
      Status status, String title, String filterMode, double fontSizeFactor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
          fetchData(filterMode);
        });
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Color(0xff023e8a), width: 1.0),
        ),
        child: Container(
          width: 150,
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selectedStatus == status
                ? Color.fromARGB(255, 207, 68, 18)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSizeFactor * 16,
                    color: selectedStatus == status
                        ? Colors.white
                        : Color.fromARGB(255, 207, 68, 18),
                  ),
                ),
              ),
              SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  getStatusValue(status),
                  style: TextStyle(
                    fontSize: fontSizeFactor * 20,
                    fontWeight: FontWeight.w700,
                    color: selectedStatus == status
                        ? Colors.white
                        : Color.fromARGB(255, 207, 68, 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getStatusValue(Status status) {
    switch (status) {
      case Status.approved:
        return reportListData?.cards[0].approved.toString() ?? "0";
      case Status.reject:
        return reportListData?.cards[0].reject.toString() ?? "0";
      default:
        return "0";
    }
  }

  Widget buildListViewForStatus(Status status) {
    return selectedStatus == status
        ? reportListData == null || reportListData!.details.isEmpty
        ? const Center(
      child: Text("No Data"),
    )
        : ListView.builder(
      shrinkWrap: true,
      itemCount: reportListData?.details.length,
      itemBuilder: (context, index) {
        return buildListTile(index, reportListData?.details[index]);
      },
    )
        : Container();
  }

  Widget buildListTile(int index, model.Detail? detailData) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth / 1000;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ManagerReportDetails(
                requestId: detailData!.requestId,
                selectedStatus: selectedStatus)));
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Color(0xff023e8a), width: 1.0),
        ),
        child: ListTile(
          dense: true,
          contentPadding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 5),
          leading: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              detailData?.requestId.toString() ?? "",
              style: TextStyle(
                fontSize: fontSizeFactor * 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff023e8a),
              ),
            ),
          ),
          title: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  detailData?.date ?? "",
                  style: TextStyle(
                    fontSize: fontSizeFactor * 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff023e8a),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    detailData?.vendorName ?? "",
                    style: TextStyle(
                      fontSize: fontSizeFactor * 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff023e8a),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

enum Status {
  approved,
  reject,
}
