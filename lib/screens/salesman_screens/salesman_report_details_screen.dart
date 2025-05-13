import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marchandise/screens/manager_screens/api_service/manager_api_service.dart';
import 'package:marchandise/screens/manager_screens/model/report_details_list_model.dart';
import 'package:marchandise/screens/salesman_screens/salesman_dashboard_screen.dart';
import 'package:marchandise/utils/willpop.dart';

class SalesManReportDetailsScreen extends StatefulWidget {
  final int requestId;
  final Status selectedStatus;
  final String CustomerName;
  const SalesManReportDetailsScreen(
      {super.key,
      required this.requestId,
      required this.selectedStatus,
      required this.CustomerName});

  @override
  State<SalesManReportDetailsScreen> createState() =>
      _SalesManReportDetailsScreenState();
}

class _SalesManReportDetailsScreenState
    extends State<SalesManReportDetailsScreen> {
  ManagerApiService apiService = ManagerApiService();
  Future<ReportDetailsListModel>? reportDetailsListFuture;
  late Willpop willpop;
  String? filterModeselection;

  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    reportDetailsListFuture = fetchData();
    print("object:>>>${widget.requestId}");
    print("object:>>>${widget.selectedStatus}");
  }

  Future<ReportDetailsListModel> fetchData() async {
    final filterMode = getStatusString(widget.selectedStatus);
    filterModeselection = getStatusString(widget.selectedStatus);

    try {
      EasyLoading.show(
          status: "Loading...",
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
      return await apiService.fetchReportDetailsList(
        reportListMode: "SM",
        filterMode: filterMode,
        requestID: widget.requestId,
      );
    } catch (e) {
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  String getStatusString(Status status) {
    switch (status) {
      case Status.banding:
        return "B";
      case Status.discount:
        return "D";
      case Status.returning:
        return "R";
      default:
        return "";
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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            widget.CustomerName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white, // Top color
                Colors.white, // New middle color (white)
                Colors.white, // New middle color (white)
                Colors.white, // New middle color (white)
                Colors.white, // New middle color (white)
                Colors.white, // Bottom color
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                    child: FutureBuilder<ReportDetailsListModel>(
                        future: reportDetailsListFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text("Error : ${snapshot.error}");
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Center(
                                child: const Text('No data available!!'));
                          } else {
                            ReportDetailsListModel reportDetailsListModel =
                                snapshot.data!;
                            return reportDetailsListModel.data.isEmpty
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Text("No data available")],
                                  )
                                // gridview nandini changes
                                : GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1.4,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                    ),
                                    itemCount: snapshot.data!.data.length,
                                    itemBuilder: (context, index) {
                                      final data = snapshot.data!.data[index];
                                      return Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: getStatusColor(
                                                        data.reqStatus)
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: getStatusColor(
                                                            data.reqStatus)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(12),
                                                      topRight:
                                                          Radius.circular(12),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Barcode: ${data.prdouctId}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              data.prdouctName,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: getStatusColor(
                                                              data.reqStatus),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Text(
                                                          data.reqStatus,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons
                                                                    .shopping_cart_outlined,
                                                                'Quantity',
                                                                data.quantity
                                                                    .toStringAsFixed(
                                                                        2),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 16),
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons
                                                                    .calendar_today_outlined,
                                                                'Expiry',
                                                                data.expiryDate ??
                                                                    'N/A',
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 16),
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons.balance,
                                                                'UOM',
                                                                data.uom ??
                                                                    'N/A',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // if (data.DiscPerc > 0 ||
                                                        // data.DiscAmount > 0)
                                                        const Divider(
                                                            height: 16),
                                                        // if (data.DiscPerc > 0)
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons.money,
                                                                'Cost',
                                                                data.cost
                                                                    .toStringAsFixed(
                                                                        2),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons.percent,
                                                                'Discount %',
                                                                data.discPerc
                                                                    .toStringAsFixed(
                                                                        2),
                                                              ),
                                                            ),
                                                            // if (data.DiscAmount > 0)
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons
                                                                    .money_off_csred_outlined,
                                                                'Discount Amt',
                                                                data.discAmount
                                                                    .toStringAsFixed(
                                                                        3),
                                                              ),
                                                            )
                                                          ],
                                                        ),

                                                        // if (data.note.isNotEmpty ||
                                                        // data.reason.isNotEmpty)
                                                        const Divider(
                                                            height: 16),
                                                        // if (data.note.isNotEmpty)
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons
                                                                    .info_outline,
                                                                'Reason',
                                                                data.reason
                                                                        .isNotEmpty
                                                                    ? data
                                                                        .reason
                                                                    : 'N/A',
                                                              ),
                                                            ),

                                                            // if (data.reason.isNotEmpty)

                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons
                                                                    .calendar_month,
                                                                'Expiry Date',
                                                                formatSalesmanDate(data
                                                                        .expiryDate
                                                                        .toString()) ??
                                                                    'N/A',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const Divider(
                                                            height: 16),
                                                        // if (data.note.isNotEmpty)
                                                        Row(
                                                          children: [
                                                            // if (data.reason.isNotEmpty)
                                                            Expanded(
                                                              child:
                                                                  _buildInfoRow(
                                                                Icons
                                                                    .note_outlined,
                                                                'Note',
                                                                data.note
                                                                        .isNotEmpty
                                                                    ? data.note
                                                                    : 'N/A',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                            // : GridView.builder(
                            //     gridDelegate:
                            //         const SliverGridDelegateWithFixedCrossAxisCount(
                            //             crossAxisCount: 3,
                            //             crossAxisSpacing: 8.0,
                            //             mainAxisSpacing: 8.0,
                            //             childAspectRatio: 5 / 3),
                            //     itemCount:
                            //         reportDetailsListModel.data.length ?? 0,
                            //     itemBuilder: (context, index) {
                            //       Datum data =
                            //           reportDetailsListModel.data[index];
                            //       return Stack(
                            //         children: [
                            //           Container(
                            //             width: double.infinity,
                            //             child: Card(
                            //               elevation: 4,
                            //               child: Padding(
                            //                 padding:
                            //                     const EdgeInsets.all(8.0),
                            //                 child: Column(
                            //                   crossAxisAlignment:
                            //                       CrossAxisAlignment.start,
                            //                   mainAxisAlignment:
                            //                       MainAxisAlignment
                            //                           .spaceEvenly,
                            //                   children: [
                            //                     Text(
                            //                       "BarCode : ${data.prdouctId}",
                            //                       style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 15.sp,
                            //                       ),
                            //                     ),
                            //                     Text(
                            //                       // 'dghjkesruejrfbj hjrbetmnsg berdmewrgs dfjghjsdbfjwejfhmehjv  iuweku  orkeqjewru oewihi',
                            //                       "Product Name : ${data.prdouctName}",
                            //                       style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 15.sp,
                            //                       ),
                            //                     ),
                            //                     Text(
                            //                       "Price: ${data.cost.toStringAsFixed(2) ?? 0}",
                            //                       style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 15.sp,
                            //                       ),
                            //                     ),
                            //                     Text(
                            //                       "Quantity : ${data.quantity.toStringAsFixed(2)}",
                            //                       style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 15.sp,
                            //                       ),
                            //                     ),
                            //                     if (filterModeselection ==
                            //                         'D') ...[
                            //                       Text(
                            //                         "DiscMode : ${data.discMode}",
                            //                         style: TextStyle(
                            //                           fontWeight:
                            //                               FontWeight.w400,
                            //                           fontSize: 5.sp,
                            //                         ),
                            //                       ),
                            //                       // Show percentage if mode is percentage
                            //                       if (data.discMode ==
                            //                           "Percentage")
                            //                         Text(
                            //                           "DiscPercentage : ${data.discPerc.toStringAsFixed(2)}%",
                            //                           style: TextStyle(
                            //                             fontWeight:
                            //                                 FontWeight.w400,
                            //                             fontSize: 15.sp,
                            //                           ),
                            //                         ),
                            //                       // Show amount if mode is amount
                            //                       if (data.discMode ==
                            //                           "Amount")
                            //                         Text(
                            //                           "DiscAmount : ${data.discAmount.toStringAsFixed(3)}",
                            //                           style: TextStyle(
                            //                             fontWeight:
                            //                                 FontWeight.w400,
                            //                             fontSize: 15.sp,
                            //                           ),
                            //                         ),
                            //                     ],
                            //                     Text(
                            //                       "Expiry Date : ${data.expiryDate}",
                            //                       style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 15.sp,
                            //                       ),
                            //                     ),
                            //                     Text(
                            //                       "Note : ${data.note.isNotEmpty ? data.note : "N/A"}",
                            //                       style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 15.sp,
                            //                       ),
                            //                     ),
                            //                     Text(
                            //                       "Reason : ${data.reason.isNotEmpty ? data.reason : "N/A"}",
                            //                       style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 15.sp,
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //           Positioned(
                            //             top: 0,
                            //             right: 0,
                            //             child: Container(
                            //               padding:
                            //                   const EdgeInsets.symmetric(
                            //                       horizontal: 8,
                            //                       vertical: 4),
                            //               decoration: const BoxDecoration(
                            //                 color: Colors.blueAccent,
                            //                 borderRadius: BorderRadius.only(
                            //                   topRight: Radius.circular(8),
                            //                   bottomLeft:
                            //                       Radius.circular(8),
                            //                 ),
                            //               ),
                            //               child: Text(
                            //                 data.reqStatus ??
                            //                     '', // Dynamic status display
                            //                 style: const TextStyle(
                            //                   color: Colors.white,
                            //                   fontSize: 10,
                            //                   fontWeight: FontWeight.bold,
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       );
                            //     },
                            //   );
                          }
                        }))
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatSalesmanDate(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return 'N/A';
    try {
      DateTime parsedDate = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF1a237e); // Dark Blue
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// -------->>>>>>>>>>>>>>>.--------hcgcgxgcx

// -------->>>>

              // Positioned(
                                          //   right: 5,
                                          //   top: 5,
                                          //   child: CornerBanner(
                                          //     bannerPosition:
                                          //         CornerBannerPosition.topRight,
                                          //     bannerColor:
                                          //         Colors.black.withOpacity(0.8),
                                          //     child: Text(
                                          //       data.reqStatus,
                                          //       style: TextStyle(
                                          //         color: Colors.white,
                                          //         fontSize: 5.sp,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // )
                                            // : ListView.builder(
                            //     itemCount:
                            //         reportDetailsListModel.data.length ?? 0,
                            //     itemBuilder: (context, index) {
                            //       Datum data =
                            //           reportDetailsListModel.data[index];
                            //       return Stack(
                            //         children: [
                            //           Card(
                            //             elevation: 4,
                            //             child: ListTile(
                            //               title: Column(
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 children: [
                            //                   Text(
                            //                     "ItemCode : ${data.prdouctId}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 5.sp),
                            //                   ),
                            //                   Text(
                            //                     "Product Name : ${data.prdouctName}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 5.sp),
                            //                   ),
                            //                   Text(
                            //                     "Quantity : ${data.quantity.toStringAsFixed(2)}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 5.sp),
                            //                   ),
                            //                   if (filterModeselection ==
                            //                       'D') ...[
                            //                     Text(
                            //                       "DiscMode : ${data.discMode}",
                            //                       style: TextStyle(
                            //                           fontWeight:
                            //                               FontWeight.w400,
                            //                           fontSize: 5.sp),
                            //                     ),
                            //                     // Show percentage if mode is percentage
                            //                     if (data.discMode ==
                            //                         "Percentage")
                            //                       Text(
                            //                         "DiscPercentage : ${data.discPerc.toStringAsFixed(2)}%",
                            //                         style: TextStyle(
                            //                           fontWeight:
                            //                               FontWeight.w400,
                            //                           fontSize: 5.sp,
                            //                         ),
                            //                       ),
                            //                     // Show amount if mode is amount
                            //                     if (data.discMode ==
                            //                         "Amount")
                            //                       Text(
                            //                         "DiscAmount : ${data.discAmount.toStringAsFixed(3)}",
                            //                         style: TextStyle(
                            //                           fontWeight:
                            //                               FontWeight.w400,
                            //                           fontSize: 5.sp,
                            //                         ),
                            //                       ),
                            //                   ],

                            //                   // // Show percentage if mode is percentage
                            //                   // if (data.discMode ==
                            //                   //     "Percentage")
                            //                   //   Text(
                            //                   //     "DiscPercentage : ${data.discPerc.toStringAsFixed(2)}%",
                            //                   //     style: TextStyle(
                            //                   //       fontWeight:
                            //                   //           FontWeight.w400,
                            //                   //       fontSize: 5.sp,
                            //                   //     ),
                            //                   //   ),
                            //                   // // Show amount if mode is amount
                            //                   // if (data.discMode == "Amount")
                            //                   //   Text(
                            //                   //     "DiscAmount : ${data.discAmount.toStringAsFixed(3)}",
                            //                   //     style: TextStyle(
                            //                   //       fontWeight:
                            //                   //           FontWeight.w400,
                            //                   //       fontSize: 5.sp,
                            //                   //     ),
                            //                   //   ),
                            //                   Text(
                            //                     "Expiry Date : ${data.expiryDate}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 5.sp),
                            //                   ),
                            //                   Text(
                            //                     "Note : ${data.note.isNotEmpty ? data.note : "N/A"}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 5.sp),
                            //                   ),
                            //                   Text(
                            //                     "Reason : ${data.reason.isNotEmpty ? data.reason : "N/A"}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.w400,
                            //                         fontSize: 5.sp),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //           Positioned(
                            //             right: 5,
                            //             top: 5,
                            //             child: CornerBanner(
                            //               bannerPosition:
                            //                   CornerBannerPosition.topRight,
                            //               bannerColor:
                            //                   Colors.black.withOpacity(0.8),
                            //               child: Text(
                            //                 data.reqStatus,
                            //                 style: TextStyle(
                            //                     color: Colors.white,
                            //                     fontSize: 5.sp),
                            //               ),
                            //             ),
                            //           )
                            //         ],
                            //       );
                            //     });