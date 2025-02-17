import 'package:postgres/postgres.dart';

class Database {
  PostgreSQLConnection? connection;

  final String localhost = 'localhost';
  final int port = 5434;
  final String databaseName = 'crudapp';
  final String username = 'postgres';
  final String password = 'andubadao123';

  Future<void> getConnection() async {
    if (connection == null || connection!.isClosed) {
      connection = PostgreSQLConnection(
        'localhost',
        port,
        'crudapp',
        username: 'postgres',
        password: 'andubadao123',
      );
      await connection!.open();
    }
  }

  Future<List<List<dynamic>>> executeQuery(String query,
      {Map<String, dynamic>? substitutionValues}) async {
    await getConnection(); // Đảm bảo kết nối luôn mở trước khi thực hiện truy vấn
    return await connection!
        .query(query, substitutionValues: substitutionValues);
  }
}
