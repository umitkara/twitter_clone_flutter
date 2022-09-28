import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../models/tweet.dart';

import 'tweet_new_reply_widget.dart';

/// A widget that contains tweet actions. This widget is used in [TweetWidget].
/// It contains like, retweet and reply actions.
class ActionButtonsWidget extends StatelessWidget {
  final Tweet? tweet;

  const ActionButtonsWidget({super.key, required this.tweet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              color: tweet?.replies
                          ?.contains(FirebaseAuth.instance.currentUser?.uid) ??
                      false
                  ? Colors.blue
                  : Colors.grey,
              icon: const Icon(Icons.comment),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return TweetNewReplyWidget(replyingTweet: tweet!);
                  },
                );
              },
              splashRadius: 20,
              tooltip: 'Reply',
            ),
            Text(tweet?.replies?.length.toString() ?? '0'),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              color: tweet?.retweets
                          ?.contains(FirebaseAuth.instance.currentUser?.uid) ??
                      false
                  ? Colors.green
                  : Colors.grey,
              icon: const Icon(Icons.repeat),
              onPressed: () => tweet
                  ?.retweetUnretweet(FirebaseAuth.instance.currentUser?.uid),
              splashRadius: 20,
              tooltip: 'Retweet',
            ),
            Text(tweet?.retweets?.length.toString() ?? '0'),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              color: tweet?.likes
                          ?.contains(FirebaseAuth.instance.currentUser?.uid) ??
                      false
                  ? Colors.red
                  : Colors.grey,
              icon: tweet?.likes
                          ?.contains(FirebaseAuth.instance.currentUser?.uid) ??
                      false
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border),
              onPressed: () =>
                  tweet?.likeDislike(FirebaseAuth.instance.currentUser?.uid),
              splashRadius: 20,
              tooltip: 'Like',
            ),
            Text(tweet?.likes?.length.toString() ?? '0'),
          ],
        ),
      ],
    );
  }
}
