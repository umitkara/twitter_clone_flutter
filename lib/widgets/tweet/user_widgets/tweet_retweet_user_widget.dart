import 'package:flutter/material.dart';

import '../../../models/tweet.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/providers.dart';

class TweetRetweetUserWidget extends ConsumerStatefulWidget {
  const TweetRetweetUserWidget({super.key, required this.tweet});

  final Tweet tweet;

  @override
  TweetRetweetUserWidgetState createState() => TweetRetweetUserWidgetState();
}

class TweetRetweetUserWidgetState
    extends ConsumerState<TweetRetweetUserWidget> {
  @override
  Widget build(BuildContext context) {
    final whichProfileToShow = ref.watch(whichProfileToShowProvider.notifier);

    return FutureBuilder(
      future: widget.tweet.user,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            children: <Widget>[
              TextButton(
                onPressed: () {
                  whichProfileToShow.state = snapshot.data!.id!;
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text(
                  snapshot.data!.name ?? 'Loading...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Text(
                ' Retweeted',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 5),
              Text(
                timeago.format(widget.tweet.createdAt ?? DateTime.now()),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          );
        } else {
          return const Text('Loading...');
        }
      },
    );
  }
}
