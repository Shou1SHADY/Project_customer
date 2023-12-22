import 'dart:async';
import 'package:car_pooling/models/routes.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  late Database _database;

  // Open the database
  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'routes_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE routes(id TEXT PRIMARY KEY, userId TEXT, fromRoute TEXT, toRoute TEXT, price INTEGER, rating INTEGER, departureDate TEXT, tripState TEXT)',
        );
      },
      version: 4,
    );
  }

  // Insert or update a route in the database
  Future<void> insertOrUpdateRoute(Route route) async {
    print("${route.fromRoute} " + "111111111111111111");
    await _database.insert(
      'routes',
      route.toFirestoreMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all routes from the database
  Future<List<Route>> getRoutes() async {
    final List<Map<String, dynamic>> maps = await _database.query('routes');
    return List.generate(maps.length, (i) {
      return Route.fromFirestore(maps[i]);
    });
  }

  // Delete a route from the database
  Future<void> deleteRoute(String id) async {
    await _database.delete(
      'routes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
