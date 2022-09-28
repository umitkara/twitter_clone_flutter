import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import './tweet_types.dart';
import './user.dart';

class Tweet {
  String? id;
  String? body;
  DateTime? createdAt;
  List<dynamic>? likes;
  List<dynamic>? media;
  dynamic originalTweet;
  List<dynamic>? replies;
  List<dynamic>? retweets;
  TweetType? type;
  Future<User>? user;
  String? userId;
  List<dynamic>? hashtags;
  List<dynamic>? mentions;

  Tweet({
    this.id,
    this.body,
    this.createdAt,
    this.likes,
    this.media,
    this.originalTweet,
    this.replies,
    this.retweets,
    this.type,
    this.user,
    this.userId,
    this.hashtags,
    this.mentions,
  });

  factory Tweet.fromJson(Map<String, dynamic> json, String? id) {
    final Future<Tweet>? orgTweet;
    if (json['originalTweet'] == null) {
      orgTweet = null;
    } else {
      orgTweet = (json['originalTweet'] as DocumentReference).get().then(
          (value) =>
              Tweet.fromJson(value.data()! as Map<String, dynamic>, value.id));
    }
    return Tweet(
      id: id,
      body: json['body'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      likes: json['likes'] as List<dynamic>?,
      media: json['media'] as List<dynamic>?,
      originalTweet: orgTweet,
      replies: json['replies'] as List<dynamic>?,
      retweets: json['retweets'] as List<dynamic>?,
      type: _getTypeFromString(json['type']),
      user: (json['user'] as DocumentReference).get().then(
          (value) => User.fromJson(value.data()! as Map<String, dynamic>)),
      userId: json['userId'] as String?,
      hashtags: json['hashtags'] as List<dynamic>?,
      mentions: json['mentions'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    return {
      'id': id,
      'body': body,
      'createdAt': createdAt,
      'likes': likes ?? [],
      'originalTweet': originalTweet,
      'replies': replies ?? [],
      'retweets': retweets ?? [],
      'type': type?.name,
      'user': userDoc,
      'userId': userId,
      'hashtags': hashtags ?? [],
      'mentions': mentions ?? [],
    };
  }

  @override
  String toString() {
    return 'Tweet(id: $id, body: $body, createdAt: $createdAt, likes: $likes, media: $media, originalTweet: $originalTweet, replies: $replies, retweets: $retweets, type: $type, userId: $userId)';
  }

  void _like(String? userId) {
    // Add current user to likes
    likes!.add(userId);
    // Update tweet data
    FirebaseFirestore.instance.collection('tweets').doc(id).update({
      'likes': FieldValue.arrayUnion([userId])
    });
    // Add liked tweet to users liked tweets
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'likes': FieldValue.arrayUnion([id])
      });
    }
  }

  void _dislike(String? userId) {
    // Remove current user from likes
    likes!.remove(userId);
    // Update tweet data
    FirebaseFirestore.instance
        .collection('tweets')
        .doc(id)
        .update({'likes': likes});
    // Remove liked tweet from users liked tweets
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'likes': FieldValue.arrayRemove([id])
      });
    }
  }

  void likeDislike(String? userId) {
    if (likes!.contains(userId)) {
      _dislike(userId);
    } else {
      _like(userId);
    }
  }

  void _retweet(String? userId) async {
    // Add current user to retweets
    retweets!.add(userId);
    // Get tweet data and update retweet count
    final tweetDoc = FirebaseFirestore.instance.collection('tweets').doc(id);
    tweetDoc.update({
      'retweets': FieldValue.arrayUnion([userId])
    });
    // Create a new tweet and attach current tweet as original tweet
    final newRetweet = Tweet(
      body: "",
      type: TweetType.retweet,
      userId: userId,
      createdAt: DateTime.now(),
      originalTweet: tweetDoc,
    );
    // Add new tweet to database
    final newRetweetDoc = await FirebaseFirestore.instance
        .collection('tweets')
        .add(newRetweet.toJson());
    newRetweetDoc.update({
      'id': newRetweetDoc.id,
    });
    // Add new tweet to current user's tweets
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'tweets': FieldValue.arrayUnion([newRetweetDoc.id])
      });
    }
  }

  void _unretweet(String? userId) async {
    retweets!.remove(userId);
    final tweetDoc = FirebaseFirestore.instance.collection('tweets').doc(id);
    tweetDoc.update({
      'retweets': FieldValue.arrayRemove([userId])
    });
    // Not a good soliton. When tweets get larger it's going to take time.
    // Find a better way to do this.
    final currentUser =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final retweetDoc = await FirebaseFirestore.instance
        .collection('tweets')
        .where('originalTweet', isEqualTo: tweetDoc)
        .where('userId', isEqualTo: currentUser.id)
        .get();
    retweetDoc.docs.first.reference.delete();
    currentUser.update({
      'tweets': FieldValue.arrayRemove([retweetDoc.docs.first.id])
    });
  }

  void retweetUnretweet(String? userId) {
    if (retweets!.contains(userId)) {
      _unretweet(userId);
    } else {
      _retweet(userId);
    }
  }

  void reply(String? userId) {
    // Add current user to replies
    replies!.add(userId);
    // Update tweet data
    FirebaseFirestore.instance.collection('tweets').doc(id).update({
      'replies': FieldValue.arrayUnion([userId])
    });
    // Add replied tweet to users replied tweets
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'replies': FieldValue.arrayUnion([id])
      });
    }
  }
}

TweetType _getTypeFromString(String? type) {
  switch (type) {
    case 'tweet':
      return TweetType.tweet;
    case 'retweet':
      return TweetType.retweet;
    case 'reply':
      return TweetType.reply;
    default:
      return TweetType.tweet;
  }
}
