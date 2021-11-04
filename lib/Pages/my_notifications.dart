import 'package:code_in_veins/models/AllModel.dart';
import 'package:code_in_veins/widget/ErrorDialog.dart';
import 'package:code_in_veins/widget/contest_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class MyNotifications extends StatefulWidget {
  @override
  _MyNotificationsState createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications> {
  bool isLoading = true;



  List<AllModel> allContest = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<PendingNotificationRequest> pendingNotificationRequests = [];

  _getDataOnline() async {
    var url = 'https://kontests.net/api/v1/all';

    var response = await http.get(url);
    pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      for (var con in jsonResponse) {
        if (_checkIfExist(con["name"].hashCode)) {
          allContest.add(AllModel.fromJson(con));
        }
      }
      allContest.sort((a, b) => (a.site).compareTo(b.site));
    } else {
      return onError(context, "Having problem connecting to the server")
          .then((value) => Navigator.of(context).pop());
    }
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _checkIfExist(int id) {
    return pendingNotificationRequests.firstWhere(
                (itemToCheck) => itemToCheck.id == id,
                orElse: () => null) ==
            null
        ? false
        : true;
  }

  @override
  void initState() {
    _getDataOnline();

    super.initState();
  }

  _deleteAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    pendingNotificationRequests.clear();
    allContest.clear();
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color(0xffF3F7F7),
        appBar: AppBar(
          backgroundColor: Color(0xff75cfb8),
          title: Text(
            "Future Notifications",
            style: GoogleFonts.gabriela(
                color: Color(0xFF292f38), fontSize: deviceHeight * 0.026),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(Icons.delete),
                iconSize: deviceHeight * 0.030,
                color: Color(0xff374045),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("Delete All Reminder"),
                      content: Text("Do you want to delete all reminders"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("No"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Yes"),
                          onPressed: () {
                            _deleteAll();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  );
                }),
          ],
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : pendingNotificationRequests.isEmpty
                ? Center(
                    child: Text(
                      "No Reminder",
                      style: GoogleFonts.gabriela(
                          color: Color(0xFF292f38),
                          fontSize: deviceWidth * 0.044,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                : ListView.builder(
                    itemBuilder: (ctx, index) {
                      return IndividualDetails(
                        duration: allContest[index].duration,
                        name: allContest[index].name,
                        site: allContest[index].site,
                        endTime: allContest[index].endTime,
                        startTime: allContest[index].startTime,
                        url: allContest[index].url,
                      );
                    },
                    itemCount: allContest.length,
                  ),
      ),
    );
  }
}
