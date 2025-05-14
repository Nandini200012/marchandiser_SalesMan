import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marchandise/services/comment/export_excel/export_excel_api.dart';
import 'package:marchandise/utils/export_function.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:marchandise/model/report_list_model.dart' as model;
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
  // Constants
  static const Color primaryColor = Color(0xFFFBC02D);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xff023e8a);
  static const Color cardColor = Colors.white;
  static const Color selectedTabColor = Color(0xFFFBC02D);
  static const Color unselectedTabColor = Colors.white;

  // Services
  final ManagerApiService apiService = ManagerApiService();
  final MerchendiserApiService merchandiserapiService =
      MerchendiserApiService();
  final Faker faker = Faker();
  late Willpop willpop;

  // State variables
  DateTime _selectedFromDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _selectedToDate = DateTime.now();
  model.Data? reportListData;
  Status selectedStatus = Status.banding;

  // Filter-related variables
  List<Vendors> vendorList = [];
  List<Map<String, dynamic>> salesPersonList = [];
  String? selectedVendor;
  int? selectedVendorID;
  String? selectedSalesPerson;
  int? selectedSalesPersonID;
  TextEditingController vendorController = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();

  // Pagination and loading
  bool isLoading = false; // For vendor loading
  bool isSalesPersonLoading = false; // For salesperson loading
  int currentPage = 1;
  final int pageSize = 20;

  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData("B");
      fetchVendors();
      fetchSalesPersonList();
    });
  }

  // API Methods
  Future<void> fetchData(String filterMode) async {
    try {
      final reportList = await apiService.getReportList(
        fromDate: _selectedFromDate.toString(),
        toDate: _selectedToDate.toString(),
        reportListMode: "SM",
        filterMode: filterMode,
        pageNo: 1,
        vendorId: selectedVendorID,
        salesPersonId: selectedSalesPersonID,
      );

      setState(() {
        reportListData = reportList.data;
      });
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchSalesPersonList() async {
    setState(() {
      isSalesPersonLoading = true;
    });
    try {
      var response = await http.get(Uri.parse(Urls.getSalesPersons));
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
            salesPersonList = mappedList;
            isSalesPersonLoading = false;
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
      setState(() {
        isSalesPersonLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading salespersons: $e')),
      );
      return [];
    }
  }

  Future<void> fetchVendors({String query = '', int page = 1}) async {
    try {
      setState(() {
        isLoading = true;
      });
      final newVendors = await merchandiserapiService.fetchVendors(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            if (page == 1) {
              vendorList = newVendors;
            } else {
              vendorList.addAll(newVendors);
            }
            currentPage = page;
            isLoading = false;
          });
        }
      });
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading vendors: $error')),
          );
        }
      });
    }
  }

  // UI Helper Methods
  String getFilterModeFromStatus(Status status) {
    switch (status) {
      case Status.banding:
        return "B";
      case Status.discount:
        return "D";
      case Status.returning:
        return "R";
      default:
        return "B";
    }
  }

  String getStatusValue(Status status) {
    if (reportListData == null || reportListData!.cards.isEmpty) return "0";

    switch (status) {
      case Status.banding:
        return reportListData!.cards[0].bandig.toString();
      case Status.discount:
        return reportListData!.cards[0].discount.toString();
      case Status.returning:
        return reportListData!.cards[0].cardReturn.toString();
      default:
        return "0";
    }
  }

  Future<void> _exportToExcel() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading export data...')),
    );

    try {
      final data = await fetchExportData(
        fromDate: DateFormat('yyyy-MM-dd').format(_selectedFromDate),
        toDate: DateFormat('yyyy-MM-dd').format(_selectedToDate),
      );

      if (data != null && data.isSuccess) {
        log('excel export data:${data.data.first}');
        final filePath = await exportToExcel(data);

        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported ${data.data.length} records to Excel!'),
              duration: const Duration(seconds: 3),
            ),
          );

          if (kIsWeb) {
            final blob = html.Blob([File(filePath).readAsBytesSync()]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..target = 'blank'
              ..setAttribute('download', 'exported_data.xlsx')
              ..click();
            html.Url.revokeObjectUrl(url);
            html.window.open(url, '_blank');
          } else {
            final result = await OpenFile.open(filePath);
            if (result.type != ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to open the file.')),
              );
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to fetch export data. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _selectedFromDate : _selectedToDate,
      firstDate: DateTime.now().subtract(const Duration(days: 2 * 365)),
      lastDate: isFromDate
          ? DateTime.now()
          : DateTime(DateTime.now().year + 10, DateTime.now().month,
              DateTime.now().day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _selectedFromDate = picked;
        } else {
          _selectedToDate = picked;
        }
        fetchData(getFilterModeFromStatus(selectedStatus));
      });
    }
    return picked;
  }

  // Widget Build Methods
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFF9C4),
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
          padding: const EdgeInsets.only(right: 15),
          child: GestureDetector(
            onTap: () {
              DynamicAlertBox().logOut(context, "Do you Want to Logout", () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SplashScreen()));
              });
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor,
              child: Text("SM", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(bool isFromDate) {
    final date = isFromDate ? _selectedFromDate : _selectedToDate;
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context, isFromDate),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${isFromDate ? "From" : "To"}: ${DateFormat('dd/MM/yyyy').format(date)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.calendar_today,
                color: Colors.black54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorDropdown() {
    return Expanded(
      child: Stack(
        children: [
          TypeAheadFormField<Vendors>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: vendorController,
              decoration: InputDecoration(
                labelText: 'Select Customer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: vendorController.text.isEmpty
                    ? const Icon(Icons.search, size: 20)
                    : IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () async {
                          await _clearVendorData();
                        },
                      ),
              ),
              onChanged: (value) {
                fetchVendors(query: value, page: 1);
              },
            ),
            suggestionsCallback: (pattern) async {
              return vendorList
                  .where((vendor) =>
                      vendor.vendorName
                          .toLowerCase()
                          .contains(pattern.toLowerCase()) ||
                      vendor.vendorCode
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, Vendors suggestion) {
              return ListTile(
                title: Text(suggestion.vendorName),
                subtitle: Text(suggestion.vendorCode),
              );
            },
            onSuggestionSelected: (Vendors suggestion) async {
              await _selectVendor(suggestion);
            },
            noItemsFoundBuilder: (context) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No Vendor found'),
            ),
            debounceDuration: Duration(milliseconds: 300),
          ),
          if (isLoading)
            Positioned(
              right: 10,
              top: 15,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _clearVendorData() async {
    setState(() {
      selectedVendor = null;
      selectedVendorID = null;
      vendorController.clear();
      fetchData(getFilterModeFromStatus(selectedStatus));
    });
  }

  Future<void> _selectVendor(Vendors suggestion) async {
    setState(() {
      selectedVendor = suggestion.vendorName;
      selectedVendorID = suggestion.vendorId;
      vendorController.text = suggestion.vendorName;
      fetchData(getFilterModeFromStatus(selectedStatus));
    });
  }

  Widget _buildSalesPersonDropdown() {
    return Expanded(
      child: Stack(
        children: [
          TypeAheadFormField<Map<String, dynamic>>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: salesPersonController,
              decoration: InputDecoration(
                labelText: 'Select Salesperson',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: salesPersonController.text.isEmpty
                    ? const Icon(Icons.search, size: 20)
                    : IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            salesPersonController.clear();
                            selectedSalesPerson = null;
                            selectedSalesPersonID = null;
                            fetchData(getFilterModeFromStatus(selectedStatus));
                          });
                        },
                      ),
              ),
            ),
            suggestionsCallback: (pattern) {
              return salesPersonList.where((salesPerson) =>
                  salesPerson['salesPersonName']
                      .toLowerCase()
                      .contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, Map<String, dynamic> suggestion) {
              return ListTile(
                title: Text(suggestion['salesPersonName']),
              );
            },
            onSuggestionSelected: (Map<String, dynamic> suggestion) {
              setState(() {
                selectedSalesPerson = suggestion['salesPersonName'];
                selectedSalesPersonID = suggestion['salesPersonID'];
                salesPersonController.text = suggestion['salesPersonName'];
                fetchData(getFilterModeFromStatus(selectedStatus));
              });
            },
            noItemsFoundBuilder: (context) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No Salesperson found'),
            ),
            debounceDuration: Duration(milliseconds: 300),
          ),
          if (isSalesPersonLoading)
            Positioned(
              right: 10,
              top: 15,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(Status status, String title, String filterMode) {
    final isSelected = selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = status;
            fetchData(filterMode);
          });
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1,
            ),
          ),
          color: isSelected ? primaryColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getStatusValue(status),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "Req No",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "Date",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              "Name",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
      int index, model.Detail detailData, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SalesManReportDetailsScreen(
              requestId: detailData.requestId,
              selectedStatus: selectedStatus,
              CustomerName: detailData.vendorName,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Req ID: ${detailData.requestId}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Date: ${detailData.date}",
                style: const TextStyle(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
              // const Sized Edison: 8px;
              const SizedBox(height: 8),
              Text(
                "Customer: ${detailData.vendorName}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.chevron_right, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Row(
          children: [
            _buildDateSelector(true),
            const SizedBox(width: 12),
            _buildDateSelector(false),
            const SizedBox(width: 12),
            _buildVendorDropdown(),
            const SizedBox(width: 12),
            _buildSalesPersonDropdown(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatusTab(Status.banding, "Banding", "B"),
            const SizedBox(width: 12),
            _buildStatusTab(Status.discount, "Discount", "D"),
            const SizedBox(width: 12),
            _buildStatusTab(Status.returning, "Return", "R"),
          ],
        ),
        const SizedBox(height: 16),
        _buildListHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: reportListData == null
              ? const Center(child: CircularProgressIndicator())
              : reportListData!.details.isEmpty
                  ? const Center(child: Text("No Data Available"))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        itemCount: reportListData!.details.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.3,
                        ),
                        itemBuilder: (context, index) {
                          return _buildGridItem(
                              index, reportListData!.details[index], context);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => willpop.onWillPop(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Container(
          width: double.infinity,
          color: backgroundColor,
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }
}

enum Status { banding, discount, returning }

// ---->>>...old
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:faker/faker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:marchandise/services/comment/export_excel/export_excel_api.dart';
// import 'package:marchandise/utils/export_function.dart';
// import 'package:open_file/open_file.dart';
// import 'package:universal_html/html.dart' as html;
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:intl/intl.dart';
// import 'package:marchandise/model/report_list_model.dart' as model;
// import 'package:marchandise/screens/manager_screens/api_service/manager_api_service.dart';
// import 'package:marchandise/screens/model/Vendors.dart';
// import 'package:marchandise/screens/salesman_screens/model/merchendiser_api_service.dart';
// import 'package:marchandise/screens/salesman_screens/salesman_report_details_screen.dart';
// import 'package:marchandise/screens/splash_screen.dart';
// import 'package:marchandise/utils/dynamic_alert_box.dart';
// import 'package:marchandise/utils/urls.dart';
// import 'package:marchandise/utils/willpop.dart';
// import 'package:http/http.dart' as http;

// class SalesmanDashboardScreen extends StatefulWidget {
//   const SalesmanDashboardScreen({super.key});

//   @override
//   State<SalesmanDashboardScreen> createState() =>
//       _SalesmanDashboardScreenState();
// }

// class _SalesmanDashboardScreenState extends State<SalesmanDashboardScreen> {
//   // Constants
//   static const Color primaryColor = Color(0xFFFBC02D);
//   static const Color backgroundColor = Colors.white;
//   static const Color textColor = Color(0xff023e8a);
//   static const Color cardColor = Colors.white;
//   static const Color selectedTabColor = Color(0xFFFBC02D);
//   static const Color unselectedTabColor = Colors.white;

//   // Services
//   final ManagerApiService apiService = ManagerApiService();
//   final MerchendiserApiService merchandiserapiService =
//       MerchendiserApiService();
//   final Faker faker = Faker();
//   late Willpop willpop;

//   // State variables
//   DateTime _selectedFromDate = DateTime.now().subtract(const Duration(days: 6));
//   DateTime _selectedToDate = DateTime.now();
//   model.Data? reportListData;
//   Status selectedStatus = Status.banding;

//   // Filter-related variables
//   List<Vendors> vendorList = [];
//   List<Map<String, dynamic>> salesPersonList = [];
//   String? selectedVendor;
//   int? selectedVendorID;
//   String? selectedSalesPerson;
//   int? selectedSalesPersonID;
//   TextEditingController vendorController = TextEditingController();
//   TextEditingController salesPersonController = TextEditingController();

//   // Pagination and loading
//   bool isLoading = false;
//   int currentPage = 1;
//   final int pageSize = 20;

//   @override
//   void initState() {
//     super.initState();
//     willpop = Willpop(context);
//     fetchData("B");
//     fetchVendors();
//     fetchSalesPersonList();
//   }

//   // API Methods
//   Future<void> fetchData(String filterMode) async {
//     try {
//       final reportList = await apiService.getReportList(
//         fromDate: _selectedFromDate.toString(),
//         toDate: _selectedToDate.toString(),
//         reportListMode: "SM",
//         filterMode: filterMode,
//         pageNo: 1,
//         vendorId: selectedVendorID,
//         salesPersonId: selectedSalesPersonID,
//       );

//       setState(() {
//         reportListData = reportList.data;
//       });
//     } catch (e) {
//       print("Error fetching data: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching data: $e')),
//       );
//     }
//   }

//   Future<List<Map<String, dynamic>>> fetchSalesPersonList() async {
//     try {
//       var response = await http.get(Uri.parse(Urls.getSalesPersons));
//       if (response.statusCode == 200) {
//         log('salesperson: ${response.body}');
//         var decodedResponse = jsonDecode(response.body);
//         if (decodedResponse['isSuccess']) {
//           List<dynamic> salesPersonsData =
//               decodedResponse['data']['salesPersons'];
//           final mappedList = salesPersonsData
//               .map<Map<String, dynamic>>((e) => {
//                     "salesPersonID": e['salesPerson'],
//                     "salesPersonName": e['salesPersonName']
//                   })
//               .toList();
//           setState(() {
//             salesPersonList = mappedList;
//           });
//           return mappedList;
//         } else {
//           throw Exception('API call was not successful');
//         }
//       } else {
//         throw Exception('Failed to load salespersons');
//       }
//     } catch (e) {
//       print("Error fetching salespersons: $e");
//       return [];
//     }
//   }

//   Future<void> fetchVendors({String query = '', int page = 1}) async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       final newVendors = await merchandiserapiService.fetchVendors(
//         query: query,
//         page: page,
//         pageSize: pageSize,
//       );

//       setState(() {
//         if (page == 1) {
//           vendorList = newVendors;
//         } else {
//           vendorList.addAll(newVendors);
//         }
//         currentPage = page;
//       });
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading vendors: $error')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // UI Helper Methods
//   String getFilterModeFromStatus(Status status) {
//     switch (status) {
//       case Status.banding:
//         return "B";
//       case Status.discount:
//         return "D";
//       case Status.returning:
//         return "R";
//       default:
//         return "B";
//     }
//   }

//   String getStatusValue(Status status) {
//     if (reportListData == null || reportListData!.cards.isEmpty) return "0";

//     switch (status) {
//       case Status.banding:
//         return reportListData!.cards[0].bandig.toString();
//       case Status.discount:
//         return reportListData!.cards[0].discount.toString();
//       case Status.returning:
//         return reportListData!.cards[0].cardReturn.toString();
//       default:
//         return "0";
//     }
//   }

//   Future<void> _exportToExcel() async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Downloading export data...')),
//     );

//     try {
//       final data = await fetchExportData(
//         fromDate: DateFormat('yyyy-MM-dd').format(_selectedFromDate),
//         toDate: DateFormat('yyyy-MM-dd').format(_selectedToDate),
//       );

//       if (data != null && data.isSuccess) {
//         log('excel export data:${data.data.first}');
//         final filePath = await exportToExcel(data);

//         if (filePath != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Exported ${data.data.length} records to Excel!'),
//               duration: const Duration(seconds: 3),
//             ),
//           );

//           if (kIsWeb) {
//             final blob = html.Blob([File(filePath).readAsBytesSync()]);
//             final url = html.Url.createObjectUrlFromBlob(blob);
//             final anchor = html.AnchorElement(href: url)
//               ..target = 'blank'
//               ..setAttribute('download', 'exported_data.xlsx')
//               ..click();
//             html.Url.revokeObjectUrl(url);
//             html.window.open(url, '_blank');
//           } else {
//             final result = await OpenFile.open(filePath);
//             if (result.type != ResultType.done) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Failed to open the file.')),
//               );
//             }
//           }
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Failed to fetch export data. Please try again.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred: $e')),
//       );
//     }
//   }

//   Future<DateTime?> _selectDate(BuildContext context, bool isFromDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isFromDate ? _selectedFromDate : _selectedToDate,
//       firstDate: DateTime.now().subtract(const Duration(days: 2 * 365)),
//       lastDate: isFromDate
//           ? DateTime.now()
//           : DateTime(DateTime.now().year + 10, DateTime.now().month,
//               DateTime.now().day),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: primaryColor,
//               onPrimary: Colors.white,
//               onSurface: textColor,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         if (isFromDate) {
//           _selectedFromDate = picked;
//         } else {
//           _selectedToDate = picked;
//         }
//         fetchData(getFilterModeFromStatus(selectedStatus));
//       });
//     }
//     return picked;
//   }

//   // Widget Build Methods
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: const Color(0xFFFFF9C4),
//       automaticallyImplyLeading: false,
//       elevation: 0,
//       title: const Text(
//         "Reports",
//         style: TextStyle(
//           fontWeight: FontWeight.w700,
//           color: Colors.black,
//         ),
//       ),
//       centerTitle: true,
//       actions: [
//         // IconButton(
//         //   onPressed: _exportToExcel,
//         //   icon: Image.asset('assets/excel_icon.png'),
//         //   tooltip: 'Export to Excel',
//         // ),
//         Padding(
//           padding: const EdgeInsets.only(right: 15),
//           child: GestureDetector(
//             onTap: () {
//               DynamicAlertBox().logOut(context, "Do you Want to Logout", () {
//                 Navigator.of(context).pushReplacement(MaterialPageRoute(
//                     builder: (context) => const SplashScreen()));
//               });
//             },
//             child: const CircleAvatar(
//               radius: 22,
//               backgroundColor: primaryColor,
//               child: Text("SM", style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateSelector(bool isFromDate) {
//     final date = isFromDate ? _selectedFromDate : _selectedToDate;
//     return Expanded(
//       child: InkWell(
//         onTap: () => _selectDate(context, isFromDate),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(10),
//             color: Colors.white,
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "${isFromDate ? "From" : "To"}: ${DateFormat('dd/MM/yyyy').format(date)}",
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Icon(
//                 Icons.calendar_today,
//                 color: Colors.black54,
//                 size: 20,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVendorDropdown() {
//     return Expanded(
//       child: TypeAheadFormField<Vendors>(
//         textFieldConfiguration: TextFieldConfiguration(
//           controller: vendorController,
//           decoration: InputDecoration(
//             labelText: 'Select Customer',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             suffixIcon: vendorController.text.isEmpty
//                 ? const Icon(Icons.search, size: 20)
//                 : IconButton(
//                     icon: const Icon(Icons.close, size: 20),
//                     onPressed: () async {
//                       // Perform async operation before calling setState
//                       await _clearVendorData();
//                     },
//                   ),
//           ),
//         ),
//         suggestionsCallback: (pattern) {
//           // Fetch vendors asynchronously
//           fetchVendors(query: pattern, page: 1);
//           return vendorList;
//         },
//         itemBuilder: (context, Vendors suggestion) {
//           return ListTile(
//             title: Text(suggestion.vendorName),
//             subtitle: Text(suggestion.vendorCode),
//           );
//         },
//         onSuggestionSelected: (Vendors suggestion) async {
//           // Wait for async operations to complete before calling setState
//           await _selectVendor(suggestion);
//         },
//         noItemsFoundBuilder: (context) => const Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text('No Vendor found'),
//         ),
//       ),
//     );
//   }

//   Future<void> _clearVendorData() async {
//     // Wait for any async operations to complete
//     await Future.delayed(
//         const Duration(milliseconds: 100)); // Simulate async operation

//     // Only call setState after async operation is complete
//     setState(() {
//       selectedVendor = null;
//       selectedVendorID = null;
//       vendorController.clear();
//       fetchData(getFilterModeFromStatus(selectedStatus));
//     });
//   }

//   Future<void> _selectVendor(Vendors suggestion) async {
//     // Wait for any async operations to complete
//     await Future.delayed(
//         Duration(milliseconds: 100)); // Simulate async operation

//     // Only call setState after async operation is complete
//     setState(() {
//       selectedVendor = suggestion.vendorName;
//       selectedVendorID = suggestion.vendorId;
//       vendorController.text = suggestion.vendorName;
//       fetchData(getFilterModeFromStatus(selectedStatus));
//     });
//   }

//   // Widget _buildVendorDropdown() {
//   //   return Expanded(
//   //     child: TypeAheadFormField<Vendors>(
//   //       textFieldConfiguration: TextFieldConfiguration(
//   //         controller: vendorController,
//   //         decoration: InputDecoration(
//   //           labelText: 'Select Customer',
//   //           border: OutlineInputBorder(
//   //             borderRadius: BorderRadius.circular(10),
//   //             borderSide: BorderSide(color: Colors.grey.shade300),
//   //           ),
//   //           enabledBorder: OutlineInputBorder(
//   //             borderRadius: BorderRadius.circular(10),
//   //             borderSide: BorderSide(color: Colors.grey.shade300),
//   //           ),
//   //           filled: true,
//   //           fillColor: Colors.white,
//   //           suffixIcon: vendorController.text.isEmpty
//   //               ? const Icon(Icons.search, size: 20)
//   //               : IconButton(
//   //                   icon: const Icon(Icons.close, size: 20),
//   //                   onPressed: () {
//   //                     setState(() {
//   //                       selectedVendor = null;
//   //                       selectedVendorID = null;
//   //                       vendorController.clear();
//   //                       fetchData(getFilterModeFromStatus(selectedStatus));
//   //                     });
//   //                   },
//   //                 ),
//   //         ),
//   //       ),
//   //       suggestionsCallback: (pattern) {
//   //         fetchVendors(query: pattern, page: 1);
//   //         return vendorList;
//   //       },
//   //       itemBuilder: (context, Vendors suggestion) {
//   //         return ListTile(
//   //           title: Text(suggestion.vendorName),
//   //           subtitle: Text(suggestion.vendorCode),
//   //         );
//   //       },
//   //       onSuggestionSelected: (Vendors suggestion) {
//   //         setState(() {
//   //           selectedVendor = suggestion.vendorName;
//   //           selectedVendorID = suggestion.vendorId;
//   //           vendorController.text = suggestion.vendorName;
//   //           fetchData(getFilterModeFromStatus(selectedStatus));
//   //         });
//   //       },
//   //       noItemsFoundBuilder: (context) => const Padding(
//   //         padding: EdgeInsets.all(8.0),
//   //         child: Text('No Vendor found'),
//   //       ),
//   //     ),
//   //   );
//   // }

//   Widget _buildSalesPersonDropdown() {
//     return Expanded(
//       child: TypeAheadFormField<Map<String, dynamic>>(
//         textFieldConfiguration: TextFieldConfiguration(
//           controller: salesPersonController,
//           decoration: InputDecoration(
//             labelText: 'Select Salesperson',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             suffixIcon: salesPersonController.text.isEmpty
//                 ? const Icon(Icons.search, size: 20)
//                 : IconButton(
//                     icon: const Icon(Icons.close, size: 20),
//                     onPressed: () {
//                       setState(() {
//                         salesPersonController.clear();
//                         selectedSalesPerson = null;
//                         selectedSalesPersonID = null;
//                       });
//                     },
//                   ),
//           ),
//         ),
//         suggestionsCallback: (pattern) {
//           return salesPersonList.where((salesPerson) =>
//               salesPerson['salesPersonName']
//                   .toLowerCase()
//                   .contains(pattern.toLowerCase()));
//         },
//         itemBuilder: (context, Map<String, dynamic> suggestion) {
//           return ListTile(
//             title: Text(suggestion['salesPersonName']),
//           );
//         },
//         onSuggestionSelected: (Map<String, dynamic> suggestion) {
//           setState(() {
//             selectedSalesPerson = suggestion['salesPersonName'];
//             selectedSalesPersonID = suggestion['salesPersonID'];
//             salesPersonController.text = suggestion['salesPersonName'];
//           });
//         },
//         noItemsFoundBuilder: (context) => const Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text('No Salesperson found'),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusTab(Status status, String title, String filterMode) {
//     final isSelected = selectedStatus == status;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedStatus = status;
//             fetchData(filterMode);
//           });
//         },
//         child: Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: BorderSide(
//               color: isSelected ? primaryColor : Colors.grey.shade300,
//               width: 1,
//             ),
//           ),
//           color: isSelected ? primaryColor : cardColor,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: isSelected ? Colors.white : textColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   getStatusValue(status),
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: isSelected ? Colors.white : primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildListHeader() {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: primaryColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: EdgeInsets.only(left: 16),
//               child: Text(
//                 "Req No",
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               "Date",
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(
//               "Name",
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // grid
//   Widget _buildGridItem(
//       int index, model.Detail detailData, BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => SalesManReportDetailsScreen(
//               requestId: detailData.requestId,
//               selectedStatus: selectedStatus,
//               CustomerName: detailData.vendorName,
//             ),
//           ),
//         );
//       },
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//           side: BorderSide(color: Colors.grey.shade200, width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "ID: ${detailData.requestId}",
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Date: ${detailData.date}",
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Customer: ${detailData.vendorName}",
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: textColor,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 2,
//               ),
//               const Spacer(),
//               Align(
//                 alignment: Alignment.bottomRight,
//                 child: Icon(Icons.chevron_right, color: textColor),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// // list
//   // Widget _buildListItem(int index, model.Detail detailData) {
//   //   return Card(
//   //     elevation: 2,
//   //     margin: const EdgeInsets.symmetric(vertical: 4),
//   //     shape: RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.circular(8),
//   //       side: BorderSide(color: Colors.grey.shade200, width: 1),
//   //     ),
//   //     child: ListTile(
//   //       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//   //       onTap: () {
//   //         Navigator.of(context).push(
//   //           MaterialPageRoute(
//   //             builder: (context) => SalesManReportDetailsScreen(
//   //               requestId: detailData.requestId,
//   //               selectedStatus: selectedStatus,
//   //               CustomerName: detailData.vendorName,
//   //             ),
//   //           ),
//   //         );
//   //       },
//   //       leading: SizedBox(
//   //         width: 80,
//   //         child: Text(
//   //           detailData.requestId.toString(),
//   //           style: const TextStyle(
//   //             fontSize: 14,
//   //             fontWeight: FontWeight.w600,
//   //             color: textColor,
//   //           ),
//   //         ),
//   //       ),
//   //       title: Row(
//   //         children: [
//   //           SizedBox(
//   //             width: 120,
//   //             child: Text(
//   //               detailData.date,
//   //               style: const TextStyle(
//   //                 fontSize: 14,
//   //                 fontWeight: FontWeight.w600,
//   //                 color: textColor,
//   //               ),
//   //             ),
//   //           ),
//   //           const SizedBox(width: 16),
//   //           Expanded(
//   //             child: Text(
//   //               detailData.vendorName,
//   //               style: const TextStyle(
//   //                 fontSize: 14,
//   //                 fontWeight: FontWeight.w600,
//   //                 color: textColor,
//   //               ),
//   //               overflow: TextOverflow.ellipsis,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //       trailing: const Icon(Icons.chevron_right, color: textColor),
//   //     ),
//   //   );
//   // }

//   Widget _buildContent() {
//     return Column(
//       children: [
//         // Date and Filter Row
//         Row(
//           children: [
//             _buildDateSelector(true),
//             const SizedBox(width: 12),
//             _buildDateSelector(false),
//             const SizedBox(width: 12),
//             _buildVendorDropdown(),
//             const SizedBox(width: 12),
//             _buildSalesPersonDropdown(),
//           ],
//         ),
//         const SizedBox(height: 16),

//         // Status Tabs
//         Row(
//           children: [
//             _buildStatusTab(Status.banding, "Banding", "B"),
//             const SizedBox(width: 12),
//             _buildStatusTab(Status.discount, "Discount", "D"),
//             const SizedBox(width: 12),
//             _buildStatusTab(Status.returning, "Return", "R"),
//           ],
//         ),
//         const SizedBox(height: 16),

//         // List Header
//         _buildListHeader(),
//         const SizedBox(height: 8),
// // grid
//         Expanded(
//           child: reportListData == null
//               ? const Center(child: CircularProgressIndicator())
//               : reportListData!.details.isEmpty
//                   ? const Center(child: Text("No Data Available"))
//                   : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: GridView.builder(
//                         itemCount: reportListData!.details.length,
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 4, // 2 cards per row
//                           crossAxisSpacing: 8,
//                           mainAxisSpacing: 8,
//                           childAspectRatio: 2.3, // adjust based on your content
//                         ),
//                         itemBuilder: (context, index) {
//                           return _buildGridItem(
//                               index, reportListData!.details[index], context);
//                         },
//                       ),
//                     ),
//         )

//         // List Content
//         // Expanded(
//         //   child: reportListData == null
//         //       ? const Center(child: CircularProgressIndicator())
//         //       : reportListData!.details.isEmpty
//         //           ? const Center(child: Text("No Data Available"))
//         //           : ListView.builder(
//         //               itemCount: reportListData!.details.length,
//         //               itemBuilder: (context, index) {
//         //                 return _buildListItem(
//         //                     index, reportListData!.details[index]);
//         //               },
//         //             ),
//         // ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => willpop.onWillPop(),
//       child: Scaffold(
//         appBar: _buildAppBar(),
//         body: Container(
//           width: double.infinity,
//           color: backgroundColor,
//           padding: const EdgeInsets.all(16),
//           child: _buildContent(),
//         ),
//       ),
//     );
//   }
// }

// enum Status { banding, discount, returning }
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:faker/faker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:marchandise/services/comment/export_excel/export_excel_api.dart';
// import 'package:marchandise/utils/export_function.dart';
// import 'package:open_file/open_file.dart';
// import 'package:universal_html/html.dart' as html;
// import 'package:flutter/material.dart' as flutterMaterial;
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:intl/intl.dart';
// import 'package:marchandise/model/report_list_model.dart';
// import 'package:marchandise/screens/manager_screens/api_service/manager_api_service.dart';
// import 'package:marchandise/screens/model/Vendors.dart';
// import 'package:marchandise/screens/salesman_screens/model/merchendiser_api_service.dart';
// import 'package:marchandise/screens/salesman_screens/salesman_report_details_screen.dart';
// import 'package:marchandise/screens/splash_screen.dart';
// import 'package:marchandise/utils/dynamic_alert_box.dart';
// import 'package:marchandise/utils/urls.dart';
// import 'package:marchandise/utils/willpop.dart';
// import 'package:http/http.dart' as http;

// class SalesmanDashboardScreen extends StatefulWidget {
//   const SalesmanDashboardScreen({super.key});

//   @override
//   State<SalesmanDashboardScreen> createState() =>
//       _SalesmanDashboardScreenState();
// }

// class _SalesmanDashboardScreenState extends State<SalesmanDashboardScreen> {
//   final ManagerApiService apiService = ManagerApiService();
//   final MerchendiserApiService merchandiserapiService =
//       MerchendiserApiService();
//   Faker faker = Faker();
//   DateTime _selectedDate = DateTime.now();
//   DateTime currentDate = DateTime.now();
//   Data? reportListData;
//   Status selectedStatus = Status.banding;
//   late Willpop willpop;
//   DateTime _selectedFromDate = DateTime.now().subtract(Duration(days: 6));
//   DateTime _selectedToDate = DateTime.now();

// // new
//   List<Vendors> vendorList = [];
//   List<Map<String, dynamic>> salesPersonList = [];
//   String? selectedVendor;
//   int? selectedVendorID;
//   String? selectedSalesPerson;
//   int? selectedSalesPersonID;
//   TextEditingController vendorController = TextEditingController();
//   TextEditingController salesPersonController = TextEditingController();

//   bool isLoading = false;
//   int currentPage = 1;
//   final int pageSize = 20;
//   @override
//   void initState() {
//     super.initState();
//     willpop = Willpop(context);

//     fetchData("B");
//     fetchVendors();
//     fetchSalesPersonList();
//   }

//   void fetchData(String filterMode) async {
//     try {
//       final reportList = await apiService.getReportList(
//         fromDate: _selectedFromDate.toString(),
//         toDate: _selectedToDate.toString(),
//         reportListMode: "SM",
//         filterMode: filterMode,
//         pageNo: 1,
//         vendorId: selectedVendorID,
//         salesPersonId: selectedSalesPersonID,
//       );

//       setState(() {
//         reportListData = reportList.data;
//       });
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }

//   Future<List<Map<String, dynamic>>> fetchSalesPersonList() async {
//     try {
//       var response = await http.get(
//         Uri.parse(Urls.getSalesPersons),
//       );
//       if (response.statusCode == 200) {
//         log('salesperson: ${response.body}');
//         var decodedResponse = jsonDecode(response.body);
//         if (decodedResponse['isSuccess']) {
//           List<dynamic> salesPersonsData =
//               decodedResponse['data']['salesPersons'];
//           final mappedList = salesPersonsData
//               .map<Map<String, dynamic>>((e) => {
//                     "salesPersonID": e['salesPerson'],
//                     "salesPersonName": e['salesPersonName']
//                   })
//               .toList();
//           setState(() {
//             salesPersonList = mappedList; // Assign the mapped list
//           });
//           return mappedList;
//         } else {
//           throw Exception('API call was not successful');
//         }
//       } else {
//         throw Exception('Failed to load salespersons');
//       }
//     } catch (e) {
//       print("Error fetching salespersons: $e");
//       return [];
//     }
//   }

//   Future<void> fetchVendors({String query = '', int page = 1}) async {
//     try {
//       final newVendors = await merchandiserapiService.fetchVendors(
//         query: query,
//         page: page,
//         pageSize: pageSize,
//       );
//       setState(() {
//         if (page == 1) {
//           vendorList = newVendors;
//         } else {
//           vendorList.addAll(newVendors);
//         }
//         currentPage = page;
//       });
//     } catch (error) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $error')));
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return willpop.onWillPop();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color(0xFFFFF9C4),
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           title: const Text(
//             "Reports",
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               color: Colors.black,
//             ),
//           ),
//           centerTitle: true,
//           actions: [
//             GestureDetector(
//               onTap: () async {
//                 // Show a loading indicator (or message) when the export process starts
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Downloading export data...')),
//                 );

//                 final data = await fetchExportData(
//                   fromDate: DateFormat('yyyy-mm-dd')
//                       .format(_selectedFromDate)
//                       .toString(),
//                   toDate: DateFormat('yyyy-mm-dd')
//                       .format(_selectedToDate)
//                       .toString(),
//                 ); // Your method returning ExportModel

//                 if (data != null && data.isSuccess) {
//                   try {
//                     log('excel export data:${data.data.first}');
//                     // Call your export function and get the file path
//                     final filePath = await exportToExcel(
//                         data); // Export function you already have

//                     if (filePath != null) {
//                       // Notify the user that the export is successful and the file is ready
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                               'Exported ${data.data.length} records to Excel!'),
//                           duration: Duration(seconds: 3),
//                         ),
//                       );

//                       if (kIsWeb) {
//                         // Web: Trigger browser download and open it in the tab
//                         final blob =
//                             html.Blob([File(filePath).readAsBytesSync()]);
//                         final url = html.Url.createObjectUrlFromBlob(blob);
//                         final anchor = html.AnchorElement(href: url)
//                           ..target = 'blank' // Opens the download in a new tab
//                           ..setAttribute('download', 'exported_data.xlsx')
//                           ..click();
//                         html.Url.revokeObjectUrl(url);

//                         // Optionally, you can open the file in a new tab directly
//                         html.window.open(url, '_blank');
//                       } else {
//                         // Mobile: Open the file after saving
//                         final result = await OpenFile.open(filePath);
//                         if (result.type != ResultType.done) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Failed to open the file.')),
//                           );
//                         }
//                       }
//                     } else {
//                       // If the file path is invalid or the file doesn't exist, show an error
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Failed to open the file.')),
//                       );
//                     }
//                   } catch (e) {
//                     // If any error occurs during export
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('An error occurred: $e')),
//                     );
//                   }
//                 } else {
//                   // If the fetch failed, show an error message
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                         content: Text(
//                             'Failed to fetch export data. Please try again.')),
//                   );
//                 }
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Image.asset(
//                   'assets/excel_icon.png',
//                 ),
//               ),
//             ),
//             // Icon(
//             //   Icons.download,
//             //   color: Colors.white,
//             //   size: 8.sp,
//             // ),
//             SizedBox(
//               width: 5.sp,
//             ),
//             Padding(
//               padding: EdgeInsets.only(right: 15),
//               child: GestureDetector(
//                 onTap: () {
//                   DynamicAlertBox().logOut(context, "Do you Want to Logout",
//                       () {
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(
//                         builder: (context) => SplashScreen()));
//                   });
//                 },
//                 child: CircleAvatar(
//                   radius: 22,
//                   child: Text("SM"),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             double screenWidth = constraints.maxWidth;
//             double fontSizeFactor = screenWidth / 1000;

//             return Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.white,
//                     Colors.white,
//                     Colors.white,
//                     Colors.white,
//                     Colors.white,
//                     Colors.white,
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: SafeArea(
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: InkWell(
//                               onTap: () =>
//                                   _selectDate(context, Status.banding, true),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.black),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 height: 50,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       "From: ${DateFormat('dd/MM/yyyy').format(_selectedFromDate)}",
//                                       style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: fontSizeFactor * 16,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     const Icon(
//                                       Icons.calendar_today,
//                                       color: Colors.black,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           Expanded(
//                             child: InkWell(
//                               onTap: () =>
//                                   _selectDate(context, Status.banding, false),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.black),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 height: 50,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       "To: ${DateFormat('dd/MM/yyyy').format(_selectedToDate)}",
//                                       style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: fontSizeFactor * 16,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     const Icon(
//                                       Icons.calendar_today,
//                                       color: Colors.black,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: ConstrainedBox(
//                               constraints: BoxConstraints(
//                                   maxWidth: 200.w, maxHeight: 255.h),
//                               child: TypeAheadFormField<Vendors>(
//                                 textFieldConfiguration: TextFieldConfiguration(
//                                   controller: vendorController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Select Customer',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     suffixIcon: vendorController.text.isEmpty
//                                         ? Icon(Icons.search)
//                                         : IconButton(
//                                             icon: Icon(Icons.close),
//                                             onPressed: () {
//                                               selectedVendor = null;
//                                               selectedVendorID = null;
//                                               vendorController.clear();

//                                               setState(() {}); // Refresh UI
//                                               fetchData(getFilterModeFromStatus(
//                                                   selectedStatus)); // 🔄 Re-fetch data without vendor filter
//                                             },
//                                           ),
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                   ),
//                                 ),
//                                 suggestionsCallback: (pattern) {
//                                   fetchVendors(query: pattern, page: 1);
//                                   return vendorList;
//                                 },
//                                 itemBuilder: (context, Vendors suggestion) {
//                                   return ListTile(
//                                     title: Text(suggestion.vendorName),
//                                     subtitle: Text(suggestion.vendorCode),
//                                   );
//                                 },
//                                 onSuggestionSelected: (Vendors suggestion) {
//                                   selectedVendor = suggestion.vendorName;
//                                   selectedVendorID = suggestion.vendorId;
//                                   vendorController.text = suggestion.vendorName;

//                                   setState(() {}); // Refresh UI
//                                   fetchData(getFilterModeFromStatus(
//                                       selectedStatus)); // ✅ Refetch data with updated filters
//                                 },
//                                 noItemsFoundBuilder: (context) => Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text('No Vendor found'),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: ConstrainedBox(
//                               constraints: BoxConstraints(
//                                 maxWidth: 500,
//                               ),
//                               child: TypeAheadFormField<Map<String, dynamic>>(
//                                 textFieldConfiguration: TextFieldConfiguration(
//                                   controller: salesPersonController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Select Salesperson',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     suffixIcon: salesPersonController
//                                             .text.isEmpty
//                                         ? Icon(Icons.search)
//                                         : IconButton(
//                                             icon: Icon(Icons.close),
//                                             onPressed: () {
//                                               setState(() {
//                                                 salesPersonController.clear();
//                                                 selectedSalesPerson = null;
//                                                 selectedSalesPersonID = null;
//                                                 // _refreshCurrentTab();
//                                               });
//                                             },
//                                           ),
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                   ),
//                                 ),
//                                 suggestionsCallback: (pattern) {
//                                   return salesPersonList.where((salesPerson) =>
//                                       salesPerson['salesPersonName']
//                                           .toLowerCase()
//                                           .contains(pattern.toLowerCase()));
//                                 },
//                                 itemBuilder:
//                                     (context, Map<String, dynamic> suggestion) {
//                                   return ListTile(
//                                     title: Text(suggestion['salesPersonName']),
//                                   );
//                                 },
//                                 onSuggestionSelected:
//                                     (Map<String, dynamic> suggestion) {
//                                   setState(() {
//                                     selectedSalesPerson =
//                                         suggestion['salesPersonName'];
//                                     selectedSalesPersonID =
//                                         suggestion['salesPersonID'];
//                                     salesPersonController.text =
//                                         suggestion['salesPersonName'];
//                                     // _refreshCurrentTab();
//                                   });
//                                 },
//                                 noItemsFoundBuilder: (context) => Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text('No Salesperson found'),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 10,
//                         width: double.infinity,
//                       ),
//                       Row(
//                         children: [
//                           buildStatusCard(
//                               Status.banding, "Banding", "B", constraints),
//                           SizedBox(width: 10),
//                           buildStatusCard(
//                               Status.discount, "Discount", "D", constraints),
//                           SizedBox(width: 10),
//                           buildStatusCard(
//                               Status.returning, "Return", "R", constraints),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 0.0),
//                         child: Container(
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: Color(0xFFFBC02D),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: ListTile(
//                             tileColor: Color(0xFFFBC02D),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               side: BorderSide(
//                                 color: Color(0xFFFBC02D),
//                                 width: 1.0,
//                               ),
//                             ),
//                             leadingAndTrailingTextStyle: TextStyle(
//                               fontSize:
//                                   constraints.maxWidth > 600 ? 5.sp : 12.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                             contentPadding: EdgeInsets.zero,
//                             dense: true,
//                             leading: Padding(
//                               padding:
//                                   const EdgeInsets.only(bottom: 10.0, left: 10),
//                               child: Text(
//                                 "Req No",
//                                 style: TextStyle(
//                                   fontSize:
//                                       constraints.maxWidth > 600 ? 5.sp : 12.sp,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             title: Container(
//                               height: 40,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         bottom: 10.0, left: 10),
//                                     child: Text(
//                                       "Date",
//                                       style: TextStyle(
//                                         fontSize: constraints.maxWidth > 600
//                                             ? 5.sp
//                                             : 12.sp,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: const SizedBox(
//                                       width: 10,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           bottom: 10.0, left: 10),
//                                       child: Text(
//                                         "Name",
//                                         style: TextStyle(
//                                           fontSize: constraints.maxWidth > 600
//                                               ? 5.sp
//                                               : 12.sp,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: const SizedBox(
//                                       width: 20,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: const SizedBox(
//                                       width: 20,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       buildListViewForStatus(Status.banding, constraints),
//                       buildListViewForStatus(Status.discount, constraints),
//                       buildListViewForStatus(Status.returning, constraints),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   String getFilterModeFromStatus(Status status) {
//     switch (status) {
//       case Status.banding:
//         return "B";
//       case Status.discount:
//         return "D";
//       case Status.returning:
//         return "R";
//       default:
//         return "B";
//     }
//   }

//   Future<DateTime?> _selectDate(
//       BuildContext context, Status status, bool isFromDate) async {
//     String filterMode;

//     switch (status) {
//       case Status.banding:
//         filterMode = "B";
//         break;
//       case Status.discount:
//         filterMode = "D";
//         break;
//       case Status.returning:
//         filterMode = "R";
//         break;
//     }
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now().subtract(Duration(days: 2 * 365)),
//       lastDate: DateTime(DateTime.now().year + 10),
//     );

//     if (picked != null &&
//         picked != (isFromDate ? _selectedFromDate : _selectedToDate)) {
//       setState(() {
//         if (isFromDate) {
//           _selectedFromDate = picked;
//         } else {
//           _selectedToDate = picked;
//         }
//         fetchData(filterMode);
//       });
//     }
//   }

//   Widget buildStatusCard(Status status, String title, String filterMode,
//       BoxConstraints constraints) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedStatus = status;
//             fetchData(filterMode);
//           });
//         },
//         child: flutterMaterial.Card(
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Color(0xFFFBC02D)),
//               color:
//                   selectedStatus == status ? Color(0xFFFBC02D) : Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 5.h),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: constraints.maxWidth > 600 ? 5.sp : 14.sp,
//                     color: selectedStatus == status
//                         ? Colors.white
//                         : Color(0xFFFBC02D),
//                   ),
//                 ),
//                 SizedBox(height: 3.h),
//                 Text(
//                   getStatusValue(status),
//                   style: TextStyle(
//                     fontSize: constraints.maxWidth > 600 ? 5.sp : 16.sp,
//                     fontWeight: FontWeight.w700,
//                     color: selectedStatus == status
//                         ? Colors.white
//                         : Color(0xFFFBC02D),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String getStatusValue(Status status) {
//     switch (status) {
//       case Status.banding:
//         return reportListData?.cards[0].bandig.toString() ?? "0";
//       case Status.discount:
//         return reportListData?.cards[0].discount.toString() ?? "0";
//       case Status.returning:
//         return reportListData?.cards[0].cardReturn.toString() ?? "0";
//       default:
//         return "0";
//     }
//   }

//   Widget buildListViewForStatus(Status status, BoxConstraints constraints) {
//     return selectedStatus == status
//         ? reportListData == null || reportListData!.details.isEmpty
//             ? const Expanded(
//                 child: Center(
//                   child: Text("No Data"),
//                 ),
//               )
//             : Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: reportListData?.details.length,
//                   itemBuilder: (context, index) {
//                     return buildListTile(
//                         index, reportListData?.details[index], constraints);
//                   },
//                 ),
//               )
//         : Container();
//   }

//   Widget buildListTile(
//       int index, Detail? detailData, BoxConstraints constraints) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(MaterialPageRoute(
//             builder: (context) => SalesManReportDetailsScreen(
//                 requestId: reportListData!.details[index].requestId,
//                 selectedStatus: selectedStatus,
//                 CustomerName: reportListData!.details[index].vendorName)));
//       },
//       child: flutterMaterial.Card(
//         color: Colors.white,
//         child: ListTile(
//           contentPadding: EdgeInsets.zero,
//           dense: true,
//           leading: Padding(
//             padding: const EdgeInsets.only(left: 10.0),
//             child: Text(
//               detailData?.requestId.toString() ?? "",
//               style: TextStyle(
//                 fontSize: constraints.maxWidth > 600 ? 5.sp : 10.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xff023e8a),
//               ),
//             ),
//           ),
//           title: Container(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(width: 10.w),
//                 Text(
//                   detailData?.date ?? "",
//                   style: TextStyle(
//                     fontSize: constraints.maxWidth > 600 ? 5.sp : 10.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xff023e8a),
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Text(
//                     detailData?.vendorName ?? "",
//                     style: TextStyle(
//                       fontSize: constraints.maxWidth > 600 ? 5.sp : 10.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xff023e8a),
//                     ),
//                     maxLines: null,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum Status { banding, discount, returning }
