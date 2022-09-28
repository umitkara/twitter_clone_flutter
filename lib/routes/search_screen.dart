import 'package:flutter/material.dart';
import 'package:firestore_search/firestore_search.dart';
import '../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whichProfileToShow = ref.watch(whichProfileToShowProvider.notifier);

    return FirestoreSearchScaffold(
      firestoreCollectionName: 'users',
      searchBy: 'username',
      scaffoldBody: const Center(
        child: Text('Search for users'),
      ),
      dataListFromSnapshot: User.listFromSnapshot,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<User>? userList = snapshot.data;
          if (userList!.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final User user = userList[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(user.name!),
                subtitle: Text(user.username!),
                onTap: () {
                  whichProfileToShow.state = user.id!;
                  Navigator.pushNamed(context, '/profile');
                },
              );
            },
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No users found'),
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
