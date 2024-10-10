import 'package:flutter/material.dart';
import 'package:marchandise/screens/sign_in_screen/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> _future;
  bool _showSecondImage = false;
  @override
  void initState() {
    super.initState();
    _future = _initApp();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignInScreen()));
    });
  }

  Future<void> _initApp() async {
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    print("height:>>> $h");
    print("width:>>> $w");
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/gbcimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 30),
          Visibility(
            visible: _showSecondImage,
            child: Center(
              child: Container(
                height: 200,
                width: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/workersimg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load the second image after the first image is loaded
    precacheImage(
      AssetImage("assets/workersimg.png"),
      context,
      onError: (dynamic error, StackTrace? stackTrace) {
        // Handle error if necessary
      },
    ).then((value) {
      // Set a delay before showing the second image to ensure the first image is displayed
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _showSecondImage = true;
        });
      });
    });
  }
}
// import 'package:flutter/material.dart';
// import 'package:marchandise/screens/sign_in_screen/sign_in_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   late Future<void> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = _initApp();
//   }

//   Future<void> _initApp() async {
//     await _saveUserCredentials();
//     // You can perform other initialization tasks here

//     // Simulate additional initialization time (replace with actual logic)
//     await Future.delayed(Duration(seconds: 3));
//   }

//   Future<void> _saveUserCredentials() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Save user credentials
//     prefs.setString("userName1", "mr");
//     prefs.setString("password1", "123");

//     prefs.setString("userName2", "sm");
//     prefs.setString("password2", "1234");

//     prefs.setString("userName3", "mgr");
//     prefs.setString("password3", "12345");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder(
//         future: _future,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Show a loading indicator while waiting for the future to complete
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else {
//             // Once the future is complete, navigate to the SignInScreen
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                 builder: (context) => SignInScreen(),
//               ),
//             );
//             return Container(); // Placeholder, the actual content is being replaced by the SignInScreen
//           }
//         },
//       ),
//     );
//   }
// }
