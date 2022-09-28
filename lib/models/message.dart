import 'package:cloud_firestore/cloud_firestore.dart';

import './user.dart';

class Message {
  String? id;
  DateTime? createdAt;
  List<dynamic>? messages;
  String? senderId;
  String? receiverId;
  List<dynamic>? ids;

  Message({
    this.id,
    this.createdAt,
    this.messages,
    this.senderId,
    this.receiverId,
    this.ids,
  });

  factory Message.fromJson(Map<String, dynamic> json, String? id) {
    return Message(
      id: id,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      messages: json['messages'] as List<dynamic>?,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      ids: json['ids'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'messages': messages,
      'senderId': senderId,
      'receiverId': receiverId,
      'ids': ids,
    };
  }

  @override
  String toString() {
    return 'Message(createdAt: $createdAt, messages: $messages, senderId: $senderId, receiverId: $receiverId)';
  }

  Future<User> getSenderUser() async {
    final senderUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();
    return User.fromJson(senderUserDoc.data()!);
  }

  Future<User> getReceiverUser() async {
    final receiverUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    return User.fromJson(receiverUserDoc.data()!);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMessages() async {
    return FirebaseFirestore.instance
        .collection('messages')
        .doc(id)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .get();
  }

  static Future<Message> createNewMessage(
      String senderId, String receiverId) async {
    final message = Message(
      createdAt: DateTime.now(),
      messages: [],
      senderId: senderId,
      receiverId: receiverId,
      ids: [senderId],
    );
    final newMessageDoc = await FirebaseFirestore.instance
        .collection('messages')
        .add(message.toJson());
    newMessageDoc.update({'id': newMessageDoc.id});
    var newMessage = await newMessageDoc.get();
    return Message.fromJson(newMessage.data()!, newMessage.id);
  }

  void newChatMessage(String body, MessageFrom from, bool isFirstMessage) {
    if (isFirstMessage) {
      // save to firestore
      FirebaseFirestore.instance.collection('messages').doc(id).update({
        'ids': FieldValue.arrayUnion([senderId, receiverId])
      });
    }
    final newMessage = ChatMessage(
      body: body,
      from: from,
      createdAt: DateTime.now(),
      isRead: false,
    );
    FirebaseFirestore.instance
        .collection('messages')
        .doc(id)
        .collection('messages')
        .add(newMessage.toJson());
  }

  void newChatMessageOld(String body, MessageFrom from, bool isFirstMEssage) {
    if (isFirstMEssage) {
      ids!.add(receiverId);
    }
    messages!.add({
      'body': body,
      'from': from == MessageFrom.sender ? senderId : receiverId,
      'createdAt': DateTime.now(),
      'isRead': false,
    });
    FirebaseFirestore.instance
        .collection('messages')
        .doc(id)
        .update({'messages': messages});
  }

  String getSideById(String userId) {
    if (userId == senderId) {
      return 'sender';
    } else if (userId == receiverId) {
      return 'receiver';
    } else {
      return 'unknown';
    }
  }

  // ? Not sure if this function is belongs to here?
  static Future<bool> isChatExist(String userId1, String userId2) async {
    final messageDoc1 = await FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: userId1)
        .where('senderId', isEqualTo: userId2)
        .get();
    final messageDoc2 = await FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: userId2)
        .where('senderId', isEqualTo: userId1)
        .get();
    return messageDoc1.docs.isNotEmpty || messageDoc2.docs.isNotEmpty;
  }

  // ? Not sure if this function is belongs to here?
  static Future<String> getExistingChatIdByUserIds(
      String userId1, String userId2) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: userId1)
        .where('senderId', isEqualTo: userId2)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return value.docs[0].id;
      }
      return FirebaseFirestore.instance
          .collection('messages')
          .where('receiverId', isEqualTo: userId2)
          .where('senderId', isEqualTo: userId1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          return value.docs[0].id;
        }
        return '';
      });
    });
  }
}

enum MessageFrom {
  sender,
  receiver,
}

class ChatMessage {
  String? body;
  DateTime? createdAt;
  MessageFrom? from;
  bool? isRead;

  ChatMessage({
    this.body,
    this.createdAt,
    this.from,
    this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      body: json['body'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      from:
          json['from'] == 'sender' ? MessageFrom.sender : MessageFrom.receiver,
      isRead: json['isRead'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'createdAt': createdAt,
      'from': from == MessageFrom.sender ? 'sender' : 'receiver',
      'isRead': isRead,
    };
  }

  @override
  String toString() {
    return 'ChatMessage(body: $body, createdAt: $createdAt, from: $from, isRead: $isRead)';
  }
}
