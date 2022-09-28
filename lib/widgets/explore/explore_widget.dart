import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';

import '../../routes.dart';

// ? Might add RefreshIndicator later. Or convert FutureBuilder to StreamBuilder?..

class ExploreWidget extends ConsumerWidget {
  const ExploreWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hashtagToShow = ref.watch(hashtagToShowProvider.notifier);

    return FutureBuilder(
      future:
          FirebaseFirestore.instance.collection('trends').doc('trends').get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          List<dynamic> data = snapshot.data.data()['trends'];
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.trending_up),
                title: TextButton(
                  onPressed: () {
                    hashtagToShow.state = data[index]['name'];
                    Navigator.pushNamed(context, RouteGenerator.hashtag);
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    textStyle: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  child: Text('${data[index]['name']}'),
                ),
                subtitle:
                    Text('${data[index]['count']} tweets posted last hour'),
              );
            },
          );
        }

        return const Text("loading");
      },
    );
  }
}
