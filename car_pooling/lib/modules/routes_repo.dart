import 'dart:async';
import 'package:car_pooling/components/dbHelper.dart';
import 'package:car_pooling/models/routes.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/routes.dart' as MyRoute;

class RoutesRepository {
  final DBHelper dbHelper;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RoutesRepository(this.dbHelper);

  Future<List<MyRoute.Route>> fetchAvailableRoutes() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, fetch routes from local database
      return dbHelper.getRoutes();
    } else {
      // Connected to the internet, fetch routes from Firestore
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('trips').get();

      List<MyRoute.Route> routes = snapshot.docs.map((doc) {
        return MyRoute.Route.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      // Update local database with fetched routes
      for (var route in routes) {
        await dbHelper.insertOrUpdateRoute(route);
      }

      return routes;
    }
  }
}
