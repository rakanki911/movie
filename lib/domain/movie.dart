class Movie {
  final int? id;
  final String title;
  final String genre;
  final int rating;
  final String? description;
  final String? posterPath;
  final String? releaseDate;
  final bool isLocal;

  Movie({
    this.id,
    required this.title,
    required this.genre,
    required this.rating,
    this.description,
    this.posterPath,
    this.releaseDate,
    this.isLocal = false,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      genre: map['genre'],
      rating: map['rating'],
      description: map['description'],
      posterPath: map['posterPath'],
      releaseDate: map['releaseDate'],
      isLocal: map['isLocal'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'rating': rating,
      'description': description,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'isLocal': isLocal,
    };
  }
}