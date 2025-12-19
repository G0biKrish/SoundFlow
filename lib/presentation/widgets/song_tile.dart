import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final Widget? trailing;

  const SongTile(
      {super.key, required this.song, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          image: song.artworkPath != null
              ? DecorationImage(
                  image: FileImage(File(song.artworkPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: song.artworkPath == null
            ? const Icon(Icons.music_note, color: Colors.white54)
            : null,
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[400]),
      ),
      trailing: trailing ??
          Text(
            _formatDuration(song.duration),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
      onTap: onTap,
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}
