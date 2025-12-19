import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_providers.dart';
import '../../main.dart'; // for audioHandlerProvider

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueProvider);
    final currentItemAsync = ref.watch(currentMediaItemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Playing Queue')),
      body: queueAsync.when(
        data: (queue) {
          if (queue.isEmpty) return const Center(child: Text('Queue is empty'));

          final currentItem = currentItemAsync.value;

          return ReorderableListView.builder(
            itemCount: queue.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = queue.removeAt(oldIndex);
              queue.insert(newIndex, item);
              ref.read(audioHandlerProvider).updateQueue(queue);
            },
            itemBuilder: (context, index) {
              final item = queue[index];
              final isPlaying = currentItem?.id == item.id;

              return ListTile(
                key: ValueKey(
                  item.id + index.toString(),
                ), // Ensure uniqueness if duplicates allowed
                leading: isPlaying
                    ? const Icon(
                        Icons.equalizer,
                        color: Colors.deepPurpleAccent,
                      )
                    : const Icon(Icons.drag_handle),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: isPlaying ? Colors.deepPurpleAccent : Colors.white,
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(item.artist ?? 'Unknown'),
                onTap: () {
                  ref.read(audioHandlerProvider).skipToQueueItem(index);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
