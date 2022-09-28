import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/tweet/new_tweet_widget.dart';

import '../../models/providers.dart';

class NewTweetScreen extends ConsumerWidget {
  const NewTweetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTweet = ref.watch(newTweetProvider.notifier);
    final newTweetState = ref.watch(newTweetProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Tweet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (newTweetState.body?.isNotEmpty == true) {
                newTweet.post().then((value) => Navigator.of(context).pop());
              } else {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Tweet cannot be empty'),
                    ),
                  );
              }
            },
          ),
        ],
      ),
      body: const NewTweetForm(),
    );
  }
}
