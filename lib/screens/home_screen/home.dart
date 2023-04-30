import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import '../auth/login.dart';
import 'tabs.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final userState = FirebaseAuth.instance.authStateChanges();
    return Consumer<ThemeProvider>(
      builder: (context, provider, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: provider.userTheme,
        theme: ThemeData(
          colorSchemeSeed: Colors.redAccent,
          appBarTheme: AppBarTheme(
              foregroundColor: Colors.black, backgroundColor: Colors.grey[100]),
          brightness: Brightness.light,
          // colorScheme: const ColorScheme.light(
          //   primary: Colors.redAccent,
          //   secondary: Colors.redAccent,
          //   onPrimary: Colors.black,
          //   onSecondary: Colors.white,
          //   onSurface: Colors.black,
          // ),
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.redAccent,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black12),
          brightness: Brightness.dark,
          // colorScheme: const ColorScheme.dark(
          //   primary: Colors.redAccent,
          //   secondary: Colors.redAccent,
          //   onPrimary: Colors.white,
          //   onSecondary: Colors.white,
          //   onSurface: Colors.white,
          // ),
        ),
        home: StreamBuilder<User?>(
          stream: userState,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final User? user = snapshot.data;
              return user != null ? const Tabs() : const LoginPage();
            }
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          },
        ),
      ),
    );
  }
}
