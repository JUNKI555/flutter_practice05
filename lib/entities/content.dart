import '../core/app_code.dart';

class Content {
  Content(
      {this.id,
      this.category,
      this.title,
      this.outline,
      this.artist,
      this.source,
      this.image});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      category: ContentCategory.values[json['category'] as int],
      title: json['title'] as String,
      outline: json['outline'] as String,
      artist: json['artist'] as String,
      source: json['source'] as String,
      image: json['image'] as String,
    );
  }

  final String id;
  final ContentCategory category;
  final String title;
  final String outline;
  final String artist;
  final String source;
  final String image;
}
