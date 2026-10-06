import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://anime-17dj.onrender.com';

  static Future<Map<String, dynamic>?> fetchServers({
    required String anime,
    required String episode,
    String? targetUrl,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/api/get-episode').replace(
        queryParameters: {
          'anime': anime,
          'episode': episode,
          if (targetUrl != null && targetUrl.isNotEmpty) 'targetUrl': targetUrl,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchServers: $e');
      return null;
    }
  }
}
