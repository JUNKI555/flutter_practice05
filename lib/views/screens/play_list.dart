import 'package:flutter/material.dart';
import '../../core/app_code.dart';
import '../../entities/content.dart';
import '../../view_models/list_view_model.dart';

class PlayList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List View'),
      ),
      body: FutureBuilder<List<Content>>(
        future: ListViewModel().fetchContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final contents = snapshot.data;
          return Scrollbar(
            child: RefreshIndicator(
              child: ListView.separated(
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final listTile = ListTile(
                    leading: contents[index].category == ContentCategory.video
                        ? const Icon(Icons.ondemand_video, color: Colors.red)
                        : const Icon(Icons.music_video, color: Colors.red),
                    title: Text(contents[index].title),
                    onTap: () {
                      final content = contents[index];
                      switch (contents[index].category) {
                        case ContentCategory.video:
                          break;
                        case ContentCategory.music:
                          Navigator.of(context)
                              .pushNamed('/music', arguments: content);
                          break;
                      }
                    },
                  );
                  return Container(color: Colors.white, child: listTile);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    color: Colors.blue,
                  );
                },
              ),
              onRefresh: ListViewModel().fetchContents,
            ),
          );
        },
      ),
    );
  }
}
