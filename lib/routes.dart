import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import './routes/timeline_screen.dart';
import './routes/signin_screen.dart';
import './routes/signup_screen.dart';
import './routes/new_tweet_screen.dart';
import './routes/profile_screen.dart';
import './routes/explorer_screen.dart';
import './routes/hashtag_screen.dart';
import './routes/message_screen.dart';
import './routes/chat_screen.dart';
import './routes/search_screen.dart';

/*
 * For now using default routing system is fine, but fore ease of use and built-in transition system
 * Fluro(https://pub.dev/packages/fluro) could be used in the future.
 */

class RouteGenerator {
  static const String home = '/';
  static const String login = '/singin';
  static const String register = '/signup';
  static const String newTweet = '/new-tweet';
  static const String profile = '/profile';
  static const String explore = '/explore';
  static const String hashtag = '/hashtag';
  static const String message = '/message';
  static const String chat = '/chat';
  static const String search = '/search';

  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return FirebaseAuth.instance.currentUser == null
            ? MaterialPageRoute(
                builder: (_) => const SigninScreen(),
              )
            : MaterialPageRoute(
                builder: (_) => const TimelineScreen(),
              );
      case login:
        return MaterialPageRoute(builder: (_) => const SigninScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case newTweet:
        return MaterialPageRoute(builder: (_) => const NewTweetScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case explore:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());
      case hashtag:
        return MaterialPageRoute(builder: (_) => const HashtagScreen());
      case message:
        return MaterialPageRoute(builder: (_) => const MessageScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => ErrorWidget('Route not found'));
    }
  }
}
