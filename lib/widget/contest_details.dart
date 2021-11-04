import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ErrorDialog.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'notification_button.dart';

class IndividualDetails extends StatefulWidget {
  final String name;
  final String site;
  final String url;
  final String startTime;
  final String duration;
  final String endTime;

  IndividualDetails({
    @required this.name,
    @required this.startTime,
    @required this.url,
    @required this.site,
    @required this.duration,
    @required this.endTime,
  });

  @override
  _IndividualDetailsState createState() => _IndividualDetailsState();
}

class _IndividualDetailsState extends State<IndividualDetails> {


  List<String> allSites = [
    "CodeForces",
    "CodeChef",
    "TopCoder",
    "AtCoder",
    "CSAcademy",
    "HackerRank",
    "HackerEarth",
    "LeetCode",
    "Toph"
  ];

  bool isContains = false;

  _launchURL(String link, BuildContext context) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      return onError(context, "Can not open the link");
    }
  }

  String _changeTime(DateTime dt) {
    var dateFormat = DateFormat("dd-MM-yyyy hh:mm aa");
    var utcDate = dateFormat.format(DateTime.parse(dt.toString()));
    var localDate = dateFormat.parse(utcDate, true).toLocal().toString();
    return dateFormat.format(DateTime.parse(localDate));
  }

  @override
  void initState() {
    _local();
    isContains = allSites.contains(widget.site);
    super.initState();

  }

  void _local() async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final difference =
        DateTime.parse(widget.startTime).difference(DateTime.now()).inSeconds;

    int endTimeForTimer =
        DateTime.now().millisecondsSinceEpoch + 1000 * difference;

    return Container(
      margin: EdgeInsets.only(
        right: deviceWidth * 0.03,
        left: deviceWidth * 0.03,
        top: deviceWidth * 0.04,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0xFFd0ecfd), blurRadius: 5.0),
        ],
        border: Border.all(
          color: Color(0xFF9ad3bc),
          width: 2,
        ),
      ),
      width: deviceWidth * 0.96,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5, left: 15),
                height: deviceHeight * 0.05,
                width: deviceWidth * 0.5,
                child: isContains ? Image(
                  alignment: Alignment.center,
                  image: AssetImage('assets/${widget.site}.png'),
                ) : Text("${widget.site}",style: GoogleFonts.convergence(
                    color: Color(0xff236a4e),
                    fontSize: deviceWidth * 0.056,
                    fontWeight: FontWeight.w600),),
              ),
              NtButton(
                differ: difference,
                site: widget.site,
                name: widget.name,
              )
            ],
          ),
          Divider(
            thickness: 1,
            color: Color(0xFF9ad3bc),
            endIndent: 10,
            indent: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 12),
            child: _rows(deviceWidth, "Name", widget.name),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 12),
            child: _rows(deviceWidth, "Start",
                _changeTime(DateTime.parse(widget.startTime))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 12),
            child: _rows(deviceWidth, "End",
                _changeTime(DateTime.parse(widget.endTime))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: _rows(
                deviceWidth,
                "Duration",
                _getDuration(Duration(
                        seconds: int.parse(
                            double.parse(widget.duration).round().toString())))
                    .toString()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Start In :   ",
                  style: GoogleFonts.convergence(
                      color: Color(0xFF292f38),
                      fontSize: deviceWidth * 0.044,
                      fontWeight: FontWeight.w600),
                ),
                Flexible(
                  child: CountdownTimer(
                    endWidget: Text("Started",
                        style: GoogleFonts.convergence(
                            color: Color(0xff9b5151),
                            fontSize: deviceWidth * 0.040)),
                    textStyle: GoogleFonts.gabriela(
                        color: Color(0xff9b5151),
                        fontSize: deviceWidth * 0.040),
                    endTime: endTimeForTimer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Open In web :   ",
                  style: GoogleFonts.convergence(
                      color: Color(0xFF292f38),
                      fontSize: deviceWidth * 0.044,
                      fontWeight: FontWeight.w600),
                ),
                Flexible(
                  child: IconButton(
                      color: Colors.green[800],
                    icon: Icon(Icons.open_in_browser_rounded),
                      onPressed: () {
                        _launchURL(widget.url, context);
                      }
                  )
                ),
              ],
            ),
          ),

          SizedBox(height: deviceHeight * 0.009),
        ],
      ),
    );
  }

  Row _rows(double _size, String name, String info) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "$name :   ",
          style: GoogleFonts.convergence(
              color: Color(0xFF292f38),
              fontSize: _size * 0.044,
              fontWeight: FontWeight.w600),
        ),
        Flexible(
          child: Text(
            info,
            style: GoogleFonts.convergence(
                color: Color(0xFF292f38), fontSize: _size * 0.041),
          ),
        ),
      ],
    );
  }

  String _getDuration(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    return "${twoDigits(duration.inHours)} Hour / $twoDigitMinutes Minutes";
  }
}
