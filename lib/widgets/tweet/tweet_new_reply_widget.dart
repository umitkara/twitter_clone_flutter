import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/tweet.dart';
import '../../models/tweet_types.dart';

import '../../models/providers.dart';

import './tweet_widget.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/functions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';

/// This widget is used to compose a reply to a tweet.
/// It will be displayed in a simple dialog.
class TweetNewReplyWidget extends ConsumerWidget {
  const TweetNewReplyWidget({super.key, required this.replyingTweet});

  final Tweet replyingTweet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTweetRef = ref.watch(newTweetProvider.notifier);
    final newTweet = ref.watch(newTweetProvider);

    return SimpleDialog(
      title: const Text('Reply'),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DetectableTextField(
            detectionRegExp: detectionRegExp()!,
            decoratedStyle: const TextStyle(
              color: Colors.blue,
            ),
            basicStyle: const TextStyle(),
            onChanged: (text) {
              newTweetRef.updateText(text);
            },
            maxLines: 5,
            maxLength: 240,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'What do you think?',
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TweetWidget(tweet: replyingTweet),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                newTweetRef.setOriginalTweet(replyingTweet);
                newTweetRef.setTweetType(TweetType.reply);

                final List<String> mentions = extractDetections(
                  newTweet.body!,
                  detectionRegExp(hashtag: false, url: false)!,
                );
                final List<String> hashtags = extractDetections(
                  newTweet.body!,
                  detectionRegExp(atSign: false, url: false)!,
                );
                newTweet.hashtags = hashtags;
                newTweet.mentions = mentions;

                newTweetRef.post();
                replyingTweet.reply(FirebaseAuth.instance.currentUser?.uid);
                Navigator.pop(context);
              },
              child: const Text('Reply'),
            ),
          ],
        ),
      ],
    );
  }
}
