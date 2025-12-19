import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_providers.dart';
import '../providers/audio_providers.dart';
import '../widgets/mini_player.dart';
import 'player_screen.dart';
import 'settings_screen.dart';
import 'tabs/songs_tab.dart';
import 'tabs/artists_tab.dart';
import 'tabs/albums_tab.dart';
import 'tabs/playlists_tab.dart';
import 'tabs/genres_tab.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _tabs = [
    const SongsTab(),
    const ArtistsTab(),
    const AlbumsTab(),
    const GenresTab(),
    const PlaylistsTab(),
  ];

  get import => null;

  @override
  Widget build(BuildContext context) {
    // isScanning removed as it is no longer used in the UI

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.asset('assets/images/android/main_screen_logo.png'),
        ),
        titleSpacing: 0,
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.pinkAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'SoulSound',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          if (_currentIndex == 0) // Show sort only on Songs tab
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort by',
              onSelected: (SortOption result) {
                ref.read(sortOrderProvider.notifier).state = result;
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SortOption>>[
                const PopupMenuItem<SortOption>(
                  value: SortOption.recentlyAdded,
                  child: Text('Newest'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.mostPlayed,
                  child: Text('Most Played'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.title,
                  child: Text('A to Z'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.artist,
                  child: Text('Artist'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.duration,
                  child: Text('Duration'),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _tabs),
          ),
          // Dynamic Bottom Section
          if (ref.watch(currentMediaItemProvider).asData?.value != null)
            // "Now Playing" Card Panel (Draggable/Swipeable)
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < -200) {
                  // Swipe Up
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    enableDrag: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const PlayerScreen(),
                  );
                }
              },
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  enableDrag: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const PlayerScreen(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181818), // Dark card background
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(top: 12, bottom: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Mini Player (Transparent)
                    const MiniPlayer(),

                    // Progress Bar (Simple Visual)
                    const _MiniProgressBar(),

                    const SizedBox(height: 20),

                    // Floating Pill Dock
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDockIcon(0, Icons.music_note, 'Songs'),
                          _buildDockIcon(1, Icons.person, 'Artists'),
                          _buildDockIcon(2, Icons.album, 'Albums'),
                          _buildDockIcon(3, Icons.queue_music, 'Genres'),
                          _buildDockIcon(4, Icons.playlist_play, 'Playlists'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Floating Pill Dock (Standalone)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDockIcon(0, Icons.music_note, 'Songs'),
                  _buildDockIcon(1, Icons.person, 'Artists'),
                  _buildDockIcon(2, Icons.album, 'Albums'),
                  _buildDockIcon(3, Icons.queue_music, 'Genres'),
                  _buildDockIcon(4, Icons.playlist_play, 'Playlists'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDockIcon(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 26,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 16 : 0,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for the simple progress bar
class _MiniProgressBar extends ConsumerWidget {
  const _MiniProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(currentPositionProvider);
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    final duration = mediaItem?.duration ?? Duration.zero;

    return positionAsync.when(
      data: (position) {
        final double progress = (duration.inMilliseconds > 0)
            ? (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation(Colors.amber),
                      minHeight: 4,
                    ),
                  ),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 20),
      error: (_, __) => const SizedBox(height: 20),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}
