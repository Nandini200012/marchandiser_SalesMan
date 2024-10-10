import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marchandise/provider/cart_provider.dart';
import 'package:marchandise/provider/product_details_provider.dart';
import 'package:marchandise/screens/marchandiser_screens/create_request_screen.dart';
import 'package:marchandise/screens/salesman_screens/model/merchendiser_api_service.dart';
import 'package:marchandise/screens/marchandiser_screens/cart_details_screen.dart';
import 'package:marchandise/screens/marchandiser_screens/cart_screen.dart';
import 'package:marchandise/screens/model/product_and_categories_model.dart';
import 'package:marchandise/screens/splash_screen.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/dynamic_alert_box.dart';
import 'package:marchandise/utils/willpop.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class ProductDetails {
  final String productName;
  final String productId;

  ProductDetails({required this.productName, required this.productId});
}

class AddProductListViewScreen extends StatefulWidget {
  final int? vendorId;
  final String? vendorName;
  final String? salesManName;
  final String? salesManId;

  const AddProductListViewScreen({
    Key? key,
    this.vendorId,
    this.vendorName,
    this.salesManName,
    this.salesManId,
  }) : super(key: key);

  @override
  State<AddProductListViewScreen> createState() =>
      _AddProductListViewScreenState();
}

class _AddProductListViewScreenState extends State<AddProductListViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<ProductAndCategoriesModel> productAndCategories;
  final MerchendiserApiService apiService = MerchendiserApiService();
  late Willpop willpop;
  List<Category> categories = [];
  List<String> selectedCategories = [];
  List<int> selectedCategoryIds = [];
  String selectedProductName = '';
  String selectedProductId = '';
  String selectedUOM = '';
  dynamic selectedUOMId = '';
  double selectedCost = 0.0;
  dynamic selectedItemID = '';

  int? infoButtonClickedIndex;

  @override
  void initState() {
    super.initState();
    willpop = Willpop(context);
    fetchInitialData();
  }

  void fetchInitialData() {
    productAndCategories = apiService.getProductAndCategories(
      flag: 100,
      pageNo: 1,
      vendorId: widget.vendorId ?? 1,
      filterText: '',
    );
    productAndCategories.then((data) {
      setState(() {
        categories = data.data.categories;
      });
    });
  }

  Future<void> showAlternativeUnits(
      BuildContext context, dynamic itemID, int index) async {
    try {
      List<dynamic> data = await apiService.fetchAlternativeUnits(itemID);
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.9, // Adjust the height as needed
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Alternative Units',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(thickness: 1.0),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      shrinkWrap: true, // Ensure ListView takes minimal space
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling in ListView
                      itemCount: data.length,
                      itemBuilder: (context, itemIndex) {
                        var item = data[itemIndex];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            title: Text(
                              item['productName'],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.0),
                                Text(
                                  'Barcode : ${item['productId']}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  'UOM : ${item['UOM']}',
                                  style: TextStyle(color: Colors.green),
                                ),
                                Text(
                                  'Price : ${item['Cost'].toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                selectedProductName = item['productName'];
                                selectedProductId = item['productId'];
                                selectedUOM = item['UOM'];
                                selectedUOMId = item['UOMId'];
                                selectedCost = item['Cost'];
                                selectedItemID = item['ItemID'];
                                infoButtonClickedIndex = index;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _refresh() async {
    productAndCategories = apiService.getProductAndCategories(
      flag: 100,
      pageNo: 1,
      vendorId: widget.vendorId ?? 1,
      filterText: '',
    );
    productAndCategories.then((data) {
      setState(() {
        categories = data.data.categories;
      });
    });
  }

  List<Product> filterProducts(List<Product> products, String query) {
    return [];
  }

  void _updateSelectedCategories() {
    setState(() {
      selectedCategoryIds = selectedCategories
          .map((categoryName) {
            try {
              return categories
                  .firstWhere((category) => category.grpName == categoryName)
                  .grpId;
            } catch (e) {
              print("Category not found: $categoryName");
              return -1;
            }
          })
          .where((id) => id != -1)
          .toList();
      print("Selected Category Names -------->>>>: $selectedCategories");
      print("Selected Category IDS -------->>>>: $selectedCategoryIds");
    });
  }

  void _applyFilters() async {
    try {
      final result = await apiService.getProductAndCategories(
        flag: 101,
        pageNo: 1,
        vendorId: widget.vendorId ?? 1,
        filterText: _searchController.text,
        selectedCategoryIds: selectedCategoryIds,
      );
      setState(() {
        productAndCategories = Future.value(result);
        print("Selected Category IDs: $selectedCategoryIds");
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showFilterBottomSheet(BuildContext context, List<Category> categories) {
    TextEditingController _searchController = TextEditingController();
    List<Category> filteredCategories = List.from(categories);
    List<String> localSelectedCategories = List.from(selectedCategories);

    void _filterCategories(String query) {
      setState(() {
        filteredCategories = categories
            .where((category) =>
                category.grpName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final mediaQuery = MediaQuery.of(context);
            final screenHeight = mediaQuery.size.height;
            final screenWidth = mediaQuery.size.width;

            List<Category> sortedCategories = List.from(filteredCategories)
              ..sort((a, b) {
                if (localSelectedCategories.contains(a.grpName) &&
                    !localSelectedCategories.contains(b.grpName)) {
                  return -1;
                } else if (!localSelectedCategories.contains(a.grpName) &&
                    localSelectedCategories.contains(b.grpName)) {
                  return 1;
                } else {
                  return a.grpName.compareTo(b.grpName);
                }
              });

            return Container(
              height: screenHeight * 0.6,
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Categories',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: screenWidth * 0.06),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.search, size: screenWidth * 0.06),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          style: TextStyle(fontSize: screenWidth * 0.04),
                          onChanged: (value) {
                            setState(() {
                              _filterCategories(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedCategories.length,
                      itemBuilder: (context, index) {
                        String firstLetter = sortedCategories[index]
                            .grpName
                            .substring(0, 1)
                            .toUpperCase();
                        bool isSelected = localSelectedCategories
                            .contains(sortedCategories[index].grpName);

                        return Container(
                          color: isSelected
                              ? Colors.blue.withOpacity(0.2)
                              : Colors
                                  .transparent, // Change color when selected
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  localSelectedCategories
                                      .add(sortedCategories[index].grpName);
                                } else {
                                  localSelectedCategories
                                      .remove(sortedCategories[index].grpName);
                                }
                                sortedCategories.sort((a, b) {
                                  if (localSelectedCategories
                                          .contains(a.grpName) &&
                                      !localSelectedCategories
                                          .contains(b.grpName)) {
                                    return -1;
                                  } else if (!localSelectedCategories
                                          .contains(a.grpName) &&
                                      localSelectedCategories
                                          .contains(b.grpName)) {
                                    return 1;
                                  } else {
                                    return a.grpName.compareTo(b.grpName);
                                  }
                                });
                                _updateSelectedCategories();
                                _applyFilters();
                              });
                            },
                            title: Text(
                              sortedCategories[index].grpName,
                              style: TextStyle(fontSize: screenWidth * 0.04),
                            ),
                            secondary: CircleAvatar(
                              radius: screenWidth * 0.06,
                              backgroundColor: Colors.purple,
                              child: Text(
                                firstLetter,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                            ),
                            // Adjust the color for the selected state
                            tileColor: isSelected
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var productDetailsProvider = Provider.of<ProductDetailsProvider>(context);
    var cartProvider = Provider.of<CartProvider>(context); // Add this line
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

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
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text(
            "Add Items",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                child: TextFormField(
                                  controller: _searchController,
                                  onChanged: (query) {
                                    setState(() {});
                                  },
                                  onFieldSubmitted: (value) {
                                    setState(() {
                                      _applyFilters();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Search',
                                    labelStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.06,
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setState(() {
                                                    _applyFilters();
                                                  });
                                                },
                                              )
                                            : IconButton(
                                                icon: Icon(
                                                  Icons.search,
                                                  color: Colors.red,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.06,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _applyFilters();
                                                  });
                                                },
                                              ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                  ),
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.barcode_reader,
                                size: MediaQuery.of(context).size.width * 0.1,
                                color: Constants.appColor,
                              ),
                              onPressed: scanQrCode,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Categories",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.filter_list_sharp,
                                color: Colors.blue,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                              onPressed: () {
                                if (productAndCategories != null) {
                                  productAndCategories.then((data) {
                                    _showFilterBottomSheet(
                                        context, data.data.categories);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.14, // Adjusted height for better spacing
                        child: FutureBuilder<ProductAndCategoriesModel>(
                          future: productAndCategories,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CupertinoActivityIndicator());
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Error fetching data ${snapshot.error}');
                            } else {
                              List<Category> categories =
                                  snapshot.data!.data.categories;
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: categories.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  Category category = categories[index];
                                  String firstLetterofCategory = category
                                      .grpName
                                      .substring(0, 1)
                                      .toUpperCase();
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.02,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.002,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            backgroundColor: Colors.purple,
                                            child: Text(
                                              firstLetterofCategory,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.18,
                                            child: Text(
                                              category.grpName,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines:
                                                  2, // Allows the text to wrap to two lines
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.03),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: 5), // Reduced gap between categories and products
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Products",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<ProductAndCategoriesModel>(
                      future: productAndCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CupertinoActivityIndicator());
                        } else if (snapshot.hasError) {
                          return Text("Error ${snapshot.error}");
                        } else {
                          List<Product> products = snapshot.data!.data.products;
                          return products.isNotEmpty
                              ? ListView.builder(
                                  itemCount: products.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    // Check if this index is the one where info button was clicked
                                    if (index == infoButtonClickedIndex) {
                                      return InkWell(
                                        onTap: () {
                                          productDetailsProvider
                                              .setProductDetails(
                                                  selectedProductId,
                                                  selectedProductName,
                                                  selectedUOM,
                                                  selectedUOMId,
                                                  selectedCost,
                                                  selectedItemID);
                                          _searchController.clear();
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CartDetailsScreen()));
                                        },
                                        child: Card(
                                          color: Colors.white,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.purple,
                                              child: Center(
                                                child: Text(
                                                  selectedProductName.substring(
                                                      0, 1),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(selectedProductName,
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                Text(
                                                    'Barcode : $selectedProductId',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('UNIT: $selectedUOM',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.green)),
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.info_outline),
                                                      color: Colors.blue,
                                                      onPressed: () {
                                                        showAlternativeUnits(
                                                            context,
                                                            products[index]
                                                                .itemID,
                                                            index);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                    'Price : ${selectedCost.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    // Original code for other items
                                    String productName =
                                        products[index].productName;
                                    dynamic productId =
                                        products[index].productId;
                                    dynamic itemID = products[index].itemID;
                                    dynamic UOMId = products[index].UOMId;
                                    String firstLetter =
                                        productName.substring(0, 1);
                                    String productUOM = products[index].UOM;
                                    double productCost =
                                        products[index].ProductCost;

                                    bool isInCart = cartProvider.items.any((item) =>
                                        item.itemId == itemID &&
                                        item.productIndex ==
                                            productId); // Check if the product is in the cart

                                    return InkWell(
                                      onTap: () {
                                        productDetailsProvider
                                            .setProductDetails(
                                                productId,
                                                productName,
                                                productUOM,
                                                UOMId,
                                                productCost,
                                                itemID);
                                        _searchController.clear();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CartDetailsScreen()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isInCart
                                              ? Colors.yellow[300]
                                              : Colors
                                                  .white, // Change color if in cart
                                          border: Border.all(
                                              color: Colors
                                                  .grey[300]!), // Add a border
                                          borderRadius: BorderRadius.circular(
                                              10), // Rounded corners
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal:
                                                8.0), // Margin around each item
                                        padding: EdgeInsets.all(
                                            8.0), // Padding inside each item
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.purple,
                                              child: Center(
                                                child: Text(
                                                  firstLetter,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                    8.0), // Space between avatar and text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(productName,
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  Text(
                                                      'ItemCode : ${productId.toString()}',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey)), // Reduced font size
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('UNIT: $productUOM',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .green)), // Reduced font size
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons.info_outline,
                                                            size:
                                                                20), // Reduced icon size
                                                        color: Colors.blue,
                                                        onPressed: () {
                                                          showAlternativeUnits(
                                                              context,
                                                              itemID,
                                                              index);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                      'Price : ${productCost.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey)), // Reduced font size
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text('No data found.',
                                      style: TextStyle(fontSize: 18)),
                                );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Stack(
            children: [
              Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.purple,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CartScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Bin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.shopping_cart,
                            size: 22,
                            color: Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: w / 2 - 60,
                child: badges.Badge(
                  position: badges.BadgePosition.topEnd(),
                  badgeContent: Consumer<CartProvider>(
                    builder: (context, cartProvider, _) {
                      return Text(
                        cartProvider.getCartQuantity().toString(),
                        style: TextStyle(
                            color: Colors
                                .black), // Optional: to set text color inside the badge
                      );
                    },
                  ),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor:
                        Colors.white, // Change this to your desired color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void scanQrCode() async {
    try {
      var qrCode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.QR,
      );
      if (mounted) {
        if (qrCode != "-1") {
          setState(() {
            _searchController.text = qrCode;
            productAndCategories = apiService.getProductAndCategories(
              flag: 101,
              pageNo: 1,
              vendorId: widget.vendorId ?? 1,
              filterText: _searchController.text,
            );
            _searchController.text = "";
          });
        }
      }
    } on PlatformException catch (e) {
      if (e.code == -1) {
        // Handle barcode scanner error
      } else {
        // Handle other errors
      }
    }
  }
}
