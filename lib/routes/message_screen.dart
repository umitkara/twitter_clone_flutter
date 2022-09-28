import 'package:flutter/material.dart';

import '../widgets/drawer/navigation_drawer_widget.dart';

import '../widgets/message/message_list_widget.dart';

import '../widgets/message/new_message_widget.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      drawer: NavigationDrawerWidget(pageContext: context),
      body: const MessageListWidget(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Message',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return const NewMessageWidget();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
