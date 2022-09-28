import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import './user.dart' as my_user;
import './tweet.dart';
import './tweet_types.dart';
import './message.dart' as my_messages;

/// This provider is used to get the current user from Firebase
final userStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// This provider is used to get the current user profile from Firestore
final userProfileProvider = StreamProvider.autoDispose<my_user.User?>((ref) {
  final userStream = ref.watch(userStreamProvider);
  final user = userStream.asData?.value;
  if (user == null) {
    return const Stream.empty();
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => my_user.User.fromJson(snapshot.data()!));
});

/// This provider serves current user's following list
final userFollowingsProvider = FutureProvider((ref) async {
  final userStream = ref.watch(userStreamProvider);
  final user = userStream.asData?.value;
  if (user == null) {
    return const Stream.empty();
  }
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  final userFollowings = userDoc.data()!['followings'] as List<dynamic>;

  return userFollowings;
});

/// This provider is used for creating a new tweet
final newTweetProvider = StateNotifierProvider.autoDispose<NewTweet, Tweet>(
  (ref) => NewTweet(),
);

class NewTweet extends StateNotifier<Tweet> {
  NewTweet() : super(Tweet());

  void updateText(String text) {
    state.body = text;
  }

  void setOriginalTweet(Tweet tweet) {
    final tweetDoc =
        FirebaseFirestore.instance.collection('tweets').doc(tweet.id);
    state.originalTweet = tweetDoc;
  }

  void setTweetType(TweetType type) {
    state.type = type;
  }

  Future<void> post() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not signed in');
    }
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data();
    if (userData == null) {
      throw Exception('User data is not found');
    }
    final userObj = my_user.User.fromJson(userData);
    final tweet = Tweet(
      body: state.body,
      createdAt: DateTime.now(),
      likes: [],
      media: [],
      originalTweet: state.originalTweet,
      replies: [],
      retweets: [],
      type: state.type ?? TweetType.tweet,
      user: Future.value(userObj),
      userId: user.uid,
      hashtags: state.hashtags,
      mentions: state.mentions,
    );
    final newTweetDoc = await FirebaseFirestore.instance
        .collection('tweets')
        .add(tweet.toJson());
    newTweetDoc.update({'id': newTweetDoc.id});
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'tweets': FieldValue.arrayUnion([newTweetDoc.id]),
    });
  }
}

/// This provider is used to regiter user to Firebase
final userRegisterProvider =
    StateNotifierProvider<UserRegister, Map<String, String>>(
  (ref) => UserRegister(),
);

class UserRegister extends StateNotifier<Map<String, String>> {
  UserRegister() : super({});

  Future<bool> checkUsernameExists(String username) async {
    final usernames = await FirebaseFirestore.instance
        .collection('credentials')
        .doc('usernames')
        .get();

    return (usernames.data()!['usernames'] as List<dynamic>).contains(username);
  }

  Future<bool> checkEmailExists(String email) async {
    final emails = await FirebaseFirestore.instance
        .collection('credentials')
        .doc('emails')
        .get();

    return (emails.data()!['emails'] as List<dynamic>).contains(email);
  }

  Future<bool> tryRegister() async {
    if (state['username'] == null) {
      return Future.value(false);
    }
    if (state['email'] == null) {
      return Future.value(false);
    }
    if (state['password'] == null) {
      return Future.value(false);
    }
    if (state['name'] == null) {
      return Future.value(false);
    }
    final UserCredential newUser;
    // Register user via Firebase Auth
    try {
      newUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: state['email']!,
        password: state['password']!,
      );
    } catch (e) {
      return Future.value(false);
    }
    FirebaseFirestore.instance
      // Save user info to Firestore
      ..collection('users').doc(newUser.user!.uid).set({
        'id': newUser.user!.uid,
        'name': state['name'],
        'username': state['username'],
        'email': state['email'],
        'bio': state['bio'] ?? '',
        'location': state['location'] ?? '',
        'website': state['website'] ?? '',
        'createdAt': DateTime.now(),
        'followers': [newUser.user!.uid],
        'followings': [],
        'likes': [],
        'tweets': [],
      })
      // Add username to username list
      ..collection('credentials').doc('usernames').update({
        'usernames': FieldValue.arrayUnion([state['username']]),
      })
      // Add email to email list
      ..collection('credentials').doc('emails').update({
        'emails': FieldValue.arrayUnion([state['email']]),
      });
    return Future.value(true);
  }
}

/// This provider holds information about which user to show when profile screen is shown
final whichProfileToShowProvider = StateProvider<String>(
  (ref) => '',
);

final otherUserProfileProvider = StreamProvider((ref) {
  final whichProfileToShow = ref.watch(whichProfileToShowProvider);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(whichProfileToShow)
      .snapshots()
      .map((snapshot) => my_user.User.fromJson(snapshot.data()!));
});

final whichProfileTweetQueryProvider = StateProvider<String>(
  (ref) => 'tweet',
);

final hashtagToShowProvider = StateProvider<String>(
  (ref) => '',
);

final chatIdToShowProvider = StateProvider<String>(
  (ref) => '',
);

final userSideProvider = StreamProvider((ref) {
  final currentUserId = ref.watch(userStreamProvider).asData?.value?.uid;
  final chatIdToShow = ref.watch(chatIdToShowProvider);
  if (currentUserId == null) {
    return Stream.value(null);
  }
  var msgDoc = FirebaseFirestore.instance
      .collection('messages')
      .doc(chatIdToShow)
      .withConverter(
        fromFirestore: (snapshot, _) =>
            my_messages.Message.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (message, _) => message.toJson(),
      )
      .snapshots();
  return msgDoc.map((snapshot) {
    final msg = snapshot.data();
    if (msg == null) {
      return null;
    }
    if (msg.senderId == currentUserId) {
      return my_messages.MessageFrom.sender;
    } else {
      return my_messages.MessageFrom.receiver;
    }
  });
});

// Experimental
// Paginated timeline provider

final timelineProvider = StateNotifierProvider<Timeline, List<Tweet>>((ref) {
  return Timeline();
});

class Timeline extends StateNotifier<List<Tweet>> {
  DocumentSnapshot? lastDocument;
  User? user;
  my_user.User? userProfile;

  Timeline({this.lastDocument}) : super([]) {
    init();
  }

  void init() async {
    user = FirebaseAuth.instance.currentUser!;

    userProfile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get()
        .then((value) => my_user.User.fromJson(value.data()!));

    state = await FirebaseFirestore.instance
        .collection('tweets')
        .where('userId', whereIn: userProfile?.followings)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get()
        .then((value) {
      lastDocument = value.docs.last;
      return value.docs
          .map((doc) => Tweet.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  void loadMore() async {
    try {
      final newTweets = await FirebaseFirestore.instance
          .collection('tweets')
          .where('userId', whereIn: userProfile?.followings)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(5)
          .get()
          .then((value) {
        lastDocument = value.docs[value.size - 1];
        return value.docs
            .map((doc) => Tweet.fromJson(doc.data(), doc.id))
            .toList();
      });
      state = [...state, ...newTweets];
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
