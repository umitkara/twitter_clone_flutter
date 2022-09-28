import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';

import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/functions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';

/// A widget to create new tweet.
class NewTweetForm extends ConsumerStatefulWidget {
  const NewTweetForm({super.key});

  @override
  NewTweetFormState createState() => NewTweetFormState();
}

class NewTweetFormState extends ConsumerState<NewTweetForm> {
  @override
  Widget build(BuildContext context) {
    final newTweet = ref.watch(newTweetProvider.notifier);
    final newTweetState = ref.watch(newTweetProvider);
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            DetectableTextField(
              detectionRegExp: detectionRegExp()!,
              decoratedStyle: const TextStyle(
                color: Colors.blue,
              ),
              basicStyle: const TextStyle(),
              onChanged: newTweet.updateText,
              maxLines: 5,
              maxLength: 240,
              decoration: const InputDecoration(
                hintText: 'What\'s happening?',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (newTweetState.body?.isNotEmpty == true) {
                    final List<String> mentions = extractDetections(
                      newTweetState.body!,
                      detectionRegExp(hashtag: false, url: false)!,
                    );
                    final List<String> hashtags = extractDetections(
                      newTweetState.body!,
                      detectionRegExp(atSign: false, url: false)!,
                    );
                    newTweetState.hashtags = hashtags;
                    newTweetState.mentions = mentions;
                    newTweet
                        .post()
                        .then((value) => Navigator.of(context).pop());
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Tweet cannot be empty'),
                        ),
                      );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Tweet'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewTweetFormOld extends ConsumerWidget {
  const NewTweetFormOld({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTweet = ref.watch(newTweetProvider.notifier);
    final newTweetState = ref.watch(newTweetProvider);
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: newTweetState.body,
              onChanged: newTweet.updateText,
              maxLines: 5,
              maxLength: 240,
              decoration: const InputDecoration(
                hintText: 'What\'s happening?',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (newTweetState.body?.isNotEmpty == true) {
                    newTweet
                        .post()
                        .then((value) => Navigator.of(context).pop());
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Tweet cannot be empty'),
                        ),
                      );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Tweet'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
