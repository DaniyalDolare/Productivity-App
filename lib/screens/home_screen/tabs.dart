import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/screens/auth/login.dart';
import 'package:productivity_app/screens/home_screen/tabs/habitstab.dart';
import 'package:productivity_app/screens/password_manager/password_manager.dart';
import 'package:productivity_app/screens/settings/settings.dart';
import 'package:productivity_app/services/auth.dart';

import 'tabs/notestab.dart';
import 'tabs/todotab.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with TickerProviderStateMixin {
  late TabController tabController;
  List<String> tabs = ["Notes", "Todos", "Habits"];
  User? user = FirebaseAuth.instance.currentUser;
  bool searching = false, automaticallyImplyLeading = true;
  FocusNode searchFocusNode = FocusNode();
  String searchText = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: automaticallyImplyLeading,
        title: searching
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: searchFocusNode,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "Search ${tabs[tabController.index]}"),
                ),
              )
            : const Text("Productivity"),
        actions: [
          IconButton(
            icon: Icon(searching ? Icons.close : Icons.search),
            onPressed: () {
              if (!searching) {
                searchFocusNode.requestFocus();
              } else {
                _searchController.clear();
                searchText = "";
              }
              setState(() {
                automaticallyImplyLeading = !automaticallyImplyLeading;
                searching = !searching;
              });
            },
          ),
        ],
        elevation: 0,
        bottom: searching
            ? null
            : TabBar(
                dividerColor: Colors.transparent,
                controller: tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                splashBorderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                indicator: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                tabs: const [
                  Tab(
                    child: Center(
                      child:
                          Column(children: [Icon(Icons.note), Text("Notes")]),
                    ),
                  ),
                  Tab(
                    child: Center(
                        child:
                            Column(children: [Icon(Icons.list), Text("TODO")])),
                  ),
                  Tab(
                    child: Center(
                        child: Column(
                            children: [Icon(Icons.list), Text("Habits")])),
                  ),
                ],
              ),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: "Sign out",
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await AuthService.signOutGoogle();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                            },
                          )),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            backgroundImage:
                                NetworkImage(user!.photoURL.toString()),
                          ),
                          const Padding(padding: EdgeInsets.all(10)),
                          Text(
                            user!.displayName!,
                            style: const TextStyle(
                                fontSize: 25, color: Colors.white),
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          Text(
                            user!.email!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: false, // TODO: Deactivate password manager
                  child: ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text("Password Manager"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PasswordManager()));
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Settings()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          NotesTab(
            isCurrent: tabController.index == 0,
            searchText: searchText,
          ),
          TodoTab(
              isCurrent: tabController.index == 1,
              searchController: _searchController),
          const HabitsTab(),
        ],
      ),
    );
  }
}
