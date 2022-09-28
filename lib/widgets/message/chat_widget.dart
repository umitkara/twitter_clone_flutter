import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/models/message.dart';

import '../../models/providers.dart';

import 'package:paginate_firestore/paginate_firestore.dart';

import './new_chat_message_widget.dart';

import './chat_body_widget.dart';

class ChatWidget extends ConsumerWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdToShow = ref.watch(chatIdToShowProvider);

    return Column(
      children: <Widget>[
        Flexible(
          child: PaginateFirestore(
            itemBuilder: (context, documentSnapshots, index) {
              var msg = ChatMessage.fromJson(
                documentSnapshots[index].data()! as Map<String, dynamic>,
              );
              return ChatBodyWidget(
                msg: msg,
              );
            },
            query: FirebaseFirestore.instance
                .collection('messages')
                .doc(chatIdToShow)
                .collection('messages')
                .orderBy('createdAt', descending: true),
            itemBuilderType: PaginateBuilderType.listView,
            reverse: true,
            isLive: true,
          ),
        ),
        const NewChatMessageWidget(),
      ],
    );
  }
}
