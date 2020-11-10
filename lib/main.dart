import 'package:flutter/material.dart';
import 'views/screens/play_list.dart';
import 'views/screens/player_music.dart';
import 'views/screens/player_video.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      routes: <String, WidgetBuilder>{
        '/': (_) => PlayList(),
        '/music': (_) => PlayerMusic(),
        '/video': (_) => PlayerVideo(),
      },
    );
  }
}
