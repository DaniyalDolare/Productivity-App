import 'package:example/screens/home%20screen/tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:example/login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<User> _checkLoginState() async {
    User user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User is currently signed out!');
      return null;
    } else {
      print('User is signed in!');
      // FirebaseDatabase.instance.setPersistenceEnabled(true);
      return user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          primaryColor: Colors.red),
      home: FutureBuilder<User>(
          future: _checkLoginState(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              //User user = snapshot.data;
              // this is your user instance
              /// is because there is user already logged
              return Tabs();
            }
            // other way there is no user logged.
            return LoginPage();
          }),
    );
  }
}
