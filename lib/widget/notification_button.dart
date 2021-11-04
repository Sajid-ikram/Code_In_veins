import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:timezone/timezone.dart' as tz;
import 'ErrorDialog.dart';

class NtButton extends StatefulWidget {
  const NtButton({
    Key key,
    @required this.differ,
    @required this.name,
    @required this.site,
  }) : super(key: key);
  final int differ;
  final String name;
  final String site;

  @override
  _NtButtonState createState() => _NtButtonState();
}

class _NtButtonState extends State<NtButton> with WidgetsBindingObserver {
  IconData a;
  bool isPressed = false;
  bool isLoading = true;
  String perm;
  Future<String> permissionStatusFuture;
  List<PendingNotificationRequest> pendingNotificationRequests = [];

  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";

  @override
  void initState() {
    permissionStatusFuture = getCheckNotificationPermStatus();
    _isPermitted();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  _isPermitted() async {
    perm = await permissionStatusFuture;
    pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if ((pendingNotificationRequests.singleWhere(
            (it) => it.id == widget.name.hashCode,
            orElse: () => null)) !=
        null) {
      isPressed = true;
    }
    if (!isPressed) {
      a = Icons.notifications_none_sharp;
    } else {
      a = Icons.notifications;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        permissionStatusFuture = getCheckNotificationPermStatus();
        _isPermitted();
      });
    }
  }

  Future<String> getCheckNotificationPermStatus() {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return permGranted;
        case PermissionStatus.unknown:
          return permUnknown;
        case PermissionStatus.provisional:
          return permProvisional;
        default:
          return null;
      }
    });
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _time(int value) async {
    String a = value == 0 ? "contest started" : "contest will start soon";
    await flutterLocalNotificationsPlugin.zonedSchedule(
      widget.name.hashCode,
      widget.site,
      widget.name,
      tz.TZDateTime.now(tz.local)
          .add(Duration(seconds: (widget.differ - value))),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'Code_In_Veins_id',
          'Code In Veins',
          'Code In Veins a contest reminder app',
          playSound: true,
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      payload: "${widget.site} $a",
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    int selectedTime = 600;
    return Material(
      type: MaterialType.transparency,
      child: isLoading
          ? IconButton(
              padding: EdgeInsets.only(top: 10, right: 12),
              icon: Icon(
                Icons.notifications_none_sharp,
                size: deviceHeight * 0.033,
                color: Color(0xFF314e52),
              ),
            )
          : IconButton(
              padding: EdgeInsets.only(top: 10, right: 12),
              iconSize: deviceHeight * 0.033,
              color: Color(0xFF314e52),
              splashColor: Colors.white,
              highlightColor: Colors.white,
              splashRadius: 1,
              icon: Icon(a),
              onPressed: () async {
                if (perm == "denied") {
                  _askForPer();
                } else {
                  if (a == Icons.notifications) {
                    _delete(widget.name.hashCode);
                    if (this.mounted) {
                      setState(() {
                        a = Icons.notifications_none_sharp;
                      });
                    }
                  } else {
                    await onTap(
                        ctx: context,
                        onPicked: (int value) {
                          selectedTime = value;
                        });

                    if (selectedTime > widget.differ) {
                      onError(
                          context, "Please select time less than start time");
                    } else {
                      _time(selectedTime);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Reminder added'),
                      ));
                      if (this.mounted) {
                        setState(() {
                          a = Icons.notifications;
                        });
                      }
                    }
                  }
                }
              }),
    );
  }

  _delete(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    setState(() {});
  }

  _askForPer() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notification permission is off'),
        content: Text("Please turn on notification for this app"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text("Setting"),
            onPressed: () {
              NotificationPermissions.requestNotificationPermissions();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

onTap({BuildContext ctx, Function(int) onPicked}) async {
  return Picker(
    adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
      const NumberPickerColumn(begin: 0, end: 99, suffix: Text(' hours')),
      const NumberPickerColumn(
          begin: 0, initValue: 10, end: 60, suffix: Text(' min'), jump: 5),
    ]),
    delimiter: <PickerDelimiter>[
      PickerDelimiter(
        child: Container(
          width: 30.0,
          alignment: Alignment.center,
          child: Icon(Icons.more_vert),
        ),
      )
    ],
    hideHeader: true,


    cancelText: "",
    confirmText: 'OK',
    confirmTextStyle:
        TextStyle(inherit: false, color: Color(0xff75cfb8), fontSize: 15),
    title: const Text('Remind me before'),
    selectedTextStyle: TextStyle(color: Color(0xff75cfb8)),
    onConfirm: (Picker picker, List<int> value) {
      Duration _duration = Duration(
        hours: picker.getSelectedValues()[0],
        minutes: picker.getSelectedValues()[1],
      );
      onPicked(_duration.inSeconds);
    },
  ).showDialog(ctx);
}
