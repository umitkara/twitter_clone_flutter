import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../models/providers.dart';

import '../../routes.dart';

class NavigationDrawerWidget extends ConsumerWidget {
  const NavigationDrawerWidget({
    super.key,
    required this.pageContext,
  });

  final BuildContext pageContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).asData?.value;
    final whichProfileToShow = ref.watch(whichProfileToShowProvider.notifier);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                    Text(
                      user?.name ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Text(
                      user?.bio ??
                          'You have no bio yet. You can add one from your profile page.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          user?.followings == null
                              ? '0'
                              : (user!.followings!.length - 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Followings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          user?.followers?.length.toString() ?? '0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Followers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(pageContext, RouteGenerator.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              whichProfileToShow.state = user?.id ?? '';
              Navigator.pushNamed(pageContext, RouteGenerator.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Explore'),
            onTap: () {
              Navigator.pushNamed(pageContext, RouteGenerator.explore);
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messages'),
            onTap: () {
              Navigator.pushNamed(pageContext, RouteGenerator.message);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Sign Out'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  pageContext, RouteGenerator.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
