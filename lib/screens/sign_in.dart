import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebble/screens/pebble_home.dart';
import 'package:pebble/widgets/pebble_loading_animation.dart';
import 'package:pebble/widgets/sign_up_button.dart';
import 'package:pebble/widgets/sign_up_text_field.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackBar emptyFieldsSnackBar =
          SnackBar(content: Text('Do Not Leave Any Fields Empty'));
      _scaffoldKey.currentState.showSnackBar(emptyFieldsSnackBar);
      return;
    }

    FirebaseUser firebaseUser = await loginFirebaseUser(email, password);

    if (firebaseUser == null) {
      return;
    }

    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) => PebbleHome(),
        ),
        (route) => false);

    setState(() {
      isLoading = false;
    });
  }

  Future<FirebaseUser> loginFirebaseUser(String email, String password) async {
    AuthResult authResult;
    try {
      setState(() {
        isLoading = true;
      });
      authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e is PlatformException) {
        switch (e.code) {
          case 'ERROR_INVALID_EMAIL':
            SnackBar invalidEmailSnackBar =
                SnackBar(content: Text('Email Is Invalid'));
            _scaffoldKey.currentState.showSnackBar(invalidEmailSnackBar);
            break;
          case 'ERROR_WRONG_PASSWORD':
            SnackBar wrongPasswordSnackBar =
                SnackBar(content: Text("Wrong Password"));
            _scaffoldKey.currentState.showSnackBar(wrongPasswordSnackBar);
            break;
          default:
            SnackBar signInErrorSnackBar =
                SnackBar(content: Text('Error Signing In'));
            _scaffoldKey.currentState.showSnackBar(signInErrorSnackBar);
            break;
        }
        return null;
      }
    }
    return authResult.user;
  }

  Scaffold buildLoadingAnimation() {
    print('playing loading animation');
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: PebbleLoadingAnimation(),
      ),
    );
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset("assets/images/pebblelogowhite.png"),
                width: 150.0,
                height: 150.0,
              ),
            ),
            SignUpTextField(
              hintText: 'Email',
              isPassword: false,
              controller: emailController,
            ),
            SizedBox(
              height: 20.0,
            ),
            SignUpTextField(
              hintText: 'Password',
              isPassword: true,
              controller: passwordController,
            ),
            SizedBox(
              height: 20.0,
            ),
            SignUpButton(
              text: 'Sign In',
              onTap: signIn,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? buildLoadingAnimation() : buildSignInScreen();
  }
}
