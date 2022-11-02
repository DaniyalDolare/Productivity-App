import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../home_screen/tabs.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Welcome",
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                  side: const BorderSide(color: Colors.redAccent)),
              onPressed: () async {
                await AuthService.signInWithGoogle().then((user) {
                  if (user != null) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Tabs()));
                  }
                  return user;
                }, onError: (Object error) {
                  debugPrint("Error occured while signing in: ${error.toString()}");
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("Login with Google"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
