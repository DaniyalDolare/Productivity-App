import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';

class AppUsages extends StatefulWidget {
  @override
  _AppUsagesState createState() => _AppUsagesState();
}

class _AppUsagesState extends State<AppUsages> {
  List<AppUsageInfo> _infos = [];
  TextEditingController startdate = TextEditingController();

  void getUsageStats() async {
    DateTime startDate = DateTime.parse(startdate.text);
    try {
      // DateTime startDate = DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day);

      DateTime endDate = new DateTime.now();
      List<AppUsageInfo> infos = await AppUsage.getAppUsage(startDate, endDate);
      setState(() {
        _infos = infos;
      });
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  @override
  void dispose() {
    super.dispose();
    startdate.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: startdate,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(hintText: "2020-11-19"),
          ),
          Flexible(
            child: ListView.builder(
                itemCount: _infos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(
                          "com.${_infos[index].packageName}.${_infos[index].appName}"),
                      trailing: Text(_infos[index].usage.toString()));
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: getUsageStats,
          child: Icon(Icons.file_download)),
    );
  }
}
