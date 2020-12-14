import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'app_usage.dart';

class AppUsages extends StatefulWidget {
  @override
  _AppUsagesState createState() => _AppUsagesState();
}

class _AppUsagesState extends State<AppUsages> {
  List _infos = [];
  TextEditingController startdate = TextEditingController();

  void getUsageStats() async {
    DateTime startDate = DateTime.parse(startdate.text);
    try {
      _infos = [];
      // DateTime startDate = DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day);
      Map<String, dynamic> appData = Map();
      DateTime endDate = new DateTime.now();
      List<AppUsageInfo> appsWithUsage =
          await AppUsage.getAppUsage(startDate, endDate);
      appsWithUsage.sort((a, b) {
        return b.usage.compareTo(a.usage);
      });
      print(appsWithUsage.length);

      List<Application> installedApps =
          await DeviceApps.getInstalledApplications(
              includeAppIcons: true,
              includeSystemApps: true,
              onlyAppsWithLaunchIntent: true);
      print(installedApps.length);

      for (var appWithUsage in appsWithUsage) {
        if (appWithUsage.usage < Duration(minutes: 2)) {
          continue;
        }
        Application app =
            await DeviceApps.getApp(appWithUsage.packageName, true);
        if (app is ApplicationWithIcon) {
          appData = {
            'name': app.appName,
            'icon': app.icon,
            'usage': appWithUsage.usage
          };
          _infos.add(appData);
        }
      }

      print(_infos.length);
      setState(() {});
    } catch (exception) {
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
                    contentPadding: EdgeInsets.all(8.0),
                    // title: Text(
                    //     "com.${_infos[index].packageName}.${_infos[index].appName}"),
                    // trailing: Text(_infos[index].usage.toString()));
                    leading: CircleAvatar(
                      radius: 25.0,
                      backgroundImage: MemoryImage(_infos[index]['icon']),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(_infos[index]['name']),
                    trailing: Text(_infos[index]['usage'].toString()),
                  );
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
