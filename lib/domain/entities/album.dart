class Album {
  final String name;
  final String artist;
  final String? artworkPath;
  final int numberOfSongs;

  const Album({
    required this.name,
    required this.artist,
    this.artworkPath,
    required this.numberOfSongs,
  });
}
