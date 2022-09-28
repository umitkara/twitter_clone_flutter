import 'package:flutter/material.dart';

import '../../models/tweet.dart';

import 'user_widgets/tweet_user_widget.dart';
import './tweet_action_buttons.dart';

import 'tweet_view_widget.dart';

/// A widget that displays a tweet.
class TweetWidget extends StatelessWidget {
  const TweetWidget({super.key, required this.tweet});

  final Tweet tweet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
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
                    child: TweetUser(
                        user: tweet.user, tweetPostTime: tweet.createdAt),
                  ),
                  TweetViewWidget(
                    tweet: tweet,
                  ),
                  ActionButtonsWidget(tweet: tweet),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
