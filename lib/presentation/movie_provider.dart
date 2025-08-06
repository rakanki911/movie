import 'package:flutter/material.dart';
import '../domain/movie.dart';
import '../data/movie_local_datasource.dart';
import '../data/movie_remote_datasource.dart';

class MovieProvider extends ChangeNotifier {
  final MovieLocalDataSource _localDataSource = MovieLocalDataSource();
  final MovieRemoteDataSource _remoteDataSource = MovieRemoteDataSource();

  List<Movie> popularMovies = [];
  List<Movie> favoriteMovies = [];
  List<Movie> filteredFavorites = [];
  List<Movie> searchResults = [];

  bool isLoadingPopular = false;
  bool isLoadingFavorites = false;
  bool isLoadingSearch = false;

  String? filterGenre;
  int? filterRating;

  Future<void> fetchPopularMovies() async {
    isLoadingPopular = true;
    notifyListeners();
    try {
      popularMovies = await _remoteDataSource.fetchPopularMovies();
    } catch (e) {
      popularMovies = [];
    }
    isLoadingPopular = false;
    notifyListeners();
  }

  Future<void> fetchFavoriteMovies() async {
    isLoadingFavorites = true;
    notifyListeners();
    favoriteMovies = await _localDataSource.getAllMovies();
    applyFilters();
    isLoadingFavorites = false;
    notifyListeners();
  }

  Future<void> addFavorite(Movie movie) async {
    await _localDataSource.addMovie(movie);
    await fetchFavoriteMovies();
  }

  Future<void> updateFavorite(Movie movie) async {
    await _localDataSource.updateMovie(movie);
    await fetchFavoriteMovies();
  }

  Future<void> deleteFavorite(int id) async {
    await _localDataSource.deleteMovie(id);
    await fetchFavoriteMovies();
  }

  Future<void> searchMovies(String query) async {
    isLoadingSearch = true;
    notifyListeners();
    try {
      searchResults = await _remoteDataSource.searchMovies(query);
    } catch (e) {
      searchResults = [];
    }
    isLoadingSearch = false;
    notifyListeners();
  }

  void applyFilters() {
    filteredFavorites = favoriteMovies.where((movie) {
      final matchesGenre = filterGenre == null || movie.genre == filterGenre;
      final matchesRating = filterRating == null || movie.rating == filterRating;
      return matchesGenre && matchesRating;
    }).toList();
    notifyListeners();
  }

  void setGenreFilter(String? genre) {
    filterGenre = genre;
    applyFilters();
  }

  void setRatingFilter(int? rating) {
    filterRating = rating;
    applyFilters();
  }
}