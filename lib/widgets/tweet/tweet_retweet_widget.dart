import 'package:flutter/material.dart';

import '../../models/tweet.dart';

import './tweet_widget.dart';

import 'user_widgets/tweet_retweet_user_widget.dart';

/// A widget that displays a retweet.
class TweetRetweetWidget extends StatelessWidget {
  const TweetRetweetWidget(
      {super.key, required this.tweet, required this.originalTweet});

  final Tweet tweet;
  final Future<Tweet> originalTweet;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tweet>(
        future: originalTweet,
        builder: (context, snapshot) {
          return Card(
            child: Row(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TweetRetweetUserWidget(tweet: tweet),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TweetWidget(tweet: snapshot.data ?? tweet),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
