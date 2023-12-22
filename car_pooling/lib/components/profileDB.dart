import 'package:car_pooling/models/profile.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProfileDBHelper {
  late Database _database;

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'profile_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE profiles(email TEXT PRIMARY KEY, address TEXT, phone TEXT, password TEXT, image TEXT)',
        );
      },
      version: 2,
    );
  }

  Future<void> insertOrUpdateProfile(ProfileModel profile) async {
    await _database.insert(
      'profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProfileModel>> getProfiles() async {
    final List<Map<String, dynamic>> maps = await _database.query('profiles');
    return List.generate(maps.length, (i) {
      return ProfileModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteProfile(String email) async {
    await _database.delete(
      'profiles',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<ProfileModel?> getProfileByEmail(String email) async {
    List<Map<String, dynamic>> maps = await _database.query(
      'profiles',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) {
      return null; // No profile found for the given email
    }

    return ProfileModel.fromMap(maps.first);
  }
}
