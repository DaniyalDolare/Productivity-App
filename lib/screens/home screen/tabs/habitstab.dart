import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HabitsTab extends StatefulWidget {
  @override
  _HabitsTabState createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, right: 10, left: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "No Instagram",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('Streak: 2')
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        child: Icon(Icons.done),
                      ),
                      Container(
                        child: Icon(Icons.close),
                      ),
                      Container(
                        child: Icon(Icons.skip_next_sharp),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, right: 10, left: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Study",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('Streak: 5')
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        child: Icon(Icons.done),
                      ),
                      Container(
                        child: Icon(Icons.close),
                      ),
                      Container(
                        child: Icon(Icons.timelapse),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
