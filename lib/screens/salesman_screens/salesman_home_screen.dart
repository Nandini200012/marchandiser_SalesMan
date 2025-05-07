import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marchandise/provider/salesman_request_provider.dart';
import 'package:marchandise/screens/salesman_screens/api_service/salesman_api_service.dart';
import 'package:marchandise/screens/salesman_screens/model/salesman_request_list_model.dart';
import 'package:marchandise/screens/salesman_screens/request_details_screen.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/comment_box.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/willpop.dart';
import 'package:provider/provider.dart';

class SalesmanHomeScreen extends StatefulWidget {
  const SalesmanHomeScreen({super.key});

  @override
  State<SalesmanHomeScreen> createState() => _SalesmanHomeScreenState();
}

final SalesManApiService apiService = SalesManApiService();
late Future<SalesmanRequestListModel> salesRequestList;
late Willpop willpop;
int totalRequests = 0;
List<Datum> filteredRequests = [];
String searchQuery = "";
bool isAscending = true; // For ascending/descending sorting
String selectedSortOption = 'Customer Name'; // Default sort option

class _SalesmanHomeScreenState extends State<SalesmanHomeScreen> {
  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    _refreshData();
  }

  Future<void> _refreshData() async {
    salesRequestList = SalesManApiService().getSalesmanRequestList();
    final result = await salesRequestList; // Await the future to get the result
    setState(() {
      totalRequests = result.data.length; // Update the total request count
      filteredRequests = result.data; // Update the filtered requests
    });
  }

  void _filterRequests(String query) {
    setState(() {
      searchQuery = query;
      if (searchQuery == "") {
        _refreshData(); // Call _refreshData() if the search query is empty
      } else {
        filteredRequests = filteredRequests
            .where((request) =>
                request.vendorName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                request.vendorCode
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase())) // Search vendorId as well
            .toList();
      }
    });
  }

  void _sortRequests() {
    setState(() {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');

      if (selectedSortOption == 'Customer Name') {
        filteredRequests.sort((a, b) => isAscending
            ? a.vendorName.compareTo(b.vendorName)
            : b.vendorName.compareTo(a.vendorName));
      } else if (selectedSortOption == 'PostDate') {
        filteredRequests.sort((a, b) {
          try {
            // Assume 'formatter' is an instance of DateFormat you’ve initialized elsewhere
            DateTime dateA = formatter.parse(a.date); // Parse to DateTime
            DateTime dateB = formatter.parse(b.date); // Parse to DateTime

            // Perform the comparison based on ascending or descending order
            return isAscending
                ? dateA.compareTo(dateB)
                : dateB.compareTo(dateA);
          } catch (e) {
            // Handle any date parsing exceptions
            print('Error parsing date: $e');
            return 0; // Return 0 so it doesn't affect the sorting in case of an error
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            return willpop.onWillPop();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFFFF9C4),
              automaticallyImplyLeading: false,
              title: Text(
                "Sales Man",
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 15.w),
                  child: GestureDetector(
                    onTap: () {
                      DynamicAlertBox().logOut(context, "Do you Want to Logout",
                          () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => SplashScreen()));
                      });
                    },
                    child: CircleAvatar(
                      radius: 22.r,
                      child: Text("SM"),
                    ),
                  ),
                ),
              ],
            ),
            resizeToAvoidBottomInset: false,
            body: RefreshIndicator(
              onRefresh: _refreshData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
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
                        padding: EdgeInsets.all(10.w),
                        child: Column(
                          children: [
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Request [$totalRequests]",
                                  style: TextStyle(
                                    fontWeight: FontWeight
                                        .w600, // Use a slightly heavier weight
                                    color: Colors.black,
                                    fontSize: 5
                                        .sp, // Increase the font size for better readability
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 200.w, // Maintain search box width
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(
                                                0.2), // Subtle shadow for depth
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0,
                                                3), // Offset for slight lift effect
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        onChanged: _filterRequests,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.search,
                                              color: Colors.grey
                                                  .shade600), // Lighter icon color
                                          hintText: "Search",
                                          hintStyle: TextStyle(
                                            fontSize: 5
                                                .sp, // Slightly larger font size
                                            color: Colors.grey
                                                .shade500, // Softer hint text color
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12
                                                .h, // Increased vertical padding for a comfortable click area
                                            horizontal: 10.w,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            borderSide: BorderSide(
                                                color: Colors.grey
                                                    .shade300), // Soft border color
                                          ),
                                        ),
                                        style: TextStyle(
                                            fontSize: 5
                                                .sp), // Larger input text size for readability
                                      ),
                                    ),
                                    SizedBox(
                                        width: 8
                                            .w), // Add more spacing between search and dropdown

                                    // Dropdown for sorting options
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: DropdownButton<String>(
                                        value: selectedSortOption,
                                        items: <String>[
                                          'Customer Name',
                                          'PostDate'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                  fontSize: 5
                                                      .sp), // Larger font for better readability
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedSortOption = newValue!;
                                            _sortRequests();
                                          });
                                        },
                                        underline:
                                            SizedBox(), // Remove default underline
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: Colors
                                                .black), // Modern dropdown arrow
                                      ),
                                    ),
                                    SizedBox(
                                        width: 8
                                            .w), // Consistent spacing between elements

                                    IconButton(
                                      icon: Icon(
                                        isAscending
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color: Colors.black.withOpacity(
                                            0.7), // Slightly transparent for a smoother look
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isAscending = !isAscending;
                                          _sortRequests(); // Toggle sorting direction
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Expanded(
                              child: FutureBuilder<SalesmanRequestListModel>(
                                future: salesRequestList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text("Error: ${snapshot.error}"));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.data.isEmpty) {
                                    return Center(
                                        child: Text("No Request Available"));
                                  } else {
                                    List<Datum> datums = filteredRequests;
                                    return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            constraints.maxWidth > 600 ? 3 : 1,
                                        childAspectRatio:
                                            constraints.maxWidth > 600
                                                ? 2
                                                : 6.5,
                                        crossAxisSpacing: 10.w,
                                        mainAxisSpacing: 10.h,
                                      ),
                                      itemCount: datums.length,
                                      itemBuilder: (context, index) {
                                        String selectedVendorName =
                                            datums[index].vendorName;
                                        String selectedVendortId =
                                            datums[index].vendorCode.toString();
                                        String selectedProductQuantity =
                                            datums[index]
                                                .totalProduct
                                                .toString();
                                        int requesId = datums[index].requestId;
                                        String productFirstLetter =
                                            selectedVendorName.substring(0, 1);
                                        String date = datums[index].date;

                                        return Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.h),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.5)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading: CircleAvatar(
                                                        backgroundColor:
                                                            Color(0xFFFBC02D),
                                                        child: Text(
                                                          productFirstLetter,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        selectedVendorName,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 3.sp,
                                                        ),
                                                      ),
                                                      subtitle: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Customer Code : $selectedVendortId',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          Text(
                                                            'Post Date : $date',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.grey,
                                                      thickness: 1.h,
                                                      indent: 16.w,
                                                      endIndent: 16.w,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.w),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                selectedProductQuantity,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      constraints.maxWidth >
                                                                              600
                                                                          ? 4.sp
                                                                          : 18.sp,
                                                                  color: Color(
                                                                      0xFFFBC02D),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 5.w),
                                                              Text(
                                                                "Products",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      constraints.maxWidth >
                                                                              600
                                                                          ? 3.sp
                                                                          : 12.sp,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: constraints
                                                                        .maxWidth >
                                                                    600
                                                                ? 50.w
                                                                : 150.w,
                                                            child: TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                    return RequestDetailsScreen(
                                                                      vendorName:
                                                                          selectedVendorName,
                                                                      vendorId:
                                                                          selectedVendortId,
                                                                      requestId:
                                                                          requesId,
                                                                    );
                                                                  }),
                                                                );
                                                              },
                                                              child: Text(
                                                                "Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFFFBC02D),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      constraints.maxWidth >
                                                                              600
                                                                          ? 4.sp
                                                                          : 12.sp,
                                                                ),
                                                              ),
                                                              style:
                                                                  ButtonStyle(
                                                                padding:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                  EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.h),
                                                                ),
                                                                side: MaterialStateProperty
                                                                    .all<
                                                                        BorderSide>(
                                                                  BorderSide(
                                                                    color: Color(
                                                                        0xFFFBC02D),
                                                                    width:
                                                                        1.0.w,
                                                                  ),
                                                                ),
                                                                shape: MaterialStateProperty
                                                                    .all<
                                                                        OutlinedBorder>(
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.r),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              log('home: $requesId, ');
                                                              showCommentPopup(
                                                                  context,
                                                                  requestID:
                                                                      requesId,
                                                                  productID:
                                                                      "-1",
                                                                  productName:
                                                                      'null');
                                                            },
                                                            icon: Icon(
                                                                Icons.message),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
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
      },
    );
  }

  commentPopup() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController _commentController = TextEditingController();
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your comment',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String comment = _commentController.text;
                // TODO: Handle comment submission logic here
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
