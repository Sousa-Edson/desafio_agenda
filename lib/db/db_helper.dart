import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pessoa.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'agenda.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pessoa(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            telefone TEXT,
            fotoPath TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertPessoa(Pessoa pessoa) async {
    final dbClient = await db;
    return await dbClient.insert('pessoa', pessoa.toMap());
  }

  Future<List<Pessoa>> getPessoas({String? filtro}) async {
    final dbClient = await db;
    String whereClause = '';
    List<dynamic> args = [];
    if (filtro != null && filtro.isNotEmpty) {
      whereClause = 'WHERE nome LIKE ?';
      args = ['%$filtro%'];
    }
    final maps = await dbClient.rawQuery(
      'SELECT * FROM pessoa $whereClause',
      args,
    );
    return maps.map((e) => Pessoa.fromMap(e)).toList();
  }

  Future<int> updatePessoa(Pessoa pessoa) async {
    final dbClient = await db;
    return await dbClient.update(
      'pessoa',
      pessoa.toMap(),
      where: 'id = ?',
      whereArgs: [pessoa.id],
    );
  }

  Future<int> deletePessoa(int id) async {
    final dbClient = await db;
    return await dbClient.delete('pessoa', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countPessoas() async {
    final dbClient = await db;
    final x = await dbClient.rawQuery('SELECT COUNT(*) FROM pessoa');
    return Sqflite.firstIntValue(x) ?? 0;
  }
}
