import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/models/message.dart';

import '../../models/providers.dart';
import '../../routes.dart';

class NewMessageWidget extends ConsumerStatefulWidget {
  const NewMessageWidget({super.key});

  @override
  NewMessageWidgetState createState() => NewMessageWidgetState();
}

class NewMessageWidgetState extends ConsumerState<NewMessageWidget> {
  List<dynamic> searchedUser = [];

  @override
  Widget build(BuildContext context) {
    final usersFollowings = ref.watch(userFollowingsProvider).asData!.value;
    final currentUserId = ref.watch(userStreamProvider).asData!.value!.uid;
    final chatIdToShow = ref.watch(chatIdToShowProvider.notifier);

    return SimpleDialog(
      title: const Text('New Message'),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search for a user',
            ),
            onChanged: (value) async {
              searchedUser.clear();
              var userQuery = FirebaseFirestore.instance
                  .collection('users')
                  .where('id', whereIn: (usersFollowings as List<dynamic>))
                  .where('username', isEqualTo: value)
                  .limit(20);
              final users = await userQuery.get();
              for (var user in users.docs) {
                searchedUser.add(user.data());
              }
              setState(() {});
            },
          ),
        ),

        // list of users
        SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: searchedUser.length,
            itemBuilder: (context, index) {
              final user = searchedUser[index];
              return ListTile(
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                title: Text(user['username']),
                onTap: () async {
                  if (await Message.isChatExist(currentUserId, user['id'])) {
                    // navigate to chat screen
                    chatIdToShow.state =
                        await Message.getExistingChatIdByUserIds(
                            currentUserId, user['id']);
                    if (!mounted) return;
                    Navigator.of(context).pushNamed(RouteGenerator.chat);
                  }
                  chatIdToShow.state = (await Message.createNewMessage(
                          currentUserId, user['id']))
                      .id!;
                  if (!mounted) return;
                  Navigator.of(context).pushNamed(RouteGenerator.chat);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
