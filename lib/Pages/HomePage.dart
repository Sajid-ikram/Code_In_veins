import 'package:code_in_veins/Pages/all_future_contest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Individual_contets.dart';
import 'my_notifications.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    _kam();
    super.initState();
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Contest reminder'),
          content: Text(payload),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
  }

  _kam() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      await selectNotification(notificationAppLaunchDetails.payload);
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color(0xffF3F7F7),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(125),
                ),
              ),
              actions: [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.notifications),
                  iconSize: size.height * 0.035,
                  color: Color(0xff3b5360),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyNotifications(),
                      ),
                    );
                  },
                ),
              ],
              expandedHeight: size.height * 0.27,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Code In Veins",
                  style: GoogleFonts.gabriela(
                      color: Color(0xff3b5360), fontSize: size.height * 0.0198),
                ),
                background: Image(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/a.png'),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 15, bottom: 10),
                  child: Text(
                    'All Sites',
                    style: GoogleFonts.gabriela(
                      fontSize: size.width * 0.053,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff3b5360),
                    ),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => GestureDetector(
                  onTap: () {
                    if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllFutureContest(
                            types: "All Future Contest",
                          ),
                        ),
                      );
                    }
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllFutureContest(
                            types: "Within 24 hour",
                          ),
                        ),
                      );
                    }
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllFutureContest(
                            types: "Tomorrow's contest",
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          size.height * 0.04,
                        ),
                        bottomLeft: Radius.circular(
                          size.height * 0.04,
                        ),
                        bottomRight: Radius.circular(
                          size.height * 0.014,
                        ),
                        topRight: Radius.circular(
                          size.height * 0.014,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: size.height * 0.074,
                          width: size.height * 0.074,
                          decoration: BoxDecoration(
                              color: Color(0xff75cfb8),
                              borderRadius: BorderRadius.circular(400)),
                          padding: EdgeInsets.only(
                              left: size.height * 0.02,
                              right: size.height * 0.02,
                              top: size.height * 0.018,
                              bottom: size.height * 0.018),
                          child: Container(
                            child: Image(
                              fit: BoxFit.fill,
                              image: AssetImage('assets/time.png'),
                            ),
                          ),
                        ),
                        Container(
                            height: size.height * 0.075,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                            child: index == 0
                                ? _textForAllCon("All Contest within 24 Hour")
                                : index == 1
                                    ? _textForAllCon("All Contest in Tomorrow")
                                    : _textForAllCon("All Future Contest"))
                      ],
                    ),
                  ),
                ),
                childCount: 3,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
                  child: Text(
                    'Individual Site',
                    style: GoogleFonts.gabriela(
                      fontSize: size.width * 0.053,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff3b5360),
                    ),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _Individual(
                    size: size,
                    index: index,
                  );
                },
                childCount: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textForAllCon(String a) => Text(
    a,
    style: GoogleFonts.convergence(
      fontSize: MediaQuery.of(context).size.width * 0.048,
      fontWeight: FontWeight.w500,
      color: Color(0xff3b5360),
    ),
  );
}

class _Individual extends StatelessWidget {
  List<String> allSites = [
    "CodeForces",
    "CodeChef",
    "toph"
    "TopCoder",
    "AtCoder",
    "CSAcademy",
    "HackerRank",
    "HackerEarth",
    "LeetCode",
  ];

  _Individual({
    Key key,
    @required this.size,
    @required this.index,
  }) : super(key: key);
  final Size size;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualContest(
              types: allSites[index],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        height: size.height * 0.074,
        width: size.width * 0.98,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(
              size.height * 0.04,
            ),
            topRight: Radius.circular(
              size.height * 0.04,
            ),
            bottomLeft: Radius.circular(
              size.height * 0.014,
            ),
            topLeft: Radius.circular(
              size.height * 0.014,
            ),
          ),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: size.width * 0.5,
              padding: EdgeInsets.only(left: 15, right: 13, top: 5, bottom: 5),
              child: Image(
                fit: BoxFit.fill,
                alignment: Alignment.center,
                image: AssetImage('assets/${allSites[index]}.png'),
                //height: MediaQuery.of(context).size.height * 0.1,
                //width: double.infinity,
              ),
            ),
            Container(
              height: size.height * 0.074,
              width: size.height * 0.074,
              padding: EdgeInsets.all(size.height * 0.017),
              decoration: BoxDecoration(
                color: Color(0xff75cfb8),
                borderRadius: BorderRadius.circular(400),
              ),
              child: Image(
                alignment: Alignment.centerRight,
                image: AssetImage('assets/arrow.png'),
                height: MediaQuery.of(context).size.height * 0.03,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
