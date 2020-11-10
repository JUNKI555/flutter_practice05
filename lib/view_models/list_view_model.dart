import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../entities/content.dart';

class ListViewModel {
  List<Content> _contents = [];

  List<Content> get contents {
    return [..._contents];
  }

  Future<List<Content>> fetchContents() async {
    final loadData = await rootBundle.loadString('assets/json/playlist.json');
    final jsonMap = jsonDecode(loadData) as Map<String, dynamic>;

    if (jsonMap['playlist'] != null) {
      final result = <Content>[];
      jsonMap['playlist'].forEach((dynamic v) {
        result.add(new Content.fromJson(v as Map<String, dynamic>));
      });

      _contents = result;
    }

    // notifyListeners();
    return _contents;
  }
}
