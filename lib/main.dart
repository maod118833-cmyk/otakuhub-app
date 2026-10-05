import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.amber,
        ),
      ),
      home: const AnimeSearchScreen(),
    );
  }
}

class AnimeSearchScreen extends StatefulWidget {
  const AnimeSearchScreen({super.key});

  @override
  State<AnimeSearchScreen> createState() => _AnimeSearchScreenState();
}

class _AnimeSearchScreenState extends State<AnimeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _animeList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTopAnime();
  }

  Future<void> _fetchTopAnime() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/top/anime?limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _animeList = data['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = 'فشل في تحميل الأنميات الأكثر شعبية.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال بالشبكة.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchAnime(String query) async {
    if (query.trim().isEmpty) {
      _fetchTopAnime();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/anime?q=$query&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _animeList = data['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = 'لم نتمكن من إيجاد نتائج.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء البحث.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌸 OtakuHub - عالم الأنمي'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن أنمي (مثال: Naruto, Attack on Titan)...',
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchTopAnime();
                  },
                ),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _searchAnime,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        )
                      : _animeList.isEmpty
                          ? const Center(child: Text('لا توجد نتائج للعرض'))
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _animeList.length,
                              itemBuilder: (context, index) {
                                final anime = _animeList[index];
                                final title = anime['title'] ?? 'بدون عنوان';
                                final imageUrl = anime['images']?['jpg']
                                        ?['image_url'] ??
                                    '';
                                final score = anime['score']?.toString() ?? 'N/A';

                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey[800],
                                                child: const Icon(Icons.movie),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  score,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
