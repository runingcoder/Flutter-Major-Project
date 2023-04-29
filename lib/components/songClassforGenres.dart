class Song {
  final String imageUrl;
  final String name;
  final String artistName;

  Song({required this.imageUrl, required this.name, required this.artistName});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      imageUrl: json['imageUrl'],
      name: json['name'],
      artistName: json['artists'].join(', '),
    );
  }
}