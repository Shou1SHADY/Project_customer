import 'package:car_pooling/modules/avalaible.dart';
import 'package:car_pooling/modules/cartpage.dart';

import 'package:car_pooling/modules/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modules/homepage.dart';

const ColorScheme myColorScheme = ColorScheme(
  primary: Color.fromARGB(255, 167, 130, 231),
  secondary: Color.fromARGB(255, 253, 244, 244),
  surface: Colors.white,
  background: Colors.white,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.white,
  brightness: Brightness.light,
);

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navKey = GlobalKey<NavigatorState>();
  bool logged = true;
  String email = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //methodlogging();
    checkLogin();
    // });
  }

  // methodlogging() async {
  //   logged = await checkLogin();
  // }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   checkLogin(context);
  // }

  Future<void> checkLogin() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email") ?? "none";
    String pass = prefs.getString("password") ?? "none";
    print(pass + " " + email);
    if (email.isNotEmpty && pass.isNotEmpty) {
      UserCredential userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );
        _navKey.currentState?.pushReplacementNamed('/cart');
        //  return true;
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (_) => Avalaible()),
        //   (route) => false, // This removes all routes below the pushed route
        // );
      } catch (e) {
        // Handle authentication errors
        print("Authentication error: $e");
      }
    }
    // return false;
  }
//   Future checkLogin(BuildContext context) async {
// // Obtain shared preferences.
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     email = prefs.getString("email")!;
//     String pass = prefs.getString("password")!;
//     print(pass + " " + email);
//     if (email.isNotEmpty && pass.isNotEmpty) {
//       UserCredential userCredential;
//       userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: pass,
//       );
//       Navigator.push(context, MaterialPageRoute(builder: (_) => Avalaible()));
//     }
//   }

  @override
  Widget build(BuildContext context) {
    MaterialColor myPrimarySwatch = MaterialColor(
      Color.fromARGB(255, 185, 152, 241).value,
      <int, Color>{
        50: myColorScheme.primary.withOpacity(0.1),
        100: myColorScheme.primary.withOpacity(0.2),
        200: myColorScheme.primary.withOpacity(0.3),
        300: myColorScheme.primary.withOpacity(0.4),
        400: myColorScheme.primary.withOpacity(0.5),
        500: myColorScheme.primary.withOpacity(0.6),
        600: myColorScheme.primary.withOpacity(0.7),
        700: myColorScheme.primary.withOpacity(0.8),
        800: myColorScheme.primary.withOpacity(0.9),
        900: myColorScheme.primary,
      },
    );

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: _navKey,
          debugShowCheckedModeBanner: false,
          title: 'Flutter',
          theme: ThemeData(
            colorScheme: myColorScheme,
            useMaterial3: true,
            primarySwatch: myPrimarySwatch,
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              headline1: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              bodyText1: TextStyle(
                fontSize: 16.0,
              ),
              button: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => MyHomePage(), //HomePage
            '/register': (context) => const RegisterPage(),
            '/cart': (context) => CartPage(),
            '/avai': (context) => Avalaible()
          },
          home: child,
        );
      },
      child: email.isEmpty ? MyHomePage() : CartPage(), // Homepage
    );
  }
}
