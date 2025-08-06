import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/movie.dart';
import 'movie_provider.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({Key? key}) : super(key: key);

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedGenre;
  int _rating = 5;

  final List<String> genres = [
    'دراما', 'أكشن', 'كوميديا', 'رعب', 'خيال علمي', 'رومانسي', 'أنيميشن', 'وثائقي', 'عائلي', 'مغامرة', 'جريمة', 'غموض', 'تاريخي', 'حرب', 'موسيقى', 'غربي'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة فيلم جديد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفيلم',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال اسم الفيلم' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                decoration: const InputDecoration(
                  labelText: 'النوع',
                  border: OutlineInputBorder(),
                ),
                items: genres.map((genre) => DropdownMenuItem(
                  value: genre,
                  child: Text(genre),
                )).toList(),
                onChanged: (value) => setState(() => _selectedGenre = value),
                validator: (value) => value == null ? 'الرجاء اختيار النوع' : null,
              ),
              const SizedBox(height: 16),
              Text('التقييم الشخصي: $_rating', style: Theme.of(context).textTheme.bodyLarge),
              Slider(
                value: _rating.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _rating.toString(),
                onChanged: (value) => setState(() => _rating = value.round()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف الفيلم (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final movie = Movie(
                      title: _titleController.text,
                      genre: _selectedGenre!,
                      rating: _rating,
                      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                      isLocal: true,
                    );
                    await Provider.of<MovieProvider>(context, listen: false).addFavorite(movie);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}