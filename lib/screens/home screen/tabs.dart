import 'package:example/screens/home%20screen/tabs/habitstab.dart';
import 'package:example/login.dart';
import 'package:example/password_manager.dart';
import 'package:example/settings.dart';
import 'package:example/screens/home%20screen/tabs/todotab.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart';
import 'tabs/notestab.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  User user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.red[400],
                padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.logout),
                          onPressed: () {
                            signOutGoogle();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                                (route) => false);
                          },
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              NetworkImage(this.user.photoURL.toString()),
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        Text(
                          user.displayName,
                          style: TextStyle(fontSize: 25),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text("Password Manager"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PasswordManager()));
                },
              )
            ],
          )),
        ),
        backgroundColor: Colors.grey[900],
        body: TabBarView(
          children: [NotesTab(), TodoTab(), HabitsTab()],
        ),
      ),
    );
  }
}
