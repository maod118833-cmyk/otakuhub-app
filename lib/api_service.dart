import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // دالة لجلب سيرفرات الحلقة
  static Future<List<dynamic>> fetchEpisodeServers({
    required String anime,
    required String episode,
  }) async {
    // بناء الرابط مع الاستعلام المطلوب
    final url = Uri.parse(
      'https://anime-17dj.onrender.com/api/get-episode?anime=$anime&episode=$episode',
    );

    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 25), // إعطاء مهلة كافية للاستخراج
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // التاكد من وجود السيرفرات في الاستجابة
        if (data['success'] == true && data['servers'] != null) {
          return data['servers'];
        } else {
          return [];
        }
      } else {
        throw Exception('خطأ من السيرفر: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل الاتصال بالسيرفر: $e');
    }
  }
}
