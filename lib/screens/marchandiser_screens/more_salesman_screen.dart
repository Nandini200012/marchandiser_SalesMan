import 'package:flutter/material.dart';
import 'package:marchandise/screens/marchandiser_screens/all_salesman_select_screen.dart';

class MoreSalesManScreen extends StatefulWidget {
  const MoreSalesManScreen({super.key});

  @override
  State<MoreSalesManScreen> createState() => _MoreSalesManScreenState();
}

class _MoreSalesManScreenState extends State<MoreSalesManScreen> {
  String selectedValue = 'Sales Man 1';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back)),
                    const SizedBox(
                      width: 10,
                    ),
                    Text("Request Details")
                  ],
                ),
                const SizedBox(height: 25),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text("Choose Salesman")),
                const SizedBox(height: 15),
                Container(
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage("assets/workersimg.png"),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Vaughn",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text("Grocery")
                          ],
                        )
                      ],
                    )),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedValue, // Initial value
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items: <String>[
                    'Sales Man 1',
                    'Sales Man 2',
                    'Sales Man 3',
                    'Sales Man 4'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
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
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 5, 92, 163),
                                Color.fromARGB(255, 5, 92, 163),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      AllSelctSalesManScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Next",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
