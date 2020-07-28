import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebble/models/user.dart';
import 'package:pebble/screens/pebble_home.dart';
import 'package:pebble/widgets/pebble_loading_animation.dart';
import 'package:pebble/widgets/sign_up_button.dart';
import 'package:pebble/widgets/sign_up_text_field.dart';
import 'package:uuid/uuid.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference usersRef = Firestore.instance.collection("users");
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StorageReference profilePicturesRef = FirebaseStorage().ref().child("pfp/");
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  bool isLoading = false;

  void signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      SnackBar emptyFieldsSnackBar =
          SnackBar(content: Text('Do Not Leave Any Fields Empty'));
      _scaffoldKey.currentState.showSnackBar(emptyFieldsSnackBar);
    }

    FirebaseUser firebaseUser = await createFirebaseUser(email, password);

    if (firebaseUser == null) {
      return;
    }

    // create uid
    Uuid userUid = Uuid();
    String userUidString = userUid.v4();

    String pfpURL =
        await profilePicturesRef.child("default_pfp.png").getDownloadURL();

    // create document
    usersRef.document(userUidString).setData({
      'id': userUidString,
      'bio': 'Bio',
      'email': email,
      'photoUrl': pfpURL,
      'displayName': username,
      'timestamp': DateTime.now(),
    });

    // create User from document
    usersRef.document(userUidString).get().then((doc) {
      if (!doc.exists) {
        User currentUser = User.fromDocument(doc);
      } else {
        final SnackBar userExistsSnackBar =
            SnackBar(content: Text('User Already Exists, Retry'));
        _scaffoldKey.currentState.showSnackBar(userExistsSnackBar);
      }
    });

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

  Future<FirebaseUser> createFirebaseUser(String email, String password) async {
    AuthResult authResult;
    try {
      setState(() {
        isLoading = true;
      });
      authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e is PlatformException) {
        switch (e.code) {
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            SnackBar emailInUseSnackBar =
                SnackBar(content: Text('Error: Email Is Already In Use'));
            _scaffoldKey.currentState.showSnackBar(emailInUseSnackBar);
            break;

          case 'ERROR_WEAK_PASSWORD':
            SnackBar weakPasswordSnackBar =
                SnackBar(content: Text('Error: Password Is Too Weak'));
            _scaffoldKey.currentState.showSnackBar(weakPasswordSnackBar);
            break;

          case 'ERROR_INVALID_EMAIL':
            SnackBar invalidEmailSnackBar =
                SnackBar(content: Text('Error: Email Is Invalid'));
            _scaffoldKey.currentState.showSnackBar(invalidEmailSnackBar);
            break;
          default:
            SnackBar signUpErrorSnackBar =
                SnackBar(content: Text('Error Signing In'));
            _scaffoldKey.currentState.showSnackBar(signUpErrorSnackBar);
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

  Scaffold buildSignUpScreen() {
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
                child: Image.asset('assets/images/pebblelogowhite.png'),
                width: 150.0,
                height: 150.0,
              ),
            ),
            Container(
              width: 300.0,
              child: Center(
                child: SignUpTextField(
                  hintText: 'Email',
                  isPassword: false,
                  controller: emailController,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SignUpTextField(
              hintText: 'Username',
              isPassword: false,
              controller: usernameController,
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
    return isLoading ? buildLoadingAnimation() : buildSignUpScreen();
  }
}
