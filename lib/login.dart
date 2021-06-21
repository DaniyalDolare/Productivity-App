import 'package:example/screens/home%20screen/tabs.dart';
import 'package:flutter/material.dart';
import 'services/auth.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
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
                  side: BorderSide(color: Colors.redAccent)),
              onPressed: () async {
                await signInWithGoogle().then((user) => {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Tabs()))
                    });
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Login with Google"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
