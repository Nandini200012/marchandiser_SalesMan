import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marchandise/provider/create_request_vendor_detals.dart';
import 'package:marchandise/screens/model/Vendors.dart';
import 'package:marchandise/screens/salesman_screens/model/merchendiser_api_service.dart';
import 'package:marchandise/screens/marchandiser_screens/marchendiser_bottomnav.dart';
import 'package:marchandise/screens/marchandiser_screens/select_salesman_screen.dart';
import 'package:marchandise/screens/model/vendor_and_salesperson_model.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/willpop.dart';
import 'package:provider/provider.dart';

class VendorDetails {
  final int code;
  final String name;
  final String vendorCode;
  final String mobileNo;

  VendorDetails(
      {required this.code,
      required this.name,
      required this.vendorCode,
      required this.mobileNo});
}

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

final MerchendiserApiService apiService = MerchendiserApiService();
List<Vendors> vendorList = [];
late Future<VendorAndSalesPersonModel> vendorData;
late Willpop willpop;
TextEditingController searchController = TextEditingController();
IconData _currentIcon = Icons.search;

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final MerchendiserApiService apiService = MerchendiserApiService();
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    willpop = Willpop(context);
    fetchVendors();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchVendors({String query = '', int page = 1}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newVendors = await apiService.fetchVendors(
          query: query, page: page, pageSize: pageSize);
      setState(() {
        if (page == 1) {
          vendorList = newVendors;
        } else {
          vendorList.addAll(newVendors);
        }
        currentPage = page;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchVendors(query: searchController.text, page: currentPage + 1);
    }
  }

  void _onSearch() {
    setState(() {
      vendorList.clear();
      currentPage = 1;
      fetchVendors(query: searchController.text, page: 1);
    });
  }

  Future<void> _refresh() async {
    fetchVendors(query: searchController.text, page: 1);
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      currentPage = 1;
      fetchVendors(query: '', page: currentPage);
      vendorList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var vendorDetailsProvider =
        Provider.of<CreateRequestVendorDetailsProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        return willpop.onWillPop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.purple,
          leading: InkWell(
              onTap: () {
                searchController.text = "";
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const MarchendiserBottomNavigation()));
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: const Text(
            "Create Request",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
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
                  child: Text("MR"),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          searchController.text.isNotEmpty
                              ? Icons.close
                              : Icons.search,
                          color: searchController.text.isNotEmpty
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () {
                          if (searchController.text.isNotEmpty &&
                              _currentIcon == Icons.search) {
                            _onSearch();
                            _currentIcon = Icons.close;
                          } else {
                            _clearSearch();
                            _currentIcon = Icons.search;
                          }
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: vendorList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == vendorList.length) {
                          return isLoading
                              ? Center(child: CircularProgressIndicator())
                              : SizedBox.shrink();
                        }
                        final vendor = vendorList[index];
                        return GestureDetector(
                          onTap: () {
                            searchController.text = "";
                            vendorDetailsProvider.setVendorDetails(
                                vendor.vendorId,
                                vendor.vendorName,
                                vendor.salesPerson,
                                vendor.salesPersonName);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SelectSalesmanScreen()));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.purple,
                                  child: Text(
                                    vendor.vendorName.isNotEmpty
                                        ? vendor.vendorName[0]
                                        : '',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vendor.vendorName,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Customer Code: ${vendor.vendorCode}',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Mobile No: ${vendor.mobileNo}',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
