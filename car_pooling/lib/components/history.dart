import 'package:car_pooling/models/history.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelperHistory {
  late Database _database;

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'history_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE history(id INTEGER PRIMARY KEY, userId TEXT, source TEXT, destination TEXT, tripState TEXT, time TEXT, price INTEGER, driver TEXT)',
        );
      },
      version: 2,
    );
  }

  Future<void> insertHistoryItem(HistoryItem item) async {
    await _database.insert(
      'history',
      {
        'userId': item.userId,
        'source': item.source,
        'destination': item.destination,
        'tripState': item.tripState,
        'time': item.time,
        'price': item.price,
        'driver': item.driver,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryItem>> getHistoryItems() async {
    final List<Map<String, dynamic>> maps = await _database.query('history');
    return List.generate(maps.length, (i) {
      return HistoryItem(
        userId: maps[i]['userId'],
        source: maps[i]['source'],
        destination: maps[i]['destination'],
        tripState: maps[i]['tripState'],
        time: maps[i]['time'],
        price: maps[i]['price'],
        driver: maps[i]['driver'],
      );
    });
  }
}
