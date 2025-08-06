import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'movie_provider.dart';
import '../domain/movie.dart';
import 'add_movie_page.dart';
import 'movie_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _lastQuery = '';
  final List<String> genres = [
    'دراما', 'أكشن', 'كوميديا', 'رعب', 'خيال علمي', 'رومانسي', 'أنيميشن', 'وثائقي', 'عائلي', 'مغامرة', 'جريمة', 'غموض', 'تاريخي', 'حرب', 'موسيقى', 'غربي'
  ];
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MovieProvider>(context, listen: false);
    provider.fetchPopularMovies();
    provider.fetchFavoriteMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة أفلامي'),
        centerTitle: true,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchPopularMovies();
              await provider.fetchFavoriteMovies();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // شريط البحث
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'ابحث عن فيلم في TMDb',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchResults.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (query) {
                    if (query.trim().isNotEmpty && query != _lastQuery) {
                      provider.searchMovies(query.trim());
                      _lastQuery = query;
                    }
                  },
                ),
                const SizedBox(height: 16),
                // نتائج البحث
                if (provider.isLoadingSearch)
                  const Center(child: CircularProgressIndicator()),
                if (!provider.isLoadingSearch && provider.searchResults.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نتائج البحث', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.searchResults.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final movie = provider.searchResults[index];
                            return _MovieCard(movie: movie);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                // قسم الأفلام الشهيرة
                Text('الأفلام الشهيرة الآن', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: provider.isLoadingPopular
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.popularMovies.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final movie = provider.popularMovies[index];
                            return _MovieCard(movie: movie);
                          },
                        ),
                ),
                const SizedBox(height: 24),
                // قسم المفضلة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('أفلامي المفضلة', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'تصفية',
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) {
                            String? selectedGenre = Provider.of<MovieProvider>(context, listen: false).filterGenre;
                            int? selectedRating = Provider.of<MovieProvider>(context, listen: false).filterRating;
                            return StatefulBuilder(
                              builder: (context, setModalState) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('تصفية المفضلة', style: Theme.of(context).textTheme.titleLarge),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        value: selectedGenre,
                                        decoration: const InputDecoration(
                                          labelText: 'النوع',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: [const DropdownMenuItem(value: null, child: Text('الكل'))] +
                                            genres.map((genre) => DropdownMenuItem(
                                              value: genre,
                                              child: Text(genre),
                                            )).toList(),
                                        onChanged: (value) => setModalState(() => selectedGenre = value),
                                      ),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<int>(
                                        value: selectedRating,
                                        decoration: const InputDecoration(
                                          labelText: 'التقييم',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: [const DropdownMenuItem(value: null, child: Text('الكل'))] +
                                            List.generate(10, (i) => i + 1).map((rate) => DropdownMenuItem(
                                              value: rate,
                                              child: Text(rate.toString()),
                                            )).toList(),
                                        onChanged: (value) => setModalState(() => selectedRating = value),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Provider.of<MovieProvider>(context, listen: false).setGenreFilter(selectedGenre);
                                                Provider.of<MovieProvider>(context, listen: false).setRatingFilter(selectedRating);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('تطبيق'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Provider.of<MovieProvider>(context, listen: false).setGenreFilter(null);
                                                Provider.of<MovieProvider>(context, listen: false).setRatingFilter(null);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('إزالة الفلاتر'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                provider.isLoadingFavorites
                    ? const Center(child: CircularProgressIndicator())
                    : provider.filteredFavorites.isEmpty
                        ? const Center(child: Text('لا توجد أفلام مفضلة بعد.'))
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.filteredFavorites.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final movie = provider.filteredFavorites[index];
                              return _FavoriteMovieTile(movie: movie);
                            },
                          ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddMoviePage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'إضافة فيلم جديد',
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(movie: movie, canAddToFavorites: true),
          ),
        );
      },
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                movie.posterPath ?? '',
                height: 170,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 170,
                  width: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteMovieTile extends StatelessWidget {
  final Movie movie;
  const _FavoriteMovieTile({required this.movie});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          movie.posterPath ?? '',
          height: 50,
          width: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 50,
            width: 40,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 24),
          ),
        ),
      ),
      title: Text(movie.title),
      subtitle: Text('التقييم: ${movie.rating}/10'),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(movie: movie),
          ),
        );
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'حذف',
        onPressed: () {
          Provider.of<MovieProvider>(context, listen: false).deleteFavorite(movie.id!);
        },
      ),
    );
  }
}