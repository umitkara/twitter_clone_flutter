import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';

import 'package:paginate_firestore/paginate_firestore.dart';

import '../tweet/tweet_widget.dart';
import '../tweet/tweet_retweet_widget.dart';
import '../tweet/tweet_reply_widget.dart';

import '../../models/tweet.dart';

import '../../models/tweet_types.dart';

class HashtagWidget extends ConsumerWidget {
  const HashtagWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hashtagToShow = ref.watch(hashtagToShowProvider);
    if (hashtagToShow == '') {
      return ErrorWidget('No hashtag to show');
    }

    return PaginateFirestore(
      itemBuilder: (context, documentSnapshots, index) {
        final tweet = Tweet.fromJson(
            documentSnapshots[index].data() as Map<String, dynamic>,
            documentSnapshots[index].id);
        if (tweet.type == TweetType.retweet) {
          return TweetRetweetWidget(
              tweet: tweet, originalTweet: tweet.originalTweet);
        } else if (tweet.type == TweetType.reply) {
          return TweetReplyWidget(
              tweet: tweet, originalTweet: tweet.originalTweet);
        } else {
          return TweetWidget(tweet: tweet);
        }
      },
      query: FirebaseFirestore.instance
          .collection('tweets')
          .where('hashtags', arrayContains: '#$hashtagToShow')
          .orderBy('createdAt', descending: true),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true,
      onEmpty: const Center(child: Text('No tweets')),
    );
  }
}
