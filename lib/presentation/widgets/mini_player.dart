import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_providers.dart';
import '../screens/player_screen.dart';
import '../../main.dart'; // for audioHandlerProvider usage if needed directly

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final playbackStateAsync = ref.watch(playbackStateProvider);

    return mediaItemAsync.when(
      data: (item) {
        if (item == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PlayerScreen()),
            );
          },
          child: Container(
            height: 64,
            width: double.infinity,
            color: Colors.transparent,
            child: Row(
              children: [
                // Art
                Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[800],
                  child: item.artUri != null
                      ? Image.file(
                          File(item.artUri!.toFilePath()),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.music_note),
                        )
                      : const Icon(Icons.music_note),
                ),
                const SizedBox(width: 12),
                // Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        item.artist ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                // Controls
                playbackStateAsync.when(
                  data: (state) {
                    final playing = state.playing;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                          color: Colors.white,
                          onPressed: () {
                            final handler = ref.read(audioHandlerProvider);
                            if (playing) {
                              handler.pause();
                            } else {
                              handler.play();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          color: Colors.white,
                          onPressed: () {
                            ref.read(audioHandlerProvider).skipToNext();
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

extension UriFilePath on Uri {
  String toFilePath() => path; // Simplified
}
