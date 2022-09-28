import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/widgets/profile/profile_header_widget.dart';

import '../../models/providers.dart';

import 'package:paginate_firestore/paginate_firestore.dart';

import '../../models/tweet.dart';

import '../tweet/tweet_widget.dart';
import '../tweet/tweet_retweet_widget.dart';
import '../tweet/tweet_reply_widget.dart';

import '../../models/tweet_types.dart';

class ProfileReplyListviewWidget extends ConsumerWidget {
  const ProfileReplyListviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTweets = ref.watch(otherUserProfileProvider).asData?.value.tweets;
    final userRef = ref.watch(otherUserProfileProvider);

    if (userRef.value == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (userTweets!.isEmpty) {
      return const Center(
        child: Text('No tweets'),
      );
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
            .where('userId', isEqualTo: userRef.value!.id)
            .where('type', isEqualTo: TweetType.reply.name)
            .orderBy('createdAt', descending: true),
        itemBuilderType: PaginateBuilderType.listView,
        isLive: true,
        itemsPerPage: 20,
        onEmpty: const Center(
          child: Text('No tweets'),
        ),
        header: const SliverToBoxAdapter(
          child: ProfileHeaderWidget(),
        ));
  }
}
