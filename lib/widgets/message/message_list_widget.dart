import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';
import '../../models/message.dart';

import './message_widget.dart';

class MessageListWidget extends ConsumerWidget {
  const MessageListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userStreamProvider).asData!.value;

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('messages')
          .where('ids', arrayContains: currentUser!.uid)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = Message.fromJson(
                (messages[index].data() as Map<String, dynamic>),
                messages[index].id,
              );
              return MessageWidget(message: message);
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
