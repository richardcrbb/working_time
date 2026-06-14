import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working_time/db/models.dart';
import 'package:working_time/db/notifiers.dart';

class MyDatabase {
  //!                       singleton --> unica conexion
  static Database? _database;
  //!                       getter  --> metodo en propiedad
  //esta funcion evalua si ya se abrio una conexion en el singleton,
  //si no, executa una conexion nueva y la pone en el singleton.
  static Future<Database> get database async{
    if (_database!=null) return _database!;
    _database = await _initDB();
    return _database!; 
  }

  //esto usa el paquete sqflite para ejecutar la funcion openDatabase
  //para usar esta funcion se necesita el path de la db, para ello se usa el paquete path.
  static Future<Database> _initDB()async{
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath,'working_hours.db');
    
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) {
        
      },
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE timesheet(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location TEXT,
          start TEXT,
          finish TEXT,
          duration REAL,
          isExtraTime INTEGER,
          pay REAL
          );'''

        );
        db.execute('''
          CREATE TABLE locationsTable(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location TEXT,
          regularPayment REAL,
          overtimePayment REAL
          )''');
        db.execute('''
          CREATE TABLE filterFrequency(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          frequency TEXT
          )''');
        db.insert(
          'filterFrequency',
          {'frequency':'Biweekly'},
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      },

    ); 
  }
  //!                       create

  static Future<int> insertLog (HoursLog log) async {
    final db = await MyDatabase.database;

    final id = await db.insert(
      'timesheet',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
      );
    return id;
  }


  //!                       read single

  static Future<HoursLog> readLog (int id) async {
    final db = await MyDatabase.database;

    final log = await db.query(
      'timesheet',
      where: 'id=?',
      whereArgs: [id]
      );
    return HoursLog.fromMap(log[0]);
  }

  //!                      read List

  static Future<List<HoursLog>> readLogList (int currentPage, int itemsPerPage) async{
    final db = await MyDatabase.database;

    List listado = await db.query(
      'timesheet',
      limit: itemsPerPage+1,
      offset: currentPage*itemsPerPage,
      orderBy: 'id DESC'
    );

    return listado.map((e) {
      final item = HoursLog.fromMap(e);
      return item;
    },).toList();
  }


  //!                       update

  static Future<int> updateLog (HoursLog log) async {
    final db = await MyDatabase.database;

    final id = await db.update(
      'timesheet',
      log.toMap(),
      where: 'id=?',
      whereArgs: [log.id],
      conflictAlgorithm: ConflictAlgorithm.replace
      );
    return id;
  }



  //!                       delete

  static Future<int> deleteLog (HoursLog log) async {
    final db = await MyDatabase.database;

    final id = await db.delete(
      'timesheet',
      where: 'id=?',
      whereArgs: [log.id],
      );
    return id;
  }
  


  //!                          Add New location
  static Future<int> addNewLocation (WorkLocation loc)async{
    final db = await MyDatabase.database;

    int id = await db.insert(
      'locationsTable',
      {'location':loc.location,
      'regularPayment':loc.regularPayment,
      'overtimePayment':loc.overtimePayment,},
    conflictAlgorithm: ConflictAlgorithm.replace
    );

    return id;
  }

  //!                        Edit old location 

  static Future<int> editOldLocation (WorkLocation oldLocation)async{
    final db = await MyDatabase.database;

    int id = await db.update(
      'locationsTable',
      oldLocation.toMap(),
      where: 'id=?',
      whereArgs: [oldLocation.id],
      conflictAlgorithm: ConflictAlgorithm.replace
      );
    return id;
  }

  //!                       Get Locations Table

  static Future<List<WorkLocation>> getLocationsTable()async{
    final db = await MyDatabase.database;

    final locations = await db.query('locationsTable',orderBy: 'location');
    
    return locations.map((e) {return WorkLocation.fromMap(e);}).toList();
  }

  //!                       get location availability

  static Future<bool> getLocationAvailability (String location)async{
    Database db = await MyDatabase.database;
    List availability = await db.query(
      'locationsTable',
      where: 'location=?',
      whereArgs: [location]
    );
    return availability.isEmpty? true : false;

  }

  //!                        Delete location

  static Future<int> deleteLocation(WorkLocation location)async{
    final db= await MyDatabase.database;

    int id = await db.delete(
      'locationsTable',
      where: 'id=?',
      whereArgs: [location.id]
    );
    return id;
  }

  //!                        Get filter frequency

  static Future<String> getFilterFrequency ()async{
    final db = await MyDatabase.database;  

    final freqList = await db.query(
      'filterFrequency',
      where: 'id=?',
      whereArgs: [1]);
    return freqList[0]['frequency']?.toString()?? '' ;

  }

  //!                        update filter frequency

  static Future<void> updateFilterFrequency (String filterFreq)async{
    final Database db = await MyDatabase.database;
    db.update(
      'filterFrequency',
      {'frequency':filterFreq},
      where: 'id=?', 
      whereArgs: [1],
      conflictAlgorithm: ConflictAlgorithm.replace
      );
  }

  //!                        get filtered registries

  static Future<List<Map<String,Object?>>> getFilteredRegistries (int offset) async {
    //filter
    final String filter = await MyDatabase.getFilterFrequency();
    
    //variables
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year,now.month,now.day);
    final DateTime firstOfMonth = today.subtract(Duration(days: today.day-1));//para que no me quede en 0
    final DateTime sixteen = firstOfMonth.add(Duration(days: 15));
    final DateTime lastOfMonth = DateTime(today.year,today.month+1,1);
    final DateTime monday = today.subtract(Duration(days: today.weekday-1));
    final DateTime sunday = monday.add(Duration(days: 7)); //actually is the other monday but! at 0:00, who cares!

    // Filter Parameters filterStartDay & filterEndDay are in notifiers.dart
    
    if(filter=='Weekly'){
      filterStartDay=monday.subtract(Duration(days: 7*offset));
      filterEndDay=sunday.subtract(Duration(days: 7*offset));
    }
    else if (filter == 'Biweekly'){
      if(offset%2==0){
        
        int offsetScope = (offset/2).toInt(); // calculate what offset ago should be applied.
        
        if(today.day<16){
          filterStartDay=DateTime(firstOfMonth.year,firstOfMonth.month-offsetScope,firstOfMonth.day);
          filterEndDay=DateTime(sixteen.year,sixteen.month-offsetScope,sixteen.day);
        }
        else {
          filterEndDay=DateTime(sixteen.year,sixteen.month-offsetScope,sixteen.day);
          filterStartDay=DateTime(lastOfMonth.year,lastOfMonth.month-offsetScope,lastOfMonth.day);
        }
      }
      else if (offset%2==1){

        int offsetScope2 = offset~/2+1; // first biweek goes back last month (use floor division)
        int offsetScope3 = offset~/2;    //second biweek remains in the same month (use floor division)
        if(today.day<16){
          filterStartDay=DateTime(sixteen.year,sixteen.month-offsetScope2,sixteen.day);
          filterEndDay=DateTime(lastOfMonth.year,lastOfMonth.month-offsetScope2,lastOfMonth.day);
        }
        else{
          filterStartDay=DateTime(firstOfMonth.year,firstOfMonth.month-offsetScope3,firstOfMonth.day);
          filterEndDay=DateTime(sixteen.year,sixteen.month-offsetScope3,sixteen.day);
        }

      }
    }
    else{
      filterStartDay=DateTime(firstOfMonth.year,firstOfMonth.month-offset,1);
      filterEndDay=DateTime(lastOfMonth.year,lastOfMonth.month-offset,1);
    }

    //consulta a base de datos

    final Database db = await MyDatabase.database;


    //<HoursLog>
    return await db.rawQuery('''
        SELECT location, SUM(pay) AS total_pay
        FROM timesheet
        WHERE start>=? AND start<?
        GROUP BY location;

      ''',[filterStartDay.toIso8601String(),filterEndDay.toIso8601String()]);
      //start BETWEEN ? AND ?

  }

  //!                           get the annual list of registries.
  static Future<List<Map<String,dynamic>>> getGroupedAnnualRegistries ()async{
    Database db = await MyDatabase.database;

    return db.rawQuery('''
      SELECT strftime('%Y%m', start) AS month, sum(pay) AS total_monthly_pay
      FROM timesheet
      WHERE start>=date('now', '-12 months')
      GROUP BY strftime('%Y%m', start)
      ORDER BY month DESC;
    ''');
  }




}




