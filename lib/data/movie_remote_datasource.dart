import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/movie.dart';

class MovieRemoteDataSource {
  static const String _apiKey = '3cfe1c57d923410a239ea548e1aebc5a';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String _defaultPoster = 'https://via.placeholder.com/300x450?text=No+Image';

  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final url = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=ar&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movie) => Movie(
        id: movie['id'],
        title: movie['title'] ?? '',
        genre: '', // سيتم جلب النوع لاحقاً إذا لزم
        rating: (movie['vote_average'] as num?)?.round() ?? 0,
        description: movie['overview'] ?? '',
        posterPath: movie['poster_path'] != null ? '$_imageBaseUrl${movie['poster_path']}' : _defaultPoster,
        releaseDate: movie['release_date'],
        isLocal: false,
      )).toList();
    } else {
      throw Exception('فشل في جلب الأفلام الشهيرة');
    }
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final url = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&language=ar&query=$query&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movie) => Movie(
        id: movie['id'],
        title: movie['title'] ?? '',
        genre: '',
        rating: (movie['vote_average'] as num?)?.round() ?? 0,
        description: movie['overview'] ?? '',
        posterPath: movie['poster_path'] != null ? '$_imageBaseUrl${movie['poster_path']}' : _defaultPoster,
        releaseDate: movie['release_date'],
        isLocal: false,
      )).toList();
    } else {
      throw Exception('فشل في البحث عن الأفلام');
    }
  }
}