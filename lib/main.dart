import 'package:flutter/material.dart';
import 'api_service.dart';

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
  late Future<List<dynamic>> _serversFuture;

  // تحديد أنمي وحلقة تجريبية
  final String _animeName = 'one-piece';
  final String _episodeNum = '1';

  @override
  void initState() {
    super.initState();
    _loadEpisodeData();
  }

  void _loadEpisodeData() {
    _serversFuture = ApiService.fetchEpisodeServers(
      anime: _animeName,
      episode: _episodeNum,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أنمي: $_animeName - حلقة $_episodeNum'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _serversFuture,
        builder: (context, snapshot) {
          // 1. حالة جاري التحميل ⏳
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text('جاري جلب السيرفرات من Render... 🚀'),
                ],
              ),
            );
          }

          // 2. حالة حدوث خطأ ❌
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadEpisodeData();
                        });
                      },
                      child: const Text('إعادة المحاولة 🔄'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. حالة نجاح الاستجابة وجودة البيانات 📲
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final servers = snapshot.data!;
            return ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.play_circle_fill, color: Colors.green, size: 36),
                    title: Text(server['name'] ?? 'سيرفر تشغيل'),
                    subtitle: Text('الجودة: ${server['quality'] ?? 'تلقائية'}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // إشعار مؤقت عند الضغط لرؤية رابط السيرفر
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم إيجاد الرابط: ${server['url']}'),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text('لم يتم العثور على سيرفرات لهذه الحلقة.'),
          );
        },
      ),
    );
  }
}
