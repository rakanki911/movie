import '../domain/movie.dart';
import 'local_database.dart';

class MovieLocalDataSource {
  final LocalDatabase db = LocalDatabase.instance;

  Future<int> addMovie(Movie movie) async {
    return await db.insertMovie(movie.toMap());
  }

  Future<List<Movie>> getAllMovies() async {
    final movies = await db.getAllMovies();
    return movies.map((e) => Movie.fromMap(e)).toList();
  }

  Future<int> updateMovie(Movie movie) async {
    if (movie.id == null) throw Exception('Movie id is null');
    return await db.updateMovie(movie.id!, movie.toMap());
  }

  Future<int> deleteMovie(int id) async {
    return await db.deleteMovie(id);
  }
}