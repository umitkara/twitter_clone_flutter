import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/providers.dart';

import '../models/message.dart';

import '../widgets/message/chat_widget.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  Future<String> getUsernameFromChat(
      String chatId, String currentUserId) async {
    var messageDoc = await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .get();
    var message = Message.fromJson(messageDoc.data()!, messageDoc.id);
    if (message.senderId == currentUserId) {
      var receiverUser = await message.getReceiverUser();
      return receiverUser.name!;
    }
    var senderUser = await message.getSenderUser();
    return senderUser.name!;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdToShow = ref.watch(chatIdToShowProvider);
    final currentUserId = ref.watch(userStreamProvider).asData!.value!.uid;
    final chatName = getUsernameFromChat(chatIdToShow, currentUserId);
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: chatName,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Chat with ${snapshot.data}');
            } else {
              return const Text('Loading...');
            }
          },
        ),
      ),
      body: const ChatWidget(),
    );
  }
}
