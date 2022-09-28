import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? bio;
  DateTime? createdAt;
  List<dynamic>? followings;
  List<dynamic>? followers;
  List<dynamic>? tweets;
  String? id;
  String? link;
  String? location;
  String? name;
  String? username;

  User({
    this.bio,
    this.createdAt,
    this.followings,
    this.followers,
    this.id,
    this.link,
    this.location,
    this.name,
    this.username,
    this.tweets,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      bio: json['bio'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      followings: json['followings'] as List<dynamic>?,
      followers: json['followers'] as List<dynamic>?,
      id: json['id'] as String,
      link: json['link'] as String?,
      location: json['location'] as String?,
      name: json['name'] as String,
      username: json['username'] as String,
      tweets: json['tweets'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'createdAt': createdAt,
      'followings': followings,
      'followers': followers,
      'id': id,
      'link': link,
      'location': location,
      'name': name,
      'username': username,
      'tweets': tweets,
    };
  }

  DocumentReference toDocumentReference() {
    return FirebaseFirestore.instance.collection('users').doc(id);
  }

  static Future<User> fromDocumentReference(
      DocumentReference documentReference) async {
    final snapshot = await documentReference.get();
    return User.fromJson(snapshot.data()! as Map<String, dynamic>);
  }

  static List<User> listFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() {
    return 'User(bio: $bio, createdAt: $createdAt, followings: $followings, followers: $followers, id: $id, link: $link, location: $location, name: $name, username: $username)';
  }

  void follow(String? userId) {
    if (userId == null) {
      return;
    }
    if (followings!.contains(userId)) {
      return;
    }
    followings!.add(userId);
    FirebaseFirestore.instance.collection('users').doc(id).update({
      'followings': FieldValue.arrayUnion([userId])
    });
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'followers': FieldValue.arrayUnion([id])
    });
  }

  void unfollow(String? userId) {
    if (userId == null) {
      return;
    }
    if (!followings!.contains(userId)) {
      return;
    }
    followings!.remove(userId);
    FirebaseFirestore.instance.collection('users').doc(id).update({
      'followings': FieldValue.arrayRemove([userId])
    });
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'followers': FieldValue.arrayRemove([id])
    });
  }
}
