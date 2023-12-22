import 'dart:async';

import 'package:car_pooling/components/dbHelper.dart';
import 'package:car_pooling/components/history.dart';
import 'package:car_pooling/components/profileDB.dart';
import 'package:car_pooling/models/history.dart';
import 'package:car_pooling/models/profile.dart';
import 'package:car_pooling/modules/history.dart';
import 'package:car_pooling/modules/homepage.dart';
import 'package:car_pooling/modules/profile.dart';
import 'package:car_pooling/modules/routes_repo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routes.dart' as MyRoute;
import 'package:intl/intl.dart';

class Avalaible extends StatefulWidget {
  const Avalaible({super.key});

  @override
  State<Avalaible> createState() => _AvailableState();
}

class _AvailableState extends State<Avalaible> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  List<MyRoute.Route> search = [];
  final Connectivity _connectivity = Connectivity();
  bool bypassTimingCondition = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<MyRoute.Route> myRoutes = List<MyRoute.Route>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    //_firestore = ;
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    //   checkConnection();
    /////////////////////
    //   _fetchAvailableTrips();
    //  initializeDB();
    ////////////////////
    userFunc();
    initL();
  }

  initL() async {
    myRoutes = [];
  }

  // Future<void> initList() async {
  //   _firestore.collection('trips').snapshots().map((snapshot) {
  //     // print("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW");
  //     snapshot.docs.map((doc) {
  //       // If the route doesn't exist, add it to myRoutes
  //       //    if (search.length < snapshot.docs.length) {
  //       search.add(
  //           MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>));
  //       //  }

  //       MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>);
  //     }).toList();
  //   });
  // }

  // initializeDB() async {
  //   DBHelper dbHelper = DBHelper();
  //   await dbHelper.initDatabase();

  //   QuerySnapshot<Map<String, dynamic>> snapshot =
  //       await _firestore.collection('trips').get();

  //   List<MyRoute.Route> routes = snapshot.docs.map((doc) {
  //     return MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>);
  //   }).toList();

  //   for (var route in routes) {
  //     // Do something with 'route' if needed
  //     print("${route.departureDate}" + "111111111111111111111111111111");
  //     await dbHelper.insertOrUpdateRoute(route);
  //   }
  // }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityResult = result;
    });
  }

  checkConnection() async {
    _connectivityResult = await (Connectivity().checkConnectivity());
  }

  userFunc() async {
    User? user = FirebaseAuth.instance.currentUser;
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + user!.email.toString());
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + user.uid);

    final dbHelper = ProfileDBHelper();
    await dbHelper.initDatabase();

// Example: Insert or update a profile
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + user!.email.toString());
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + user.uid);

    // ProfileModel? profile =
    //     await dbHelper.getProfileByEmail(user.email.toString());
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? image = prefs.getString("image");
    //if (profile!.email!.isEmpty) {
    final profile = ProfileModel(
      email: user.email,
      address: '123 Main Street',
      phone: '123-456-7890',
      password: user.uid,
      image: image ?? "image",
    );

    await dbHelper.insertOrUpdateProfile(profile);
    //  }
    // else if (image.isNotEmpty) {
    //   final profile = ProfileModel(
    //     email: user.email,
    //     address: '123 Main Street',
    //     phone: '123-456-7890',
    //     password: user.uid,
    //     image: image,
    //   );
    //   await dbHelper.insertOrUpdateProfile(profile);
    // } else {}
  }

  Future<void> historyTrip(MyRoute.Route routed, HistoryItem item) async {
    final dbHelper = DBHelperHistory();
    await dbHelper.initDatabase();

    try {
      print("HISTOOOOOOOOOOOORY");
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await dbHelper.insertHistoryItem(item);

        // await dbHelper.insertOrUpdateRoute(sampleRoute);
        // List<MyRoute.Route> testA = await dbHelper.getRoutes();
        // print(testA);
        print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        await _firestore.collection('history').doc(user.uid).set({
          'userId': user.uid,
          'source': "routed.fromRoute", // Replace with your source logic
          'destination': routed.toRoute,
          "tripState": "finished",
          'time': routed.departureDate,
          "price": routed.price,
          "driver": routed.userId
        });

        // Create a trip document in Firestore

        // Display success message or navigate to the next page
      } else {
        print('User not signed in.');
      }
    } catch (e) {
      // Handle errors
      print('Error starting trip: $e');
    }
  }

  void _showReservationNotAllowedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reservation Not Allowed"),
          content: Text("You can't reserve a trip at this time."),
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

  // bool canReserve(MyRoute.Route route) {
  //   DateTime departureTime = _parseDepartureTime(route.departureDate);
  //   DateTime currentTime = DateTime.now();

  //   // Adjust the reservation cutoff time based on departure time
  //   if (departureTime.hour == 17 && departureTime.minute == 30) {
  //     // If departure time is 5:30 PM, cutoff time is 1:00 PM
  //     DateTime cutoffTime =
  //         DateTime(currentTime.year, currentTime.month, currentTime.day, 13, 0);
  //     return currentTime.isBefore(cutoffTime);
  //   } else if (departureTime.hour == 7 && departureTime.minute == 30) {
  //     // If departure time is 7:30 AM, cutoff time is 10:00 PM the day before
  //     DateTime cutoffTime = DateTime(
  //         currentTime.year, currentTime.month, currentTime.day - 1, 22, 0);
  //     return currentTime.isBefore(cutoffTime);
  //   }

  //   // Default case, allow reservation
  //   return true;
  // }

  // DateTime _parseDepartureTime(String departureTime) {
  //   // Use the intl package to parse the time string
  //   return DateFormat.E().add_jm().parse(departureTime);
  // }
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
///////////////////////////////

  bool canReserve(MyRoute.Route route) {
    if (bypassTimingCondition) {
      return true;
    }
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat("EEEE, hh:mm a", 'en_US');
    DateTime departureTime = dateFormat.parse(route.departureDate);

    if (route.departureDate.toLowerCase().contains("am")) {
      print("AAAAAAAAAAAAAMMMMMMMMMM");
      // If departure time is in the morning
      DateTime reservationDeadline = DateTime(
        departureTime.year,
        departureTime.month,
        departureTime.day - 1,
        22, // 10:00 PM
        0,
      );

      return now.isBefore(reservationDeadline);
    } else {
      // If departure time is in the evening
      DateTime reservationDeadline = DateTime(
        departureTime.year,
        departureTime.month,
        departureTime.day,
        13, // 1:00 PM
        0,
      );
      print(now.isBefore(reservationDeadline));
      return now.isBefore(reservationDeadline);
    }
  }

  // DateTime _parseDepartureTime(String departureDate) {
  //   return DateFormat('hh:mm a').parse(departureDate);
  // }
  Stream<List<MyRoute.Route>> _fetchAvailableTrips() async* {
    myRoutes.clear();
    DBHelper dbHelper = DBHelper();
    await dbHelper.initDatabase();
    // checkConnection();
    if (_connectivityResult == ConnectivityResult.none) {
      print("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
    } else {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('trips').get();

      List<MyRoute.Route> routes = snapshot.docs.map((doc) {
        return MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      for (var route in routes) {
        // Do something with 'route' if needed
        print("${route.departureDate}" + "111111111111111111111111111111");

        await dbHelper.insertOrUpdateRoute(route);
      }
      // print("AAAAAAAAAANYYYYAAAAAAAAAA");
      //////////////////////////////////////////////////////////
//       _firestore.collection('trips').snapshots().asyncMap((snapshot) async {
//         // Create an instance of DBHelper
//         print("AAAAAAAAAANYYYYAAAAAAAAAA");
// // Initialize the database

//         for (var doc in snapshot.docs) {
//           MyRoute.Route route =
//               MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>);
//           print(route.fromRoute + "NEEEEEEEEEEEEEEEEEEEEEEET");
//           // Insert or update the route in the local database
//           await dbHelper.insertOrUpdateRoute(route);
//         }
//       });
      //   print("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW");

      //////////////////////////////////////////////////////
    }
////////////////////////////////////////////////////////////
    if (_connectivityResult == ConnectivityResult.none) {
      myRoutes = await dbHelper.getRoutes();
      print(myRoutes.length);
      print("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
      yield myRoutes;
    } else {
      yield* _firestore.collection('trips').snapshots().map((snapshot) {
        myRoutes.clear();
        // print("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW");
        return snapshot.docs.map((doc) {
          MyRoute.Route newRoute =
              MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>);
          //  if (myRoutes.length < snapshot.docs.length) {

          //}

          print(myRoutes.length);
          print(
              MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>));
          print(MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>)
              .userId);
          print(MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>)
              .fromRoute);
          print(MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>)
              .toRoute);
          myRoutes.add(
              MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>));
///////////////////////////////////////////////////////////
          // bool routeExists = false;

          // for (int i = 0; i < myRoutes.length; i++) {
          //   if (myRoutes[i].userId == newRoute.userId) {
          //     // Update the existing route in myRoutes with new data
          //     myRoutes[i] = MyRoute.Route.fromFirestore(
          //         doc.data() as Map<String, dynamic>);
          //     routeExists = true;
          //     break;
          //   }
          // }

          // if (!routeExists) {
          //   // If the route doesn't exist, add it to myRoutes
          //   myRoutes.add(MyRoute.Route.fromFirestore(
          //       doc.data() as Map<String, dynamic>));
          // }
///////////////////////////////////////////////////////////
          return MyRoute.Route.fromFirestore(
              doc.data() as Map<String, dynamic>);
        }).toList();
      });
      setState(() {});
    }

    ////////////////////////////////////////////////////////////
    // RoutesRepository routesRepository = RoutesRepository(dbHelper);
    // return _firestore
    //     .collection('trips')
    //     .snapshots()
    //     .asyncMap((snapshot) async {
    //   // Fetch available routes from the repository
    //   List<MyRoute.Route> routes =
    //       await routesRepository.fetchAvailableRoutes();

    //   // You can perform additional operations here if needed
    //   print(routes.length);

    //   // Return the fetched routes
    //   return routes;
    //   ///////////////////////////////////
    // });
    //////////////////////////////////////////////////////////////
  }

  Future<void> updateUser(MyRoute.Route routeUpdate) async {
    //print(args?.tripState);
    CollectionReference users = FirebaseFirestore.instance.collection('trips');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("driverUserId", "${routeUpdate.userId}");

    final FirebaseAuth _auth = FirebaseAuth.instance;
    //  _auth.currentUser!.uid;

    await users
        .doc(routeUpdate.userId)
        .update({'userId': '${_auth.currentUser!.uid}'})
        .then((value) => print("Trip Updated"))
        .catchError((error) => print("Failed to update trip: $error"));

    return await users
        .doc(routeUpdate.userId)
        .update({'tripState': 'approved'})
        .then((value) => print("Trip Updated"))
        .catchError((error) => print("Failed to update trip: $error"));
  }

  // void filterList(String query) async {
  //   var filteredItems =
  //       myRoutes.where((element) => element.fromRoute.contains(query)).toList();
  //   setState(() {
  //     print("${filteredItems.length}" +
  //         " NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
  //     myRoutes = filteredItems;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Search Trips',
        onPressed: () => showSearch(
          context: context,
          delegate: SearchPage(
            onQueryUpdate: print,
            items: myRoutes,
            searchLabel: 'Search Trips',
            suggestion: const Center(
              child: Text('Filter Trips'),
            ),
            failure: const Center(
              child: Text('No Trip found :('),
            ),
            filter: (person) => [
              person.fromRoute,
              person.toRoute,
              person.price.toString(),
            ],
            sort: (a, b) => a.compareTo(b),
            builder: (person) => Container(
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
                      itemCount: myRoutes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.r, vertical: 3.r),
                          child: Card(
                            elevation: 5.0.r,
                            margin: EdgeInsets.symmetric(vertical: 2.0),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${myRoutes[index].fromRoute}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 4.0.h),
                                        child: Text(
                                          'To ${myRoutes[index].toRoute}',
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 4.0.h),
                                        child: Text(
                                          '\$${myRoutes[index].price}',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${myRoutes[index].departureDate}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (canReserve(myRoutes[index]) ==
                                                  true) {
                                                User? user = FirebaseAuth
                                                    .instance.currentUser;

                                                final historyItem = HistoryItem(
                                                  userId: user!.uid,
                                                  source:
                                                      myRoutes[index].fromRoute,
                                                  destination:
                                                      myRoutes[index].toRoute,
                                                  tripState: "finished",
                                                  time: myRoutes[index]
                                                      .departureDate,
                                                  price: myRoutes[index].price,
                                                  driver:
                                                      myRoutes[index].userId,
                                                );
                                                historyTrip(myRoutes[index],
                                                    historyItem);
                                                updateUser(myRoutes[index]);
                                                Navigator.pushNamed(
                                                  context,
                                                  "/cart",
                                                  arguments: myRoutes[index],
                                                );
                                              } else {
                                                _showReservationNotAllowedDialog();
                                              }
                                            },
                                            child: Text("Reserve",
                                                style:
                                                    TextStyle(fontSize: 18.sp)),
                                          ),
                                          Switch(
                                            value: bypassTimingCondition,
                                            onChanged: (value) {
                                              setState(() {
                                                bypassTimingCondition = value;
                                              });
                                            },
                                          ),
                                          Text('Bypass'),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              // Add other properties you want to display
                            ),
                          ),
                        );
                      },

                      // title: Text(person.fromRoute),
                      // subtitle: Text(person.toRoute),
                      // trailing: Text('${person.price} '),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: const Icon(Icons.search),
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
            ],
          )),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0.h),
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Available Trips",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
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
                // padding: EdgeInsets.only(top: 10.h),
                width: double.infinity,
                height: double.infinity,
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
                        //itemCount: myRoutes.length,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          if (index == snapshot.data.length - 1) {
                            // return ListView(
                            //   children: snapshot.data!.docs
                            //       .map((DocumentSnapshot document) {
                            //     Map<String, dynamic> data =
                            //         document.data()! as Map<String, dynamic>;
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.r, vertical: 3.r),
                                  child: Card(
                                    elevation: 5.0.r,
                                    margin: EdgeInsets.symmetric(vertical: 3),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Center(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 3.h,
                                                ),
                                                Text(
                                                  '${myRoutes[index].fromRoute}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 4.0.h),
                                                  child: Text(
                                                      'To ${myRoutes[index].toRoute}'),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 4.0.h),
                                                  child: Text(
                                                    '\$${myRoutes[index].price}',
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 3.h,
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${myRoutes[index].departureDate}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        if (canReserve(myRoutes[
                                                                index]) ==
                                                            true) {
                                                          User? user =
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser;

                                                          final historyItem =
                                                              HistoryItem(
                                                            userId: user!.uid,
                                                            source:
                                                                myRoutes[index]
                                                                    .fromRoute,
                                                            destination:
                                                                myRoutes[index]
                                                                    .toRoute,
                                                            tripState:
                                                                "finished",
                                                            time: myRoutes[
                                                                    index]
                                                                .departureDate,
                                                            price:
                                                                myRoutes[index]
                                                                    .price,
                                                            driver:
                                                                myRoutes[index]
                                                                    .userId,
                                                          );

                                                          historyTrip(
                                                              myRoutes[index],
                                                              historyItem);
                                                          updateUser(
                                                              myRoutes[index]);
                                                          Navigator.pushNamed(
                                                            context,
                                                            "/cart",
                                                            arguments:
                                                                myRoutes[index],
                                                          );
                                                        } else {
                                                          setState(() {
                                                            _showReservationNotAllowedDialog();
                                                          });
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Text("Reserve",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  18.sp))),
                                                  Switch(
                                                    value:
                                                        bypassTimingCondition,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        bypassTimingCondition =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                  Text('Bypass'),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),

                                      // Add other properties you want to display
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0.h, horizontal: 72.w),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    OrderHistoryPage()));
                                      },
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                "History",
                                                style:
                                                    TextStyle(fontSize: 25.sp),
                                              ),
                                            ),
                                            SizedBox(width: 7.w),
                                            Icon(Icons.history_edu_rounded)
                                          ],
                                        ),
                                      )),
                                ),
                              ],
                            );
                            //   }).toList(),
                            // );
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.r, vertical: 3.r),
                            child: Card(
                              elevation: 5.0.r,
                              margin: EdgeInsets.symmetric(vertical: 2.0),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '${myRoutes[index].fromRoute}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 4.0.h),
                                          child: Text(
                                            'To ${myRoutes[index].toRoute}',
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 4.0.h),
                                          child: Text(
                                            '\$${myRoutes[index].price}',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${myRoutes[index].departureDate}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (canReserve(
                                                        myRoutes[index]) ==
                                                    true) {
                                                  User? user = FirebaseAuth
                                                      .instance.currentUser;

                                                  final historyItem =
                                                      HistoryItem(
                                                    userId: user!.uid,
                                                    source: myRoutes[index]
                                                        .fromRoute,
                                                    destination:
                                                        myRoutes[index].toRoute,
                                                    tripState: "finished",
                                                    time: myRoutes[index]
                                                        .departureDate,
                                                    price:
                                                        myRoutes[index].price,
                                                    driver:
                                                        myRoutes[index].userId,
                                                  );
                                                  historyTrip(myRoutes[index],
                                                      historyItem);
                                                  updateUser(myRoutes[index]);
                                                  Navigator.pushNamed(
                                                    context,
                                                    "/cart",
                                                    arguments: myRoutes[index],
                                                  );
                                                } else {
                                                  _showReservationNotAllowedDialog();
                                                }
                                              },
                                              child: Text("Reserve",
                                                  style: TextStyle(
                                                      fontSize: 18.sp)),
                                            ),
                                            Switch(
                                              value: bypassTimingCondition,
                                              onChanged: (value) {
                                                setState(() {
                                                  bypassTimingCondition = value;
                                                });
                                              },
                                            ),
                                            Text('Bypass'),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),

                                // Add other properties you want to display
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            ;

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}



// final historyItem = HistoryItem(
//   userId: user!.uid,
//   source: routed.fromRoute,
//   destination: routed.toRoute,
//   tripState: "finished",
//   time: routed.departureDate,
//   price: routed.price,
//   driver: routed.userId,
// );
