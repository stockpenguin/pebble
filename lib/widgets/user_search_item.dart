import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebble/screens/direct_message.dart';

class UserSearchItem extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  UserSearchItem({
    this.profileImageUrl,
    this.username,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        child: ListTile(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => DirectMessage(
                  profileImageUrl: profileImageUrl,
                  username: username,
                ),
              ),
            );
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          leading: CircleAvatar(
            radius: 24.0,
            backgroundColor: Colors.transparent,
            backgroundImage: CachedNetworkImageProvider(
              profileImageUrl,
            ),
          ),
          title: Text(
            username,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

//Row(
//children: <Widget>[
//CircleAvatar(
//backgroundImage: CachedNetworkImageProvider(
//profileImageUrl,
//),
//),
//SizedBox(
//width: 16.0,
//),
//Text(
//username,
//),
//],
//),
