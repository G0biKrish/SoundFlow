import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// useful for streams
import '../widgets/waveform_seek_bar.dart';
import '../providers/audio_providers.dart';
import '../../main.dart'; // for audioHandlerProvider

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final playbackStateAsync = ref.watch(playbackStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art
            mediaItemAsync.when(
              data: (item) {
                if (item == null) return const SizedBox(height: 300);
                return Container(
                  height: 320,
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: item.artUri != null
                        ? DecorationImage(
                            image: FileImage(File(item.artUri!.toFilePath())),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[850],
                  ),
                  child: item.artUri == null
                      ? const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.white24,
                        )
                      : null,
                );
              },
              loading: () => const SizedBox(height: 300),
              error: (_, __) => const SizedBox(height: 300),
            ),
            const SizedBox(height: 40),

            // Title & Artist
            mediaItemAsync.when(
              data: (item) => Column(
                children: [
                  Text(
                    item?.title ?? 'Not Playing',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item?.artist ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 30),

            // Seek Bar
            Consumer(
              builder: (context, ref, child) {
                final positionAsync = ref.watch(currentPositionProvider);
                final mediaItem = ref.watch(currentMediaItemProvider).value;
                final total = mediaItem?.duration ?? Duration.zero;

                return positionAsync.when(
                  data: (position) => WaveformSeekBar(
                    duration: total,
                    position: position,
                    onChangeEnd: (newPosition) {
                      ref.read(audioHandlerProvider).seek(newPosition);
                    },
                  ),
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 20),

            // Controls
            playbackStateAsync.when(
              data: (state) {
                final playing = state.playing;
                final shuffleMode = state.shuffleMode;
                final repeatMode = state.repeatMode;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      color: shuffleMode == AudioServiceShuffleMode.all
                          ? Colors.deepPurpleAccent
                          : Colors.grey,
                      onPressed: () {
                        final newMode =
                            shuffleMode == AudioServiceShuffleMode.none
                                ? AudioServiceShuffleMode.all
                                : AudioServiceShuffleMode.none;
                        ref.read(audioHandlerProvider).setShuffleMode(newMode);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 36),
                      color: Colors.white,
                      onPressed: () =>
                          ref.read(audioHandlerProvider).skipToPrevious(),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          final handler = ref.read(audioHandlerProvider);
                          playing ? handler.pause() : handler.play();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 36),
                      color: Colors.white,
                      onPressed: () =>
                          ref.read(audioHandlerProvider).skipToNext(),
                    ),
                    IconButton(
                      icon: Icon(
                        repeatMode == AudioServiceRepeatMode.one
                            ? Icons.repeat_one
                            : Icons.repeat,
                      ),
                      color: repeatMode == AudioServiceRepeatMode.none
                          ? Colors.grey
                          : Colors.deepPurpleAccent,
                      onPressed: () {
                        final newMode = _nextRepeatMode(repeatMode);
                        ref.read(audioHandlerProvider).setRepeatMode(newMode);
                      },
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  AudioServiceRepeatMode _nextRepeatMode(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.none:
        return AudioServiceRepeatMode.all;
      case AudioServiceRepeatMode.all:
        return AudioServiceRepeatMode.one;
      case AudioServiceRepeatMode.one:
        return AudioServiceRepeatMode.none;
      default:
        return AudioServiceRepeatMode.none;
    }
  }
}
