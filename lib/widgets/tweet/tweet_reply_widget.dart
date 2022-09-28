import 'package:flutter/material.dart';

import '../../models/tweet.dart';

import './tweet_widget.dart';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_widgets/tweet_reply_user_widget.dart';

/// This widget show the reply body with mentions and hashtags, and original tweet.
class TweetReplyWidget extends ConsumerStatefulWidget {
  const TweetReplyWidget(
      {super.key, required this.tweet, required this.originalTweet});

  final Tweet tweet;
  final Future<Tweet> originalTweet;

  @override
  TweetReplyWidgetState createState() => TweetReplyWidgetState();
}

class TweetReplyWidgetState extends ConsumerState<TweetReplyWidget> {
  @override
  Widget build(BuildContext context) {
    final whichProfileToShow = ref.watch(whichProfileToShowProvider.notifier);

    return FutureBuilder<Tweet>(
        future: widget.originalTweet,
        builder: (context, originalTweetSnapshot) {
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
                          child: TweetReplyUserWidget(
                            tweet: widget.tweet,
                            originalTweetSnapshot: originalTweetSnapshot,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: DetectableText(
                            detectionRegExp: detectionRegExp()!,
                            text: widget.tweet.body ?? 'Loading...',
                            detectedStyle: const TextStyle(
                              color: Colors.blue,
                            ),
                            onTap: (tappedText) async {
                              if (tappedText.contains('@')) {
                                // get id from username
                                final uid = await FirebaseFirestore.instance
                                    .collection('users')
                                    .where('username',
                                        isEqualTo: tappedText.substring(1))
                                    .get()
                                    .then((value) => value.docs[0].id);
                                if (uid != "") {
                                  whichProfileToShow.state = uid;
                                  if (!mounted) return;
                                  Navigator.pushNamed(context, '/profile');
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User not found.'),
                                    ),
                                  );
                                }
                              } else if (tappedText.contains('#')) {
                                debugPrint('Hashtag');
                              } else {
                                debugPrint('URL');
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TweetWidget(
                              tweet:
                                  originalTweetSnapshot.data ?? widget.tweet),
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
