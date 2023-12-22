import 'package:car_pooling/components/profileDB.dart';
import 'package:car_pooling/models/profile.dart';
import 'package:car_pooling/modules/avalaible.dart';
import 'package:car_pooling/modules/history.dart';
import 'package:car_pooling/modules/homepage.dart';
import 'package:car_pooling/modules/profile.dart';
import 'package:car_pooling/modules/visamethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        backgroundColor: Colors.black87,
        title: Center(
          child: Text(
            'Payment ',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildCashPaymentPage(),
          _buildVisaPaymentPage(),
        ],
      ),
    );
  }

  Widget _buildCashPaymentPage() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 20),
          Text(
            'Pay with Cash',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement cash payment logic
              _navigateToConfirmation('Cash');
            },
            child: Text('Pay with Cash'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaPaymentPage() {
    return VisaPaymentPage();
  }

  void _navigateToConfirmation(String method) async {
    // Navigate to the payment confirmation page
    // final FirebaseAuth _auth = FirebaseAuth.instance;
    // User? user = _auth.currentUser;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString("driverUserId") ?? "No Id Found";
    CollectionReference users = FirebaseFirestore.instance.collection('trips');
// if (u)
    DocumentSnapshot userDoc = await users.doc(user).get();
    Map<String, dynamic> userData;

    // User document found, you can access its data
    userData = userDoc.data() as Map<String, dynamic>;

    if (userData['tripState'].toString().contains("approvedByDriver") ||
        userData['tripState'].toString().contains("OnGoing")) {
      await users
          .doc(user)
          .update({'tripState': 'finished'})
          .then((value) => print(
              "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"))
          .catchError((error) => print("Failed to update trip: $error"));
      //  }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationPage(
            paymentMethod: method,
            cardNumber: '',
            expiryDate: '',
          ),
        ),
      );
    }
    //Future<void> updateUser() async {
  }
}

class PaymentConfirmationPage extends StatelessWidget {
  final String paymentMethod;

  const PaymentConfirmationPage(
      {Key? key,
      required this.paymentMethod,
      required String cardNumber,
      required String expiryDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              paymentMethod == 'Cash' ? Icons.attach_money : Icons.credit_card,
              size: 100,
              color: paymentMethod == 'Cash' ? Colors.green : Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Payment Confirmed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Payment Method: $paymentMethod',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
