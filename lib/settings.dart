import 'package:example/services/auth.dart';
import 'package:example/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Setttings extends StatefulWidget {
  @override
  _SetttingsState createState() => _SetttingsState();
}

class _SetttingsState extends State<Setttings> {
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        iconTheme: IconThemeData(color: Colors.grey),
      ),
      backgroundColor: Colors.grey[900],
      body: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.photoURL.toString()),
              ),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text(
              user.displayName,
              style: TextStyle(fontSize: 25),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text(
              user.email,
            ),
            Padding(padding: EdgeInsets.all(10)),
            TextButton(
              onPressed: () {
                signOutGoogle();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false);
              },
              child: Text("LogOut"),
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  primary: Colors.white,
                  backgroundColor: Colors.redAccent),
            )
          ],
        ),
      ),
    );
  }
}
