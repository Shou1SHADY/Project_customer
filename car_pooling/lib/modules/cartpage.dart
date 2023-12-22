import 'package:car_pooling/components/profileDB.dart';
import 'package:car_pooling/models/profile.dart';
import 'package:car_pooling/modules/avalaible.dart';
import 'package:car_pooling/modules/history.dart';
import 'package:car_pooling/modules/homepage.dart';
import 'package:car_pooling/modules/payment.dart';
import 'package:car_pooling/modules/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routes.dart' as MyRoute;

class CartPage extends StatefulWidget {
  // Include necessary parameters and constructors

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Assuming you have a way to get selected routes and total price

  late FirebaseFirestore _firestore;
  List<MyRoute.Route> _MyRoutess = [];
  final Logger logger = Logger();
  String fromRoute = "";
  String toRoute = "";
  int totalPrice = 0;
  // MyRoute.Route route = MyRoute.Route(fromRoute: "", toRoute: "", price: 0);

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully.');
    } catch (e) {
      print('Error signing out: $e');
      // Handle errors here
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('email');
    await preferences.remove('password');
  }

  userFunc() async {
    User? user = FirebaseAuth.instance.currentUser;

    final dbHelper = ProfileDBHelper();
    await dbHelper.initDatabase();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? image = prefs.getString("image");
    //if (profile!.email!.isEmpty) {
    final profile = ProfileModel(
      email: user!.email ?? "",
      address: '123 Main Street',
      phone: '123-456-7890',
      password: user.uid,
      image: image ?? "image",
    );
    await dbHelper.insertOrUpdateProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    MyRoute.Route? args =
        ModalRoute.of(context)!.settings.arguments as MyRoute.Route?;

    Stream<List<MyRoute.Route>> _fetchAvailableTrips() {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      print("sssssssssssssssssssssssssssssssssssssssssssssss");
      return _firestore
          .collection('trips')
          .where('userId',
              isEqualTo:
                  _auth.currentUser!.uid) // Add this line to filter by userId
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          if (_MyRoutess.length < snapshot.docs.length) {
            _MyRoutess.add(MyRoute.Route.fromFirestore(
                doc.data() as Map<String, dynamic>));
          }

          print(_MyRoutess.length);
          print(_MyRoutess[0].userId);
          return MyRoute.Route.fromFirestore(
              doc.data() as Map<String, dynamic>);
        }).toList();
      });
    }
    // CollectionReference users = FirebaseFirestore.instance.collection('trips');

    // Future<void> updateUser() async {
    //   print(args?.tripState);
    //   final SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.setString("driverUserId", "${args?.userId}");
    //   return await users
    //       .doc(args?.userId)
    //       .update({'tripState': 'approved'})
    //       .then((value) => print("Trip Updated"))
    //       .catchError((error) => print("Failed to update trip: $error"));
    // }
//////////////////////////////////////
    // if (args == null) {
    //   return Scaffold(
    //     body: Center(
    //       child: Text('Error: Missing arguments'),
    //     ),
    //   );
    // } else {
    ///////////////////////
    //route = args;
    // fromRoute = args.fromRoute;
    // toRoute = args.toRoute;
    // totalPrice = args.price;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => Avalaible()));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.directions_car), // Add your preferred icon
            SizedBox(height: 5.0),
            Text(
              'Find',
              style: TextStyle(fontSize: 12.sp),
            ), // Add your preferred text
          ],
        ),
      ),
      drawer: Drawer(
          width: 200.w,
          child: ListView(
            children: [
              Divider(),
              InkWell(
                onTap: () {
                  userFunc();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Profile()));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.person, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () async {
                  final currentContext = context;
                  await signOut();

                  Navigator.pushAndRemoveUntil(
                    currentContext,
                    MaterialPageRoute(builder: (_) => MyHomePage()),
                    (route) => false,
                  );
                  ;
                },
                child: ListTile(
                  leading: Icon(
                    Icons.exit_to_app, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  final currentContext = context;

                  Navigator.pushReplacement(
                    currentContext,
                    MaterialPageRoute(builder: (_) => OrderHistoryPage()),
                  );
                  ;
                },
                child: ListTile(
                  leading: Icon(
                    Icons.history, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "History",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () async {
                  final currentContext = context;

                  Navigator.pushReplacement(
                    currentContext,
                    MaterialPageRoute(builder: (_) => Avalaible()),
                  );
                  ;
                },
                child: ListTile(
                  leading: Icon(
                    Icons.car_rental, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "Trips",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
            ],
          )),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'My Ride',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<List<MyRoute.Route>>(
          stream: _fetchAvailableTrips(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No available trips.'));
            }
            if (snapshot.hasData) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/photos/background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      itemCount: _MyRoutess.length,
                      itemBuilder: (BuildContext context, int index) {
                        // SizedBox(
                        //   height: 12.h,
                        // ),
                        // CircleAvatar(
                        //   // Display user profile picture using FirebaseAuth
                        //   backgroundImage:
                        //       NetworkImage(_getUserProfilePictureUrl()),
                        //   radius: 70.0.r,
                        // ),
                        // SizedBox(
                        //   height: 20.h,
                        // ),
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              color: Color.fromARGB(255, 255, 238, 160),
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'From : ${_MyRoutess[index].fromRoute} ',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'To :  ${_MyRoutess[index].toRoute}',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Total Price: \$${_MyRoutess[index].price.toString()}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Trip State: ${_MyRoutess[_MyRoutess.length - 1].tripState.toString()}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: () {
                                        logger.d(_MyRoutess[index].userId);
                                        print("Date" +
                                            _MyRoutess[index].departureDate);
                                        print("userID" + _MyRoutess[index].id);
                                        print("userID" +
                                            _MyRoutess[index].userId);
                                        print(_MyRoutess[index].tripState);
                                        //  _makePayment();
                                        //  updateUser();

                                        _makePayment();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary:
                                            Color.fromARGB(255, 199, 219, 255),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Make Payment',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ))
                  ],
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
    //////////////////}
  }

  String _getUserProfilePictureUrl() {
    // Replace with your logic to get the user's profile picture URL from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.photoURL != null) {
      return user.photoURL!;
    } else {
      // You can return a default image URL or an empty string
      return "assets/photos/486x486bb.png";
    }
  }

  _makePayment() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage()));
  }
}
