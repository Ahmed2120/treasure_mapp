import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:treasure_mapp/place.dart';

class DbHelper {

  static final DbHelper _dbHelper = DbHelper._internal();
  DbHelper._internal();
  factory DbHelper(){
    return _dbHelper;
  }


  final int version = 1;
  late Database db;

  Future<Database> openDb() async {
    db = await openDatabase(join(await getDatabasesPath(), 'mapp.db'),
        onCreate: (database, version) {
      database.execute(
          'CREATE TABLE places (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lat DOUBLE, lon DOUBLE, image TEXT)');
    }, version: version);
    return db;
  }

  Future insertData() async {
    db = await openDb();
    await db.execute(
        'INSERT INTO places VALUES(1, "Beautiful park", 41.9294115, 12.5380785, "")');
    await db.execute(
        'INSERT INTO places VALUES(2, "Best pizza in the world", 41.9294115, 12.5268947, "")');
    await db.execute(
        'INSERT INTO places VALUES(3, "The Best icecream on the world", 41.9344115, 12.5339831, "")');
    await db.execute(
        'INSERT INTO places VALUES(3, "The Best icecream on the world", 42.9344115, 13.5339831, "")');
  }

  List<Place> places = [];

  Future<List<Place>> getPlaces() async {
    final List<Map<String, dynamic>> maps = await db.query('places');
    places = List.generate(maps.length, (index) {
      print('places id: ${maps[index]}');
      return Place.fromJson(
        maps[index]
      );
    });
    for(var i =0; i<places.length; i++){
      print('places----------------${places[i].id}:');}
    return places;
  }

  Future insertPlace(Place place) async {
    int id = await db.insert('places', place.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future update(Place place) async{
    await db.update('places', place.toMap(), where: 'id = ?', whereArgs: [place.id]);
  }

  Future deletePlace(Place place) async {
    int id = await db.delete('places', where: "id = ?", whereArgs: [place.id],
        );
    return id;
  }
}
