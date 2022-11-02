import 'package:flutter/material.dart';

class HabitsTab extends StatefulWidget {
  const HabitsTab({Key? key}) : super(key: key);

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "No Instagram",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('Streak: 2')
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.done),
                      Icon(Icons.close),
                      Icon(Icons.skip_next_sharp)
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Study",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('Streak: 5')
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.done),
                      Icon(Icons.close),
                      Icon(Icons.timelapse)
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
