import 'package:flutter/material.dart';

import '../widgets/drawer/navigation_drawer_widget.dart';

import '../widgets/profile/profile_tweet_listview_widget.dart';
import '../widgets/profile/profile_retweet_listview_widget.dart';
import '../widgets/profile/profile_reply_listview_widget.dart';

import '../routes.dart';

// This is a very bad approach. Instead of creating different widget for each view
// we should hold the view in a provider and change it when user clicks on a tab.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentId = 0;
  final _pageViewController = PageController();

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RouteGenerator.search);
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      drawer: NavigationDrawerWidget(pageContext: context),
      body: PageView(
        controller: _pageViewController,
        children: const <Widget>[
          ProfileTweetListviewWidget(),
          ProfileRetweetListviewWidget(),
          ProfileReplyListviewWidget(),
        ],
        onPageChanged: (index) {
          setState(() {
            _currentId = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteGenerator.newTweet);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentId,
        onTap: (int index) {
          _pageViewController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut,
          );
          // setState(() {
          //   _currentId = index;
          // });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tweets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Retweets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reply),
            label: 'Replies',
          ),
        ],
      ),
    );
  }
}
