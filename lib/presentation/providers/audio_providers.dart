import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});

final queueProvider = StreamProvider<List<MediaItem>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queue;
});

final currentPositionProvider = StreamProvider<Duration>((ref) {
  return Stream.periodic(const Duration(milliseconds: 200)).map((_) {
    final state = ref.read(playbackStateProvider).value;
    if (state == null) return Duration.zero;
    // AudioService typically provides updateTime. If just_audio updates state via AudioHandler, updateTime is set to DateTime.now() at that moment.
    // However, our AudioHandler implementation in _notifyAudioHandlerAboutPlaybackEvents construction of PlaybackState
    // does not explicitly set updateTime, so it defaults to DateTime.now().

    if (!state.playing) return state.updatePosition;

    final now = DateTime.now();
    final elapsed = now.difference(state.updateTime);
    // Determine the position
    final position = state.updatePosition + (elapsed * state.speed);
    return position;
  });
});
