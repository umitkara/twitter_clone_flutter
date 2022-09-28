import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/models/message.dart';

import '../../models/providers.dart';

import 'package:timeago/timeago.dart' as timeago;

class ChatBodyWidget extends ConsumerWidget {
  const ChatBodyWidget({super.key, required this.msg});

  final ChatMessage msg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdToShow = ref.watch(chatIdToShowProvider);
    final userSide = ref.watch(userSideProvider);
    bool isMe;

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('messages')
          .doc(chatIdToShow)
          .get(),
      builder: (context, messagesnapshot) {
        if (messagesnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final message = Message.fromJson(
          messagesnapshot.data!.data()!,
          messagesnapshot.data!.id,
        );
        return FutureBuilder(
          future: msg.from == MessageFrom.sender
              ? message.getSenderUser()
              : message.getReceiverUser(),
          builder: (context, usersnapshot) {
            if (usersnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final user = usersnapshot.data!;
            isMe = msg.from == userSide.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: isMe
                  ? EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      right: 8,
                      left: MediaQuery.of(context).size.width * 0.3)
                  : EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 8,
                      right: MediaQuery.of(context).size.width * 0.3),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[400],
                borderRadius: isMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(timeago.format(msg.createdAt!),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        color: isMe ? Colors.white : Colors.black,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    msg.body!,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
