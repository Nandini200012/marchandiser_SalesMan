import 'package:flutter/material.dart';
import 'package:marchandise/screens/marchandiser_screens/add_product_list_screen.dart';
import 'package:marchandise/utils/constants.dart';

class AllSelctSalesManScreen extends StatefulWidget {
  const AllSelctSalesManScreen({super.key});

  @override
  State<AllSelctSalesManScreen> createState() => _AllSelctSalesManScreenState();
}

class _AllSelctSalesManScreenState extends State<AllSelctSalesManScreen> {
  List<bool> selectedItems = List.generate(5, (index) => false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back,color:Colors.white)),
          title: Text(
            "Request Details",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: CircleAvatar(
                child: Text("MR"),
                radius: 22,
              ),
            ),
          ],
        ),
       body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Colors.blue, // Top color
            Colors.white, // New middle color (white)
            Colors.white, // New middle color (white)
            Colors.white, // New middle color (white)
            Colors.blue, // Bottom color
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4, 0.6, 0.8, 1.0],
        )),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Row(
                //   children: [
                //     IconButton(
                //         onPressed: () {
                //           Navigator.of(context).pop();
                //         },
                //         icon: Icon(Icons.arrow_back)),
                //     const SizedBox(
                //       width: 10,
                //     ),
                //     Text("Request Details")
                //   ],
                // ),
                // const SizedBox(height: 25),
                // Align(
                //     alignment: Alignment.topLeft,
                //     child: Text("Choose Salesman")),
                const SizedBox(height: 15),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            // tileColor: Colors.white,
                            leading: CircleAvatar(
                              radius: 30,
                              child: Text("V"),
                            ),
                            title: Text(
                              "Vayughen",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text("Grocery"),
                            trailing: Checkbox(
                              value: selectedItems[index],
                              onChanged: (value) {
                                setState(() {
                                  selectedItems[index] = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                //  Container(
                //   child: Image.asset("assets/frame1107.png"),
                // ),

                const SizedBox(height: 25),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Description",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )),
                const SizedBox(height: 10),
                TextFormField(
                  maxLines: 5, // Adjust the number of lines as needed
                  decoration: InputDecoration(
                    hintText: 'Enter your description here',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                // Spacer(),
                // Row(
                //   children: [
                //     Expanded(
                //       child: SizedBox(
                //         width: double.infinity,
                //         child: Container(
                //           height: 52,
                //           width: double.infinity,
                //           decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(10),
                //               color: Constants.appColor
                //               // gradient: const LinearGradient(
                //               //   colors: [
                //               //     Color.fromARGB(255, 5, 92, 163),
                //               //     Color.fromARGB(255, 5, 92, 163),
                //               //   ],
                //               //   begin: Alignment.centerLeft,
                //               //   end: Alignment.centerRight,
                //               // ),
                //               ),
                //           child: ElevatedButton(
                //             onPressed: () {
                //               Navigator.of(context).push(MaterialPageRoute(
                //                   builder: (context) =>
                //                       AddProductListViewScreen()));
                //             },
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: Colors.transparent,
                //               elevation: 0,
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(10.0),
                //               ),
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.end,
                //               children: [
                //                 const Text(
                //                   "Next",
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 18,
                //                     fontWeight: FontWeight.w500,
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   width: 15,
                //                 ),
                //                 Icon(
                //                   Icons.arrow_forward_ios,
                //                   color: Colors.white,
                //                 )
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // )
              ],
            ),
          ),
        ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Constants.appColor,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddProductListViewScreen()));
          },
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        ));
  }
}
