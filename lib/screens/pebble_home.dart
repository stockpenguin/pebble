import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pebble/screens/home.dart';
import 'package:pebble/screens/sign_up.dart';
import 'package:pebble/utilities/constants.dart';
import 'package:pebble/widgets/user_search_item.dart';

import 'direct_message.dart';

class PebbleHome extends StatefulWidget {
  @override
  _PebbleHomeState createState() => _PebbleHomeState();
}

class _PebbleHomeState extends State<PebbleHome> {
  List<String> categories = [
    'Messages',
    'Games',
    'Following',
    'Followers',
    'Settings'
  ];
  int selectedCategoryIndex = 0;

  // scaffold key
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CollectionReference usersRef = Firestore.instance.collection('users');
  CollectionReference chatsRef = Firestore.instance.collection('chats');

  FirebaseUser currentUser;

  String currentUserEmail;
  String currentUserUid;

  TextEditingController userSearchTextEditingController =
      TextEditingController();

  PersistentBottomSheetController bottomSheetController;

  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String username) {
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isGreaterThanOrEqualTo: username)
        .getDocuments();
    bottomSheetController.setState(() {
      searchResultsFuture = users;
    });
  }

  @override
  void initState() {
    assignInitialValues();

    super.initState();
  }

  void assignInitialValues() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    currentUserEmail = currentUser.email;
    QuerySnapshot currentUserSnapshot = await usersRef
        .where('email', isEqualTo: currentUserEmail)
        .getDocuments();
    currentUserUid = currentUserSnapshot.documents.first.data['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: 500,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70.0,
                    width: MediaQuery.of(context).size.width * .8,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: NotificationListener(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowGlow();
                        return false;
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategoryIndex = index;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                categories[index],
                                style: index == selectedCategoryIndex
                                    ? kPebbleHomeCategoryTextStyle
                                    : kPebbleHomeCategoryTextStyle.copyWith(
                                        color: Colors.white38),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    icon: Icon(
                      Icons.add,
                    ),
                    color: Colors.white,
                    iconSize: 35.0,
                    onPressed: () {
                      bottomSheetController =
                          _scaffoldKey.currentState.showBottomSheet((context) {
                        return createNewChat();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0),
                    ),
                    color: Colors.white,
                  ),
                  child: StreamBuilder(
                    stream: chatsRef
                        .where('id', isGreaterThanOrEqualTo: currentUserUid)
                        .getDocuments()
                        .asStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      } else {
                        QuerySnapshot querySnapshot = snapshot.data;

                        if (querySnapshot.documents.isEmpty) {
                          return Container();
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.all(16.0),
                            itemCount: querySnapshot.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot chatSnapshot = querySnapshot
                                      .documents[
                                  querySnapshot.documents.length - 1 - index];

                              var messages = chatSnapshot['messages'];

                              Map<String, dynamic> message =
                                  messages[messages.length - 1];

                              Timestamp messageTime = message['createdAt'];
                              String messageUid = message['uid'];
                              String messageText = message['text'];

                              String chatId = chatSnapshot['id'];
                              String otherUserUid =
                                  chatId.replaceAll(currentUserUid, '');

                              print(currentUserUid);
                              print('otheruseruid is $otherUserUid');
                              print('messageUid is $messageUid');

                              bool isUser =
                                  messageUid == currentUserUid ? true : false;

                              print(messageUid);
                              print(currentUserUid);

                              // messageText

                              // get user pfp
//                              String pfpUrl =
//                                  await currentUserPfpUrl(messageUid);

                              return GestureDetector(
                                onTap: () async {
                                  QuerySnapshot user = await usersRef
                                      .where('id', isEqualTo: otherUserUid)
                                      .getDocuments();

                                  if (user.documents.isNotEmpty) {
                                    String username =
                                        user.documents.first['displayName'];
                                    String profileImageUrl =
                                        user.documents.first['photoUrl'];

                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => DirectMessage(
                                          profileImageUrl: profileImageUrl,
                                          username: username,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  color: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      FutureBuilder<QuerySnapshot>(
                                        future: usersRef
                                            .where('id',
                                                isEqualTo: otherUserUid)
                                            .getDocuments(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Container();
                                          } else {
                                            String photoUrl = snapshot.data
                                                .documents.first['photoUrl'];
                                            String username = snapshot.data
                                                .documents.first['displayName'];

                                            return Row(
                                              children: <Widget>[
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          photoUrl),
                                                  radius: 32.0,
                                                ),
                                                SizedBox(
                                                  width: 20.0,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      username,
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      messageText,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                      Column(
                                        children: <Widget>[],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> currentUserPfpUrl(String uid) async {
    QuerySnapshot userSnapshot =
        await usersRef.where('uid', isEqualTo: uid).getDocuments();
    String url = userSnapshot.documents.first.data['photoUrl'];
    print('returned url');
    return url;
  }

  // contents of modal sheet when user creates new conversation
  Container createNewChat() {
    double modalSheetHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Container(
      height: modalSheetHeight,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .85,
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Find User',
                  hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                controller: userSearchTextEditingController,
                onChanged: (text) {
                  handleSearch(text);
                },
              ),
            ),
          ),
          FutureBuilder(
            future: searchResultsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else if (/*differentusernames*/ false) {
                // check if the search includes the same user
                return Container();
              } else {
                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data.documents[index];
                      String profileImageUrl = doc.data['photoUrl'];
                      String username = doc.data['displayName'];

                      return UserSearchItem(
                        profileImageUrl: profileImageUrl,
                        username: username,
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
