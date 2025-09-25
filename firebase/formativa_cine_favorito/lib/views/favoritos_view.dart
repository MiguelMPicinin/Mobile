import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:formativa_cine_favorite/controllers/firestore_controller.dart';
import 'package:formativa_cine_favorite/models/movie.dart';
import 'package:formativa_cine_favorite/views/search_movie_view.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  final _firestoreController = FirestoreController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filmes Favoritos"),
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      // criar um gridView com os filmes favoritos
      body: StreamBuilder<List<Movie>>(
        stream: _firestoreController.getFavoriteMovies(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar Lista de Filmes"));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhum Filme adicionado ao Favoritos"));
          }
          final favoriteMovies = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
              return GestureDetector(
                onLongPress: () {
                  this._firestoreController.removeFavoriteMovie(movie.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Filme removido com sucesso")),
                  );
                },
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Avalie "${movie.title}"'),
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Slider(
                                  value: movie.rating,
                                  min: 0,
                                  max: 5,
                                  divisions: 50,
                                  label: movie.rating.toStringAsFixed(1),
                                  onChanged: (value) {
                                    setState(() {
                                      movie.rating = value;
                                    });
                                  },
                                ),
                                Text('Nota: ${movie.rating.toStringAsFixed(1)}'),
                              ],
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              _firestoreController.updateMovieRating(
                                movie.id,
                                movie.rating,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Nota salva com sucesso"),
                                ),
                              );
                            },
                            child: Text('Salvar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.file(
                          File(movie.posterPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(movie.title),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Nota: ${movie.rating.toStringAsFixed(1)}"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchMovieView()),
        ),
      ),
    );
  }
}
