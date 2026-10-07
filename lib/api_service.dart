import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const OtakuHubApp());
}

class OtakuHubApp extends StatelessWidget {
  const OtakuHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtakuHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchData();
  }

  // دالة جلب البيانات مع رابط Render الخاص بك ومعالجة الأخطاء
  Future<List<dynamic>> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://anime-17dj.onrender.com/'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else {
          return [data];
        }
      } else {
        throw Exception(
            'HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('فشل الاتصال بالسيرفر:\n$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OtakuHub'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          // 1. حالة الانتظار (دائرة التحميل)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. حالة حدوث خطأ (عرض رسالة الخطأ)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'حدث خطأ أثناء تحميل البيانات:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dataFuture = fetchData();
                        });
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. حالة نجاح جلب البيانات
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  title: Text(item['title'] ?? 'بدون عنوان'),
                  subtitle: Text(item.toString()),
                );
              },
            );
          }

          return const Center(
            child: Text('لا توجد بيانات للعرض'),
          );
        },
      ),
    );
  }
}
