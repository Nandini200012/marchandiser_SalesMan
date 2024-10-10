import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marchandise/screens/manager_screens/manager_bottom_navbar.dart';
import 'package:marchandise/screens/marchandiser_screens/marchendiser_bottomnav.dart';
import 'package:marchandise/screens/salesman_screens/salesman_bottom_navbar.dart';
import 'package:marchandise/utils/SharedPreferencesUtil.dart';
import 'package:marchandise/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool("rememberMe") ?? false;

    if (remember) {
      String? username = prefs.getString("rememberedUsername");
      String? password = prefs.getString("rememberedPassword");

      if (username != null && password != null) {
        usernameController.text = username;
        passwordController.text = password;
        rememberMe = true;
      }
    }
  }

  Future<void> _signIn() async {
    try {
      EasyLoading.show(
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false,
          status: "Please Wait");

      String enteredUsername = usernameController.text;
      String enteredPassword = passwordController.text;

      var url = Uri.parse(Urls.login);

      var response = await http.get(url,
          headers: {'UserID': enteredUsername, 'Password': enteredPassword});

      print("Response:>>>$response");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['isSuccess']) {
          var data = jsonResponse['data'][0];
          String userId = data['UserId'];
          int employeeId = data['EmployeeId'];
          String appRole = data['App_Role'];

          await SharedPreferencesUtil.setUserDetails(
              userId, employeeId, appRole);

          if (rememberMe) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("rememberMe", true);
            prefs.setString("rememberedUsername", enteredUsername);
            prefs.setString("rememberedPassword", enteredPassword);
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("rememberMe", false);
            prefs.remove("rememberedUsername");
            prefs.remove("rememberedPassword");
          }
          _navigateToUserScreen(appRole);
        } else {
          _showErrorDialog('Invalid Login Credential.');
        }
      } else {
        _showErrorDialog('Failed to authenticate. Please try again.');
      }
    } catch (error) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _navigateToUserScreen(String appRole) {
    switch (appRole) {
      // case "Merchandiser":
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => const MarchendiserBottomNavigation()),
      //   );
      //   break;
      case "SalesMan":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SalesManBottomNavBar()),
        );
        break;
      case "Manager":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManagerBottomNavBar()),
        );
        break;
      default:
        _showErrorDialog('Invalid role.');
        break;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  const BorderSide(
                      color: Colors.blue,
                      width: 2.0), // Set the border color and width
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomPaint(
              painter: BackgroundPainter(),
              child: Container(),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                if (kIsWeb) {
                  return _buildWebLayout(constraints);
                } else {
                  return _buildMobileLayout(constraints);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    final paddingHorizontal = screenWidth * 0.05; // 5% of the screen width
    final paddingVertical = screenHeight * 0.1; // 10% of the screen height

    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          width: screenWidth * 0.4, // 40% of the screen width
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    final paddingHorizontal = screenWidth * 0.05; // 5% of the screen width
    final paddingVertical = screenHeight * 0.05; // 5% of the screen height

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sign In",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.person, color: Colors.yellow[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              PasswordField(controller: passwordController),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  const Text(
                    "Remember me",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black,
                  ),
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const PasswordField({Key? key, required this.controller}) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        fillColor: Colors.grey[200],
        filled: true,
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.lock, color: Colors.yellow[700]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.yellow[700],
          ),
          onPressed: _togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFFFFD317),
          Color(0xFFFDFCFB),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(0, size.height * 0.15);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1,
        size.width * 0.5, size.height * 0.25);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.4, size.width, size.height * 0.15);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.85,
        size.width * 0.5, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.95, size.width, size.height * 0.85);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
