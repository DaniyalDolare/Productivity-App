import 'package:example/tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User user;

  void click() {
    signInWithGoogle().then((user) => {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Tabs()))
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OutlineButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
          borderSide: BorderSide(color: Colors.redAccent),
          splashColor: Colors.redAccent,
          onPressed: () {
            click();
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("Login with Google"),
          ),
        ),
      ),
    );
  }
}
