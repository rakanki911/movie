import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/movie.dart';
import 'movie_provider.dart';

class MovieDetailsPage extends StatelessWidget {
  final Movie movie;
  final bool canAddToFavorites;
  const MovieDetailsPage({Key? key, required this.movie, this.canAddToFavorites = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                movie.posterPath ?? '',
                height: 300,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  width: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            movie.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty)
            Text(
              'تاريخ الإصدار: ${movie.releaseDate}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          if (movie.genre.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'النوع: ${movie.genre}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            movie.description?.isNotEmpty == true ? movie.description! : 'لا يوجد ملخص متوفر.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (canAddToFavorites)
            ElevatedButton.icon(
              onPressed: () async {
                await Provider.of<MovieProvider>(context, listen: false).addFavorite(movie);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إضافة الفيلم إلى المفضلة!')),
                );
              },
              icon: const Icon(Icons.favorite_border),
              label: const Text('أضف إلى قائمة المفضلة'),
            ),
        ],
      ),
    );
  }
}