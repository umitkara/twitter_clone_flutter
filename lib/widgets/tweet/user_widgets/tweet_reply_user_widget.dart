import 'package:flutter/material.dart';

import '../../../models/tweet.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/providers.dart';

class TweetReplyUserWidget extends ConsumerStatefulWidget {
  const TweetReplyUserWidget(
      {super.key, required this.tweet, required this.originalTweetSnapshot});

  final Tweet tweet;
  final AsyncSnapshot<Tweet> originalTweetSnapshot;

  @override
  TweetReplyUserWidgetState createState() => TweetReplyUserWidgetState();
}

class TweetReplyUserWidgetState extends ConsumerState<TweetReplyUserWidget> {
  @override
  Widget build(BuildContext context) {
    final whichProfileToShow = ref.watch(whichProfileToShowProvider.notifier);

    return FutureBuilder(
      future: widget.tweet.user,
      builder: (context, tweetUserSnapshot) {
        if (tweetUserSnapshot.hasData) {
          return Row(
            children: <Widget>[
              TextButton(
                onPressed: () {
                  whichProfileToShow.state = tweetUserSnapshot.data!.id!;
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text(
                  tweetUserSnapshot.data!.name ?? 'Loading...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              FutureBuilder(
                future: widget.originalTweetSnapshot.data?.user,
                builder: (context, originalTweetUserSnapshot) {
                  if (originalTweetUserSnapshot.hasData) {
                    return Row(
                      children: <Widget>[
                        const Text(
                          ' Replying to ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            whichProfileToShow.state =
                                originalTweetUserSnapshot.data!.id!;
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Text(
                            originalTweetUserSnapshot.data!.name ??
                                'Loading...',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Loading...');
                  }
                },
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
