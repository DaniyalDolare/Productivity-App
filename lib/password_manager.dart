import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordManager extends StatefulWidget {
  @override
  _PasswordManagerState createState() => _PasswordManagerState();
}

class _PasswordManagerState extends State<PasswordManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        iconTheme: IconThemeData(color: Colors.grey),
      ),
      backgroundColor: Colors.grey[900],
      body: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Facebook"),
                    Text(
                      "Daniyal",
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    )
                  ],
                ),
              ),
              IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: "Copied"));
                  })
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddPassword()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

class AddPassword extends StatefulWidget {
  @override
  _AddPasswordState createState() => _AddPasswordState();
}

class _AddPasswordState extends State<AddPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
      ),
      backgroundColor: Colors.grey[900],
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Name of App/Website",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  )),
            ),
            Padding(padding: EdgeInsets.all(7.0)),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                hintText: "Username/E-mail",
              ),
            ),
            Padding(padding: EdgeInsets.all(7.0)),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                hintText: "Password",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
