import 'package:flutter/material.dart';

import '../../models/tweet.dart';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../routes.dart';

/// This widget show the tweet body with mentions and hashtags.
class TweetViewWidget extends ConsumerWidget {
  const TweetViewWidget({
    Key? key,
    required this.tweet,
  }) : super(key: key);

  final Tweet tweet;

  @override
  Widget build(BuildContext context, WidgetRef ref, [bool mounted = true]) {
    final whichProfileToShow = ref.watch(whichProfileToShowProvider.notifier);
    final hashtagToShow = ref.watch(hashtagToShowProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DetectableText(
        detectionRegExp: detectionRegExp()!,
        text: tweet.body ?? 'Loading...',
        detectedStyle: const TextStyle(
          color: Colors.blue,
        ),
        onTap: (tappedText) async {
          if (tappedText.contains('@')) {
            final uid = await FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: tappedText.substring(1))
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
            hashtagToShow.state = tappedText.substring(1);
            Navigator.pushNamed(context, RouteGenerator.hashtag);
          } else {
            debugPrint('URL');
          }
        },
      ),
    );
  }
}
