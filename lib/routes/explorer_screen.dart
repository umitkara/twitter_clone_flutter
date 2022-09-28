import 'package:flutter/material.dart';

import '../routes.dart';

import '../widgets/drawer/navigation_drawer_widget.dart';

import '../widgets/explore/explore_widget.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
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
      body: const ExploreWidget(),
    );
  }
}
