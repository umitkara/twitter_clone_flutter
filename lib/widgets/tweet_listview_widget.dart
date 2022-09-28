import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/tweet.dart';

import './tweet/tweet_widget.dart';
import './tweet/tweet_retweet_widget.dart';
import './tweet/tweet_reply_widget.dart';

import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/providers.dart';

import '../models/tweet_types.dart';

class TweetListview extends ConsumerWidget {
  const TweetListview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userFollowings = ref.watch(userFollowingsProvider);
    /*
    final timelineTweets = ref.watch(timelineProvider);
    debugPrint(timelineTweets.toString());
    ref.read(timelineProvider.notifier).loadMore();
    debugPrint(timelineTweets.toString());
    */
    if (userFollowings.value == null ||
        userFollowings.value == const Stream.empty()) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    PaginateRefreshedChangeListener refreshChangeListener =
        PaginateRefreshedChangeListener();
    return RefreshIndicator(
      child: PaginateFirestore(
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
            .where('userId', whereIn: (userFollowings.value as List<dynamic>))
            .orderBy('createdAt', descending: true),
        itemBuilderType: PaginateBuilderType.listView,
        isLive: true,
        itemsPerPage: 20,
        onEmpty: const Center(
          child: Text('No tweets'),
        ),
        listeners: [
          refreshChangeListener,
        ],
      ),
      onRefresh: () async {
        refreshChangeListener.refreshed = true;
      },
    );
  }
}
