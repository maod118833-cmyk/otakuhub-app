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
  bool isLoading = false;
  Map<String, dynamic>? episodeData;
  String? errorMessage;

  final TextEditingController animeController = TextEditingController(text: 'one-piece');
  final TextEditingController episodeController = TextEditingController(text: '1');

  Future<void> loadEpisode() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final data = await ApiService.fetchServers(
      anime: animeController.text.trim(),
      episode: episodeController.text.trim(),
    );

    setState(() {
      isLoading = false;
      if (data != null) {
        episodeData = data;
      } else {
        errorMessage = 'فشل في جلب البيانات، تأكد من اسم الأنمي أو رقم الحلقة.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OtakuHub 🍿'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: animeController,
              decoration: const InputDecoration(
                labelText: 'اسم الأنمي (مثل: one-piece)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: episodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم الحلقة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: isLoading ? null : loadEpisode,
              child: const Text('جلب السيرفرات 🚀'),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red))
            else if (episodeData != null)
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'النتائج:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      episodeData.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              const Text('أدخل التفاصيل واضغط على الزر لبدء الجلب.'),
          ],
        ),
      ),
    );
  }
}
