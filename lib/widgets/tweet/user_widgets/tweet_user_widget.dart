import 'package:flutter/material.dart';

import '../../../models/user.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/providers.dart';

import 'package:timeago/timeago.dart' as timeago;

class TweetUser extends ConsumerWidget {
  const TweetUser({super.key, required this.user, required this.tweetPostTime});

  final Future<User>? user;
  final DateTime? tweetPostTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whichProfileToShow = ref.watch(whichProfileToShowProvider.notifier);

    return FutureBuilder(
      future: user,
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  whichProfileToShow.state = snapshot.data!.id!;
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text(
                  snapshot.data!.name ?? 'Loading...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                snapshot.data != null
                    ? '@${snapshot.data!.username}'
                    : 'Loading...',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 5),
              Text(
                timeago.format(tweetPostTime ?? DateTime.now()),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          );
        } else {
          return const Text('Loading...');
        }
      }),
    );
  }
}
