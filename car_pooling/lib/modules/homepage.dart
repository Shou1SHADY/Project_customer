import 'package:car_pooling/modules/avalaible.dart';

import 'package:car_pooling/modules/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<MyHomePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void localDataBaseHandling() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', usernameController.text.toString().trim());
    await prefs.setString(
        'password', passwordController.text.toString().trim());
  }

  Future<void> _login() async {
    String userLogging = usernameController.text;
    String userPass = passwordController.text;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userLogging.toString().trim(),
        password: userPass.toString().trim(),
      );

      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('userID', _auth.tenantId.toString());

      localDataBaseHandling();
      // Successful login
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //       title: Text("Login Successful"),
      //       content: Text("Welcome, ${userCredential.user!.email}!"),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: Text("OK"),
      //         ),
      //       ],
      //     );
      //   },
      // );
      Navigator.push(context, MaterialPageRoute(builder: (_) => Avalaible()));
    } on FirebaseAuthException catch (e) {
      print("FAAAAIIIILLLL");
      // Failed login
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Login Failed"),
            content: Text(e.message ?? "Invalid username or password"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Login Page",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/photos/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(3.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Car',
                        style: TextStyle(
                          color: Colors.blue, // Change color for the letter 'C'
                          fontWeight: FontWeight.bold,
                          fontSize: 50.sp,
                        ),
                      ),
                      TextSpan(
                        text: 'Pooling',
                        style: TextStyle(
                          color: Colors
                              .green, // Change color for the rest of the text
                          fontWeight: FontWeight.bold,
                          fontSize: 50.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Image.asset(
                  "assets/photos/4660770.png",
                  width: 160.w,
                  height: 140.h,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0.r),
                        borderSide: BorderSide(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(),
                      ),
                    ),
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 27.h),
                Row(
                  children: [
                    // Styled Register Button
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Not Registered Yet ?",
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 68, 124),
                                fontSize: 12.sp),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RegisterPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.h, horizontal: 40.w),
                            ),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 28.h,
                          ),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.h, horizontal: 55.w),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
