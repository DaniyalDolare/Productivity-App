import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../auth/login.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      backgroundColor: Colors.grey[900],
      body: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user!.photoURL.toString()),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Text(
              user!.displayName!,
              style: const TextStyle(fontSize: 25),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Text(
              user!.email!,
            ),
            const Padding(padding: EdgeInsets.all(10)),
            TextButton(
              onPressed: () {
                AuthService.signOutGoogle();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false);
              },
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  primary: Colors.white,
                  backgroundColor: Colors.redAccent),
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
