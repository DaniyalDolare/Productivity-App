import 'package:example/add_data.dart';
import 'package:example/login.dart';
import 'package:example/settings.dart';
import 'package:example/todotab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notestab.dart';

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

            /// other way there is no user logged.
            return LoginPage();
          }),
    );
  }
}

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  User user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    // FirebaseDatabase.instance.goOffline();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          backgroundColor: Colors.black12,
          title: Text("Productivity"),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Setttings()));
              },
            ),
          ],
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.grey[900]),
            tabs: [
              Tab(
                child: Center(
                  child: Column(children: [Icon(Icons.note), Text("Notes")]),
                ),
              ),
              Tab(
                child: Center(
                    child: Column(children: [Icon(Icons.list), Text("TODO")])),
              ),
              Tab(
                child: Center(
                  child: Column(
                      children: [Icon(Icons.show_chart), Text("Add data")]),
                ),
              ),
            ],
          ),
        ),
        drawer: SafeArea(
          child: Drawer(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(icon: Icon(Icons.logout), onPressed: null)),
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(this.user.photoURL.toString()),
                ),
              ),
              Padding(padding: EdgeInsets.all(10)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.displayName,
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.email,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          )),
        ),
        backgroundColor: Colors.grey[900],
        body: TabBarView(
          children: [NotesTab(), TodoTab(), AppUsages()],
        ),
      ),
    );
  }
}
