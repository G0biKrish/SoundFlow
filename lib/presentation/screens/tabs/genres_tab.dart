import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/song.dart';
import '../../providers/music_providers.dart';
import 'package:audio_service/audio_service.dart';
import '../../widgets/song_tile.dart';
import '../../../core/audio/audio_handler.dart';
import '../../../main.dart';

// We need a specific provider for genres or just process songs.
// For now, we'll derive it from allSongsProvider to keep it simple without adding moreRepo methods if not needed.
// But the repo interface has `getSongsByGenre`, so let's add a genresProvider if we want to list genres first.
// The requirement says: "Genres -> Genre detail -> Songs grouped by artist"
// So we need a list of Genres first.

// Let's assume we can fetch unique genres.
final genresProvider = FutureProvider<List<String>>((ref) async {
  final songs = await ref.watch(allSongsProvider.future);
  final genres = songs.map((s) => s.genre).toSet().toList();
  genres.sort();
  return genres;
});

class GenresTab extends ConsumerWidget {
  const GenresTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genresProvider);

    return genresAsync.when(
      data: (genres) {
        if (genres.isEmpty) {
          return const Center(child: Text('No genres found.'));
        }
        return ListView.builder(
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            return ListTile(
              leading: const Icon(Icons.queue_music),
              title: Text(genre),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GenreDetailScreen(genre: genre),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class GenreDetailScreen extends ConsumerWidget {
  final String genre;
  const GenreDetailScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use a family provider or just filter in UI for MVP
    final allSongs = ref.watch(allSongsProvider).value ?? [];
    final songs = allSongs.where((s) => s.genre == genre).toList();

    return Scaffold(
      appBar: AppBar(title: Text(genre)),
      body: songs.isEmpty
          ? const Center(child: Text('No songs found in this genre.'))
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
                  onTap: () {
                    _playSong(ref, songs, index);
                  },
                );
              },
            ),
    );
  }

  void _playSong(WidgetRef ref, List<Song> songs, int index) {
    final handler = ref.read(audioHandlerProvider) as AudioPlayerHandler;
    final items = songs
        .map((s) => MediaItem(
              id: s.path,
              album: s.album,
              title: s.title,
              artist: s.artist,
              duration: s.duration,
              artUri: s.artworkPath != null ? Uri.file(s.artworkPath!) : null,
              extras: {'dbId': s.id},
            ))
        .toList();

    handler.playSongList(items, index);
  }
}
