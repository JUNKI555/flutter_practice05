class Content {
  Content(
      {this.id,
      this.category,
      this.title,
      this.outline,
      this.artist,
      this.source,
      this.image});

  factory Content.fromJson(Map<dynamic, dynamic> json) {
    return Content(
      id: json['id'] as String,
      category: json['category'] as int,
      title: json['title'] as String,
      outline: json['title'] as String,
      artist: json['title'] as String,
      source: json['title'] as String,
      image: json['title'] as String,
    );
  }

  final String id;
  final int category;
  final String title;
  final String outline;
  final String artist;
  final String source;
  final String image;
}
