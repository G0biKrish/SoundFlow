import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/song.dart';

import '../../main.dart';
import '../../core/audio/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Song> _results = [];
  bool _isLoading = false;

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(musicRepositoryProvider);
    final results = await repo.searchSongs(query);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _search,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(child: Text('Search for your music'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final song = _results[index];
                    return SongTile(
                      song: song,
                      onTap: () {
                        // Play searched song
                        // For simplicity, play this song as a single item queue or append?
                        // Getting "Play next" or "Play list" is better.
                        // Let's just play it in a new queue of 1 for now.
                        final item = MediaItem(
                          id: song.path,
                          album: song.album,
                          title: song.title,
                          artist: song.artist,
                          duration: song.duration,
                          artUri: song.artworkPath != null
                              ? Uri.file(song.artworkPath!)
                              : null,
                        );
                        final handler = ref.read(audioHandlerProvider)
                            as AudioPlayerHandler;
                        handler.playSongList([item], 0);
                      },
                    );
                  },
                ),
    );
  }
}
