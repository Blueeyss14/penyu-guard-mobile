import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKey {
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://127.0.0.1:3000';
  static String get realtimeUrl => '$baseUrl/api/data/realtime';
  static String get weeklyUrl => '$baseUrl/api/history/weekly';
}