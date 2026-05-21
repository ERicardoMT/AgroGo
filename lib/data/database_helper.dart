import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/chat_message.dart';
import '../models/message_notification.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    // Optimización local: evita abrir SQLite varias veces en una misma sesión.
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'agrogo_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
        favorites TEXT,
        profile_picture TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        count INTEGER NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        rentalId TEXT NOT NULL,
        reviewerName TEXT NOT NULL,
        reviewerRole TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        categories TEXT
      )
    ''');

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

    await _createRentalTrackingTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createRentalTrackingTable(db);
    }
  }

  Future<void> _createRentalTrackingTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rental_tracking (
        id TEXT PRIMARY KEY,
        bookingId TEXT NOT NULL UNIQUE,
        equipmentId TEXT NOT NULL,
        currentStep INTEGER NOT NULL,
        driverName TEXT NOT NULL,
        driverPhone TEXT NOT NULL,
        originAddress TEXT NOT NULL,
        destinationAddress TEXT NOT NULL,
        currentLatitude REAL NOT NULL,
        currentLongitude REAL NOT NULL,
        progress REAL NOT NULL,
        etaMinutes INTEGER NOT NULL,
        isMoving INTEGER NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<bool> registerUser(Map<String, dynamic> userMap) async {
    final db = await database;

    try {
      await db.insert('users', userMap);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
    String role,
  ) async {
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

  Future<int> getUserBookingsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM bookings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getUserAverageRating() async {
    final db = await database;
    final result = await db.rawQuery('SELECT AVG(rating) as avgRating FROM reviews');

    if (result.isNotEmpty && result.first['avgRating'] != null) {
      return (result.first['avgRating'] as num).toDouble();
    }

    return 0.0;
  }

  Future<int> getLandlordTractorsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM landlord_equipments');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getLandlordRentalsCount() async {
    final db = await database;

    final occupancyCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM rental_occupancies'),
        ) ??
        0;

    if (occupancyCount > 0) return occupancyCount;

    final approvedCount = Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM rental_requests WHERE status = 'approved'",
          ),
        ) ??
        0;

    if (approvedCount > 0) return approvedCount;

    return Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM rental_requests WHERE status != 'rejected'",
          ),
        ) ??
        0;
  }

  Future<double> getLandlordTotalIncome() async {
    final db = await database;

    final txResult = await db.rawQuery(
      "SELECT COALESCE(SUM(netProfit), 0) as total FROM transactions WHERE status = 'completed'",
    );

    final txTotal = (txResult.first['total'] as num?)?.toDouble() ?? 0.0;

    if (txTotal > 0) return txTotal;

    final occResult = await db.rawQuery(
      'SELECT COALESCE(SUM(rentalCost), 0) as total FROM rental_occupancies',
    );

    return (occResult.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getLandlordReviewsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM reviews');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> updateUserByEmail(
    String currentEmail,
    Map<String, dynamic> updates,
  ) async {
    final db = await database;

    final result = await db.update(
      'users',
      updates,
      where: 'email = ?',
      whereArgs: [currentEmail],
    );

    return result > 0;
  }

  Future<List<MessageNotificationSummary>> getMessageNotificationSummaries(
    String currentRole,
  ) async {
    final db = await database;
    final rows = await db.query('chat_messages', orderBy: 'sentAt ASC');
    final Map<String, List<ChatMessage>> grouped = {};

    for (final row in rows) {
      final msg = ChatMessage.fromJson(row);
      grouped.putIfAbsent(msg.conversationId, () => []).add(msg);
    }

    final summaries = <MessageNotificationSummary>[];

    grouped.forEach((convId, msgs) {
      final fromOthers = msgs.where((m) => m.senderRole != currentRole).toList();

      if (fromOthers.isEmpty) return;

      fromOthers.sort((a, b) => b.sentAt.compareTo(a.sentAt));

      final latest = fromOthers.first;
      final unread = fromOthers.where((m) => !m.isRead).length;
      final parts = convId.split('_');

      final equipmentName = parts.length > 1
          ? parts.sublist(1).join('_')
          : 'Equipo';

      summaries.add(
        MessageNotificationSummary(
          conversationId: convId,
          senderName: latest.senderName,
          senderRole: latest.senderRole,
          message: latest.message,
          sentAt: latest.sentAt,
          equipmentName: equipmentName,
          unreadCount: unread,
        ),
      );
    });

    summaries.sort((a, b) => b.sentAt.compareTo(a.sentAt));

    return summaries;
  }

  Future<void> markConversationMessagesAsRead(
    String conversationId,
    String currentRole,
  ) async {
    final db = await database;

    await db.update(
      'chat_messages',
      {'isRead': 1},
      where: 'conversationId = ? AND senderRole != ?',
      whereArgs: [conversationId, currentRole],
    );
  }

  Future<bool> isEmailRegistered(String email, {String? excludeEmail}) async {
    final db = await database;
    final normalized = email.trim().toLowerCase();

    final result = await db.query(
      'users',
      where: excludeEmail == null
          ? 'email = ?'
          : 'email = ? AND email != ?',
      whereArgs: excludeEmail == null
          ? [normalized]
          : [normalized, excludeEmail.trim().toLowerCase()],
    );

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getRentalTrackingByBooking(
    String bookingId,
  ) async {
    final db = await database;

    final rows = await db.query(
      'rental_tracking',
      where: 'bookingId = ?',
      whereArgs: [bookingId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return rows.first;
  }

  Future<void> createTrackingIfMissing({
    required String bookingId,
    required String equipmentId,
    required String destinationAddress,
  }) async {
    final db = await database;

    final existing = await getRentalTrackingByBooking(bookingId);
    if (existing != null) return;

    await db.insert(
      'rental_tracking',
      {
        'id': 'tracking_$bookingId',
        'bookingId': bookingId,
        'equipmentId': equipmentId,
        'currentStep': 0,
        'driverName': 'Operador AgroGo',
        'driverPhone': '+52 55 1234 5678',
        'originAddress': 'Patio de maquinaria AgroGo',
        'destinationAddress': destinationAddress,
        'currentLatitude': 19.3900,
        'currentLongitude': -99.1200,
        'progress': 0.0,
        'etaMinutes': 45,
        'isMoving': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> startTrackingMovement(String bookingId) async {
    final db = await database;

    await db.update(
      'rental_tracking',
      {
        'currentStep': 1,
        'progress': 0.25,
        'etaMinutes': 30,
        'isMoving': 1,
        'currentLatitude': 19.3950,
        'currentLongitude': -99.1300,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'bookingId = ?',
      whereArgs: [bookingId],
    );

    await db.update(
      'bookings',
      {'status': 'active'},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  Future<void> advanceTrackingStep(String bookingId) async {
    final db = await database;
    final current = await getRentalTrackingByBooking(bookingId);

    if (current == null) return;

    final currentStep = current['currentStep'] as int;
    final nextStep = currentStep >= 4 ? 4 : currentStep + 1;

    // Optimización de ciclos: se evita un switch largo usando mapas constantes por paso.
    final progressByStep = <int, double>{
      0: 0.0,
      1: 0.25,
      2: 0.62,
      3: 0.9,
      4: 1.0,
    };

    final etaByStep = <int, int>{
      0: 45,
      1: 30,
      2: 15,
      3: 5,
      4: 0,
    };

    final latByStep = <int, double>{
      0: 19.3900,
      1: 19.3950,
      2: 19.4020,
      3: 19.4100,
      4: 19.4150,
    };

    final lngByStep = <int, double>{
      0: -99.1200,
      1: -99.1300,
      2: -99.1380,
      3: -99.1450,
      4: -99.1500,
    };

    await db.update(
      'rental_tracking',
      {
        'currentStep': nextStep,
        'progress': progressByStep[nextStep],
        'etaMinutes': etaByStep[nextStep],
        'currentLatitude': latByStep[nextStep],
        'currentLongitude': lngByStep[nextStep],
        'isMoving': nextStep >= 1 && nextStep < 4 ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'bookingId = ?',
      whereArgs: [bookingId],
    );

    if (nextStep == 4) {
      await db.update(
        'bookings',
        {'status': 'completed'},
        where: 'id = ?',
        whereArgs: [bookingId],
      );
    }
  }

  Future<void> resetTrackingSimulation(String bookingId) async {
    final db = await database;

    await db.update(
      'rental_tracking',
      {
        'currentStep': 0,
        'progress': 0.0,
        'etaMinutes': 45,
        'isMoving': 0,
        'currentLatitude': 19.3900,
        'currentLongitude': -99.1200,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'bookingId = ?',
      whereArgs: [bookingId],
    );

    await db.update(
      'bookings',
      {'status': 'confirmed'},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }
}