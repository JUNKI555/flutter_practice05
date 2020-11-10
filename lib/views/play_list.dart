import 'package:flutter/material.dart';
import '../entities/content.dart';
import '../view_models/list_view_model.dart';

class PlayList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List View'),
      ),
      body: FutureBuilder<List<Content>>(
        future: new ListViewModel().fetchContents(),
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
                    leading: const Icon(Icons.photo_filter, color: Colors.blue),
                    title: Text(contents[index].title),
                    onTap: () {
                      // do nothing
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
              onRefresh: new ListViewModel().fetchContents,
            ),
          );
        },
      ),
    );
  }
}
