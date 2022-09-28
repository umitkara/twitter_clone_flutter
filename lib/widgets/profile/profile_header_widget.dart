import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/providers.dart';

class ProfileHeaderWidget extends ConsumerWidget {
  const ProfileHeaderWidget({super.key});
  static late bool isFollowing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(otherUserProfileProvider).asData?.value;
    final currentUser = ref.watch(userStreamProvider).asData?.value;
    final currentUserProfile = ref.watch(userProfileProvider).asData?.value;
    final isMe = currentUser?.uid == user?.id;

    if (currentUserProfile != null) {
      isFollowing = currentUserProfile.followings?.contains(user!.id) ?? false;
    } else {
      isFollowing = false;
    }

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              Text(
                user.name ?? 'Loading...',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '@${user.username}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          !isMe
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    isFollowing
                        ? ElevatedButton(
                            onPressed: () {
                              currentUserProfile!.unfollow(user.id!);
                            },
                            child: const Text('Unfollow'),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              currentUserProfile!.follow(user.id!);
                            },
                            child: const Text('Follow'),
                          ),
                  ],
                )
              : const SizedBox(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Text(
                user.bio ??
                    'You have no bio yet. You can add one from your profile page.',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      user.followings == null
                          ? '0'
                          : (user.followings!.length - 1).toString(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Followings',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      user.followers?.length.toString() ?? '0',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Followers',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      user.tweets?.length.toString() ?? '0',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Tweets',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
