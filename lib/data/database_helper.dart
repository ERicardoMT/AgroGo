import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Si estamos en un sistema de escritorio (como tu computadora Windows), 
    // inicializamos FFI para que SQLite funcione correctamente
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'agrogo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla Users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        location TEXT NOT NULL,
        profileImage TEXT,
        favorites TEXT,  -- JSON list
        profile_picture TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // 2. Tabla Equipments
    await db.execute('''
      CREATE TABLE equipments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        pricePerDay REAL NOT NULL,
        pricePerWeek REAL NOT NULL,
        pricePerMonth REAL NOT NULL,
        rating REAL NOT NULL,
        reviewCount INTEGER NOT NULL,
        available INTEGER NOT NULL,
        ownerId TEXT NOT NULL,
        ownerName TEXT NOT NULL,
        images TEXT,
        specs TEXT
      )
    ''');

    // 3. Tabla Bookings
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        equipmentId TEXT NOT NULL,
        equipmentName TEXT NOT NULL,
        equipmentCategory TEXT NOT NULL,
        userId TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        totalPrice REAL NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 4. Tabla BankAccounts
    await db.execute('''
      CREATE TABLE bank_accounts (
        id TEXT PRIMARY KEY,
        accountHolder TEXT NOT NULL,
        bankName TEXT NOT NULL,
        accountNumber TEXT NOT NULL,
        accountType TEXT NOT NULL,
        swiftCode TEXT,
        iban TEXT,
        isDefault INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        documentUrl TEXT
      )
    ''');

    // 5. Tabla Categories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        count INTEGER NOT NULL
      )
    ''');

    // 6. Tabla ChatMessages
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        senderName TEXT NOT NULL,
        senderRole TEXT NOT NULL,
        message TEXT NOT NULL,
        sentAt TEXT NOT NULL,
        isRead INTEGER NOT NULL,
        imageUrl TEXT
      )
    ''');

    // 7. Tabla Implements
    await db.execute('''
      CREATE TABLE implements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        width REAL,
        condition TEXT
      )
    ''');

    // 8. Tabla LandlordAlerts
    await db.execute('''
      CREATE TABLE landlord_alerts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL,
        equipmentId TEXT,
        rentalId TEXT
      )
    ''');

    // 9. Tabla LandlordEquipments
    await db.execute('''
      CREATE TABLE landlord_equipments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        power REAL NOT NULL,
        transmission TEXT NOT NULL,
        traction TEXT NOT NULL,
        usageHours REAL NOT NULL,
        isActive INTEGER NOT NULL,
        imageUrls TEXT,
        condition TEXT,
        implements TEXT,
        dailyRate REAL,
        createdAt TEXT NOT NULL,
        lastMaintenanceDate TEXT
      )
    ''');

    // 10. Tabla RentalOccupancies
    await db.execute('''
      CREATE TABLE rental_occupancies (
        id TEXT PRIMARY KEY,
        equipmentId TEXT NOT NULL,
        equipmentName TEXT NOT NULL,
        renterName TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        status TEXT NOT NULL,
        rentalCost REAL,
        location TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    // 11. Tabla RentalRequests
    await db.execute('''
      CREATE TABLE rental_requests (
        id TEXT PRIMARY KEY,
        rentalId TEXT NOT NULL,
        equipmentName TEXT NOT NULL,
        renterName TEXT NOT NULL,
        renterPhone TEXT NOT NULL,
        renterLocation TEXT NOT NULL,
        requestDate TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        status TEXT NOT NULL,
        dailyRate REAL NOT NULL,
        notes TEXT
      )
    ''');

    // 12. Tabla Reviews
    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        rentalId TEXT NOT NULL,
        reviewerName TEXT NOT NULL,
        reviewerRole TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        categories TEXT -- JSON list
      )
    ''');

    // 13. Tabla Transactions
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        rentalId TEXT NOT NULL,
        equipmentName TEXT NOT NULL,
        renterName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        appCommission REAL NOT NULL,
        netProfit REAL NOT NULL,
        transactionDate TEXT NOT NULL,
        completedDate TEXT,
        status TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  // --- MÉTODOS CRUD GENÉRICOS ---
  
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS DE AUTENTICACIÓN ---
  
  Future<bool> registerUser(Map<String, dynamic> userMap) async {
    final db = await database;
    try {
      await db.insert('users', userMap);
      return true; 
    } catch (e) {
      return false; 
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password, String role) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ? AND role = ?',
      whereArgs: [email, password, role],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null; 
  }

  Future<void> printTableData(String table) async {
    final db = await database;
    final List<Map<String, dynamic>> data = await db.query(table);
    
    print('--- DATOS EN LA TABLA $table ---');
    if (data.isEmpty) {
      print('La tabla está vacía.');
    } else {
      for (var row in data) {
        print(row);
      }
    }
    print('-----------------------------------');
  }

  // ==========================================
  // --- NUEVOS MÉTODOS PARA EL PERFIL ---
  // ==========================================

  // 1. Guardar la ruta de la foto (o avatar) en SQLite
  Future<bool> updateProfilePicture(String email, String imagePath) async {
    final db = await database;
    int result = await db.update(
      'users',
      {'profile_picture': imagePath},
      where: 'email = ?',
      whereArgs: [email],
    );
    return result > 0;
  }

  // 2. Contar las reservas reales del usuario en SQLite
  Future<int> getUserBookingsCount() async {
    final db = await database;
    // Cuenta cuántos registros hay en la tabla de bookings
    final result = await db.rawQuery('SELECT COUNT(*) FROM bookings');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  // 3. Obtener el promedio de calificación
  Future<double> getUserAverageRating() async {
    final db = await database;
    // Buscamos el promedio en la tabla 'reviews'
    final result = await db.rawQuery('SELECT AVG(rating) as avgRating FROM reviews');
    if (result.isNotEmpty && result.first['avgRating'] != null) {
      return (result.first['avgRating'] as num).toDouble();
    }
    return 0.0; // Si no hay reseñas, devuelve 0.0
  }
}