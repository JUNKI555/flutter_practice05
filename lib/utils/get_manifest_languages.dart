import 'dart:async';

import 'package:flutter_playout/multiaudio/HLSManifestLanguage.dart';
import 'package:flutter_playout/multiaudio/LanguageCode.dart';
import 'package:http/http.dart' as http;

Future<List<HLSManifestLanguage>> getManifestLanguages(
    String manifestURL) async {
  final response = await http.get(manifestURL);

  final manifest = response.body.split('\n');

  var start = 7;
  if (manifestURL.startsWith('https')) {
    start = 8;
  }

  final _baseURL = manifestURL.substring(0, manifestURL.indexOf('/', start));
  final _baseURLLastIndex =
      manifestURL.substring(0, manifestURL.lastIndexOf('/'));

  final _langs = <String, HLSManifestLanguage>{};

  /* iterate through all #EXT-X-MEDIA:TYPE=AUDIO */
  for (final m in manifest) {
    if (m.startsWith('#EXT-X-MEDIA:TYPE=AUDIO')) {
      final values = m.replaceAll('#EXT-X-MEDIA:TYPE=AUDIO,', '').split(',');

      final uri = values
          .where((v) => v.startsWith('URI'))
          .first
          .replaceAll('URI=', '')
          .replaceAll('\"', '');

      final languageCode = values
          .where((v) => v.startsWith('LANGUAGE'))
          .first
          .replaceAll('LANGUAGE=', '')
          .replaceAll('\"', '');

      final language = LanguageCode.getLanguageByCode(languageCode);

      if (uri.contains('/')) {
        language.url = _baseURL + uri;
      } else {
        language.url = '$_baseURLLastIndex/$uri';
      }

      _langs.putIfAbsent(languageCode, () => language);
    }
  }

  /* legacy manifest */
  if (_langs.isEmpty) {
    const languageCode = 'mul';

    final language = LanguageCode.getLanguageByCode(languageCode);

    for (final manifestUrl in manifest) {
      if (manifestUrl.contains('a-p')) {
        language.url = manifestUrl;

        _langs.putIfAbsent(languageCode, () => language);
      }
    }
  }

  return _langs.values.toList();
}
