import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/providers.dart';
import '../../models/message.dart';

import '../../routes.dart';

class MessageWidget extends ConsumerWidget {
  const MessageWidget({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdToShow = ref.watch(chatIdToShowProvider.notifier);
    final currentUserId = ref.watch(userStreamProvider).asData!.value!.uid;

    return ListTile(
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          child: Icon(Icons.person),
        ),
      ),
      title: FutureBuilder(
        future: message.senderId != currentUserId
            ? message.getSenderUser()
            : message.getReceiverUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!.name!);
          } else {
            return const Text('Loading...');
          }
        },
      ),
      subtitle: FutureBuilder(
        future: message.getMessages(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              final messages = snapshot.data!.docs;
              final lastMessage = messages.first.data();
              return Text(
                lastMessage['body'],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            } else {
              return const Text('No messages yet');
            }
          } else {
            return const Text('Loading...');
          }
        },
      ),
      onTap: () async {
        chatIdToShow.state = message.id!;
        Navigator.of(context).pushNamed(RouteGenerator.chat);
      },
    );
  }
}
