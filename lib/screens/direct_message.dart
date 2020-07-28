import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pebble/utilities/constants.dart';
import 'package:pebble/widgets/chat_bubble.dart';

class DirectMessage extends StatefulWidget {
  final String profileImageUrl;
  final String username;

  DirectMessage({this.profileImageUrl, this.username});

  @override
  _DirectMessageState createState() => _DirectMessageState();
}

class _DirectMessageState extends State<DirectMessage> {
  CollectionReference chatsRef = Firestore.instance.collection('chats');
  CollectionReference usersRef = Firestore.instance.collection('users');

  FirebaseUser currentUser;

  String chatID;
  String currentUserUid;
  String otherUserUid;

  TextEditingController messageTextEditingController = TextEditingController();

  @override
  void initState() {
    checkIfDirectMessageExists();
    super.initState();
  }

  Future<bool> checkIfDirectMessageExists() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    String currentUserEmail = currentUser.email;

    // get sender uid
    QuerySnapshot senderUsernameSnapshot = await usersRef
        .where('email', isEqualTo: currentUserEmail)
        .getDocuments();
    currentUserUid = senderUsernameSnapshot.documents.first.data['id'];

    // get recipient uid
    QuerySnapshot usernameSnapshot = await usersRef
        .where('displayName', isEqualTo: widget.username)
        .getDocuments();

    otherUserUid = usernameSnapshot.documents.first.data['id'];

    // set initial chatID
    if (chatID == null) {
      setState(() {
        chatID = '$currentUserUid$otherUserUid';
      });
    }

    chatID = '$currentUserUid$otherUserUid';
    String reverseChatID = '$otherUserUid$currentUserUid';

    // check if dm exists, return according value
    QuerySnapshot reverseChatIDSnapshot =
        await chatsRef.where('id', isEqualTo: reverseChatID).getDocuments();

    // if the reverse chatID doesn't exist
    if (reverseChatIDSnapshot.documents.isEmpty) {
      // check if normal chatID exists
      QuerySnapshot normalChatIDSnapshot =
          await chatsRef.where('id', isEqualTo: chatID).getDocuments();

      // if it doesn't, return false
      if (normalChatIDSnapshot.documents.isEmpty) {
        return false;

        // if it does, return true
      } else if (normalChatIDSnapshot.documents.length > 0) {
        return true;

        // otherwise return false
      } else {
        return false;
      }
    } else {
      // last case - the chat id is the reverse version
      setState(() {
        chatID = reverseChatID;
      });
      return true;
    }
  }

  void createDirectMessage(String message) async {
    /*
    messages database design - embedded document approach
    _________________________________________________________

    chats |
          |
          _ chatID || reverseChatID |
                                    |
                                    _ id
                                    _ timestamp
                                    _ messages |
                                               |
                                               _ 0 |
                                                   |
                                                   _ createdAt:
                                                   _ text:
                                                   _ uid:
                                               _ 1...
     */

    messageTextEditingController.clear();

    checkIfDirectMessageExists().then((bool directMessageExists) {
      print('checking');
      print(directMessageExists);
      if (directMessageExists) {
        // code to run if it exists
        print(chatID);
        chatsRef.document(chatID).get().then((doc) {
          chatsRef.document(chatID).updateData({
            'messages': FieldValue.arrayUnion([
              {
                'createdAt': DateTime.now(),
                'uid': currentUserUid,
                'text': message,
              }
            ])
          });
        });
      } else {
        // code to run if it doesn't exist
        chatsRef.document(chatID).get().then((doc) {
          chatsRef.document(chatID).setData({
            'id': chatID,
            'timestamp': DateTime.now(),
            'messages': [
              {
                'createdAt': DateTime.now(),
                'uid': currentUserUid,
                'text': message
              }
            ],
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        leading: BackButton(
          color: Colors.white,
        ),
        title: Container(
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage:
                    CachedNetworkImageProvider(widget.profileImageUrl),
              ),
              SizedBox(
                width: 25.0,
              ),
              Text(
                widget.username,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: chatsRef.document(chatID).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    DocumentSnapshot chatSnapshot = snapshot.data;

                    if (!chatSnapshot.exists) {
                      return Container();
                    } else {
                      Map<String, dynamic> chatDocument = chatSnapshot.data;
                      var messages = chatDocument['messages'];

                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.all(16.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          int reverseIndex = messages.length - index - 1;

                          Map<String, dynamic> message = messages[reverseIndex];

                          Timestamp messageTime = message['createdAt'];
                          String messageUid = message['uid'];
                          String messageText = message['text'];

                          bool isUser =
                              messageUid == currentUserUid ? true : false;

                          print(messageUid);
                          print(currentUserUid);

                          return ChatBubble(messageText, isUser);
                        },
                      );
                    }
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: messageTextEditingController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 22.0,
                    vertical: 16.0,
                  ),
                  hintText: 'Type Message',
                  hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send,
                    ),
                    onPressed: () {
                      String message = messageTextEditingController.text;
                      createDirectMessage(message);
                    },
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
