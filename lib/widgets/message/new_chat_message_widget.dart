import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/models/message.dart';

import '../../models/providers.dart';

class NewChatMessageWidget extends ConsumerStatefulWidget {
  const NewChatMessageWidget({super.key});

  @override
  NewChatMessageWidgetState createState() => NewChatMessageWidgetState();
}

class NewChatMessageWidgetState extends ConsumerState<NewChatMessageWidget> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatIdToShow = ref.watch(chatIdToShowProvider);
    final userSide = ref.watch(userSideProvider);

    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
              maxLines: 8,
              minLines: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              final currentMessage = await FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatIdToShow)
                  .withConverter(
                    fromFirestore: (snapshot, _) =>
                        Message.fromJson(snapshot.data()!, snapshot.id),
                    toFirestore: (message, _) => message.toJson(),
                  )
                  .get();
              var isFirstMessage = await FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatIdToShow)
                  .collection('messages')
                  .get();

              currentMessage.data()!.newChatMessage(
                    _controller.text,
                    userSide.value!,
                    isFirstMessage.docs.isEmpty,
                  );
              _controller.clear();
            },
          ),
        ),
      ],
    );
  }
}
