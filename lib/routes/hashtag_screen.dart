import 'package:flutter/material.dart';

import '../widgets/explore/hashtag_widget.dart';

import '../widgets/drawer/navigation_drawer_widget.dart';

class HashtagScreen extends StatelessWidget {
  const HashtagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      drawer: NavigationDrawerWidget(pageContext: context),
      body: const HashtagWidget(),
    );
  }
}
