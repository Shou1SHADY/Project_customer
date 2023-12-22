import 'package:car_pooling/components/dbHelper.dart';
import 'package:car_pooling/components/history.dart';
import 'package:car_pooling/components/profileDB.dart';
import 'package:car_pooling/models/history.dart';
import 'package:car_pooling/models/profile.dart';
import 'package:car_pooling/modules/avalaible.dart';
import 'package:car_pooling/modules/homepage.dart';
import 'package:car_pooling/modules/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routes.dart' as MyRoute;

class OrderHistoryPage extends StatefulWidget {
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<HistoryItem> myRoutes = [
    // MyRoute.Route(
    //     fromRoute: "Masr-Gedida",
    //     toRoute: "Abassia-Gate_3",
    //     price: 30,
    //     rating: 3,
    //     id: '',
    //     userId: ''),
    // MyRoute.Route(
    //     fromRoute: "Zamalek", toRoute: "Abassia-Gate_4", price: 20, rating: 4),
    // MyRoute.Route(
    //     fromRoute: "Mohandessin",
    //     toRoute: "Abassia-Gate_3",
    //     price: 20,
    //     rating: 5),
    // MyRoute.Route(
    //     fromRoute: "Abassia-Gate_4",
    //     toRoute: "Mohandessin",
    //     price: 30,
    //     rating: 1),
    // MyRoute.Route(
    //     fromRoute: "Abassia-Gate_3",
    //     toRoute: "Masr-Gedida",
    //     price: 30,
    //     rating: 3),
  ];
  // Replace this with your actual order data model
  @override
  void initState() {
    super.initState();
    initializeDb();
  }

  initializeDb() async {
    final dbHelper = DBHelperHistory();

    await dbHelper.initDatabase();

    myRoutes = await dbHelper.getHistoryItems();
    setState(() {});

    print(myRoutes.length);
    print(myRoutes[0].destination);
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
    return Scaffold(
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
                    "logout",
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
        title: Center(
          child: Text(
            'History',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
        child: ListView.builder(
          itemCount: myRoutes.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(context, myRoutes[index]);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, HistoryItem order) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        title: Text('price : ${order.price}'),
        subtitle: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${order.source}'),
              Text('To: ${order.destination}'),
              RatingBar.builder(
                initialRating: 2,
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      );
                    case 1:
                      return Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.redAccent,
                      );
                    case 2:
                      return Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                    case 3:
                      return Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      );
                    case 4:
                      return Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                    default:
                      return Icon(
                        Icons.sentiment_neutral,
                        color: Colors.grey,
                      );
                  }
                },
                onRatingUpdate: (rating) {},
              )
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
