import 'package:flutter/material.dart';

import '../widgets/tweet_listview_widget.dart';

import '../widgets/drawer/navigation_drawer_widget.dart';

import '../routes.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Timeline'),
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
        body: const TweetListview(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteGenerator.newTweet);
          },
          child: const Icon(Icons.add),
        ));
  }
}

/*
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  TimelineScreenState createState() => TimelineScreenState();
}

class TimelineScreenState extends ConsumerState<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Timeline'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                // On this header, we will show authenticated user's informations.
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        body: const TweetListview());
  }
}
*/

// This is example Riverpod Provider code to lookup for help.
/*
class TimelineScreenState extends ConsumerState<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
      ),
      body: Container(
        child: Column(
          children: [
            Text('Hello ${ref.watch(pageCountProvider).toString()}',),
            ElevatedButton(
              onPressed: () {
                ref.read(pageCountProvider.notifier).increment();
              },
              child: const Text('Increment'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(pageCountProvider.notifier).decrement();
              },
              child: const Text('Decrement'),
            ),
          ],
        ),
      ),
    );
  }
}
*/