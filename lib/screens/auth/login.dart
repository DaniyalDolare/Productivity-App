import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../home_screen/tabs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

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
            child: isLoading
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await AuthService.signInWithGoogle().then((user) {
                        if (user != null) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Tabs()));
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                        }
                        return user;
                      }, onError: (Object error) {
                        setState(() {
                          isLoading = false;
                        });
                        debugPrint(
                            "Error occured while signing in: ${error.toString()}");
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Login with Google",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
