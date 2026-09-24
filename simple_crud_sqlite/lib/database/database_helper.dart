import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Data {
  final int? id;
  final String teks;
  Data({required this.id, required this.teks});

  // Fungsi untuk mengubah objek Data menjadi bentuk Map (pasangan key-value) agar bisa dibaca oleh sqflite saat Insert/Update
  Map<String, Object?> toMap() {
    return {
      'id': id, // Memasukkan nilai id ke key 'id'
      'teks': teks, // Memasukkan nilai teks ke key 'teks'
    };
  }

  // Konstruktor tambahan (Factory) untuk mengubah data dari format Map/Database kembali menjadi bentuk objek Data
  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(id: map['id'] as int?, teks: map['teks'] as String);
  }

  // Override fungsi toString agar saat objek dicetak/di-print ke console, bentuknya terbaca jelas
  @override
  String toString() => 'Data{id: $id, teks: $teks}';
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // Membuat database dengan nama 'data.db'
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('data.db');
    return _database!;
  }

  // Membuka database pada path, menentukan versi database, dan membuat tabel jika baru pertama kali dipasang
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            teks TEXT
          )
        ''');
      },
    );
  }

  // Fungsi CREATE (Menambah Data baru ke database dengan SQL Murni)
  Future<int> insertData(Data data) async {
    final db = await instance.database;
    // Menggunakan rawInsert dengan placeholder '?' untuk keamanan terhadap SQL Injection
    return await db.rawInsert('INSERT INTO data (teks) VALUES (?)', [
      data.teks,
    ]);
  }

  // Fungsi READ (Mengambil / Membaca Semua Data dari database dengan SQL Murni)
  Future<List<Data>> getData() async {
    final db = await instance.database;
    // Menggunakan rawQuery untuk SELECT semua data
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM data',
    );
    return result.map((json) => Data.fromMap(json)).toList();
  }

  // Fungsi UPDATE (Mengubah / Memperbarui Data berdasarkan ID dengan SQL Murni)
  Future<int> updateData(Data data) async {
    final db = await instance.database;
    // Menggunakan rawUpdate
    return await db.rawUpdate('UPDATE data SET teks = ? WHERE id = ?', [
      data.teks,
      data.id,
    ]);
  }

  // Fungsi DELETE (Menghapus Data dari database berdasarkan ID tertentu dengan SQL Murni)
  Future<int> deleteData(int id) async {
    final db = await instance.database;
    // Menggunakan rawDelete
    return await db.rawDelete('DELETE FROM data WHERE id = ?', [id]);
  }
}
