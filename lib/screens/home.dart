import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pebble/models/user.dart';
import 'package:pebble/screens/sign_in.dart';
import 'package:pebble/screens/sign_up.dart';
import 'package:pebble/widgets/sign_up_button.dart';
import 'package:shimmer/shimmer.dart';

// create Pebble User
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // boolean for if the user is authenticated or not
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
  }

  void signIn() {
    // take user to sign in page
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => SignIn(),
      ),
    );
  }

  void signUp() {
    // take user to sign up page
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => SignUp()),
    );
  }

  // while it is logging in, it will show the splash screen
  Scaffold buildSplashScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SizedBox(
          width: 250.0,
          height: 250.0,
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Theme.of(context).primaryColor,
            child: Image.asset('assets/images/pebblelogowhite.png'),
          ),
        ),
      ),
    );
  }

  // when it needs the user to sign in, it will show sign in screen
  Scaffold buildSignInScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset('assets/images/pebblelogowhite.png'),
                width: 200.0,
                height: 200.0,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Stack(
                children: <Widget>[
                  Text(
                    'Pebble_',
                    style: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.transparent,
                    ),
                  ),
                  TypewriterAnimatedTextKit(
                    text: ['Pebble'],
                    textStyle: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            SignUpButton(
              onTap: signIn,
              text: 'Sign In',
            ),
            SizedBox(
              height: 20.0,
            ),
            SignUpButton(
              onTap: signUp,
              text: 'Sign Up',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSignInScreen(context);
  }
}
