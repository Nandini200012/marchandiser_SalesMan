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
      designSize: const Size(1440, 1024), // Web default
      minTextAdapt: true,
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async => willpop.onWillPop(),
          child: Scaffold(
            backgroundColor: const Color(0xFFF0F2F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              automaticallyImplyLeading: false,
              title: const Text(
                "Sales Manager",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: GestureDetector(
                    onTap: () {
                      DynamicAlertBox().logOut(context, "Do you want to logout",
                          () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => const SplashScreen()));
                      });
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 20,
                      child: Text("SM", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                )
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _refreshData,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  children: [
                    /// HEADER: Search, Filters, Sort
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Requests [$totalRequests]",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            )),
                        Row(
                          children: [
                            /// Search box
                            SizedBox(
                              width: 300,
                              child: TextField(
                                onChanged: _filterRequests,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: "Search by name or code",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            /// Sort dropdown
                            DropdownButton<String>(
                              value: selectedSortOption,
                              underline: const SizedBox(),
                              borderRadius: BorderRadius.circular(8),
                              items: ['Customer Name', 'PostDate'].map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSortOption = value!;
                                  _sortRequests();
                                });
                              },
                            ),

                            /// Toggle sorting
                            IconButton(
                              icon: Icon(
                                isAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                setState(() {
                                  isAscending = !isAscending;
                                  _sortRequests();
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// GRID
                    Expanded(
                      child: FutureBuilder<SalesmanRequestListModel>(
                        future: salesRequestList,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.data.isEmpty) {
                            return const Center(
                                child: Text("No requests available"));
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, index) {
                              final request = filteredRequests[index];

                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      const BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// Header row
                                        Row(
                                          children: [
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    request.vendorName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text(
                                                            'Customer Code: ${request.vendorCode}',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          Text(
                                                            'Post Date: ${request.date}',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 255, 179, 0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text(
                                                            'Req ID: ${request.requestId}',
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const Divider(height: 24),

                                        /// Footer row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${request.totalProduct} Products",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        RequestDetailsScreen(
                                                      vendorName:
                                                          request.vendorName,
                                                      vendorId: request
                                                          .vendorCode
                                                          .toString(),
                                                      requestId:
                                                          request.requestId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    const Color.fromARGB(
                                                        255, 255, 183, 0),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  side: BorderSide(
                                                      color: Colors
                                                          .amber.shade800),
                                                ),
                                              ),
                                              child: const Text("Details"),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  log('Comment: ${request.requestId}');
                                                  showCommentPopup(
                                                    context,
                                                    requestID:
                                                        request.requestId,
                                                    productID: "-1",
                                                    productName: "null",
                                                  );
                                                },
                                                icon: Icon(
                                                    Icons.message_outlined,
                                                    color: const Color.fromARGB(
                                                        255, 255, 170, 0))),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
