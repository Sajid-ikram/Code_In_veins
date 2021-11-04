import 'package:code_in_veins/models/AllModel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widget/contest_details.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import '../widget/ErrorDialog.dart';

class AllFutureContest extends StatefulWidget {
  static const routeName = "All_future_contest";

  const AllFutureContest({
    Key key,
    @required this.types,
  }) : super(key: key);

  final String types;

  @override
  _CodeForcesState createState() => _CodeForcesState();
}

class _CodeForcesState extends State<AllFutureContest> {
  List<AllModel> allContest = [];
  bool isLoading = false;



  _getDataOnline() async {
    var url = 'https://kontests.net/api/v1/all';

    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }

    var response = await http.get(url);

    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }

    if (response.statusCode == 200) {
      if (widget.types == "All Future Contest") {
        var jsonResponse = convert.jsonDecode(response.body);

        for (var con in jsonResponse) {
          bool isBeforeNow = DateTime.now()
              .isBefore(DateTime.parse(con["start_time"]).toLocal());
          bool notCFGym = con["site"] == "CodeForces::Gym";
          if (isBeforeNow && !notCFGym) {
            allContest.add(AllModel.fromJson(con));
          }
        }
      } else if (widget.types == "Within 24 hour") {
        var jsonResponse = convert.jsonDecode(response.body);
        for (var con in jsonResponse) {
          bool isBeforeNow = DateTime.now()
              .isBefore(DateTime.parse(con["start_time"]).toLocal());

          DateTime now = DateTime.now();
          DateTime oneDaysFromNow = now.add(new Duration(days: 1));

          bool isWithin24Hour = oneDaysFromNow
              .isBefore(DateTime.parse(con["start_time"]).toLocal());

          bool notCFGym = con["site"] == "CodeForces::Gym";

          if (isBeforeNow && !isWithin24Hour && !notCFGym) {
            allContest.add(AllModel.fromJson(con));
          }
        }
      } else if (widget.types == "Tomorrow's contest") {
        var jsonResponse = convert.jsonDecode(response.body);

        for (var con in jsonResponse) {
          DateTime ConDate = DateTime.parse(con["start_time"]).toLocal();

          bool isBeforeNow = DateTime.now().isBefore(ConDate);

          DateTime now = DateTime.now();
          DateTime oneDaysFromNow = now.add(new Duration(days: 1));

          bool isTomorrow = false;
          if (oneDaysFromNow.year == ConDate.year &&
              oneDaysFromNow.month == ConDate.month &&
              oneDaysFromNow.day == ConDate.day) {
            isTomorrow = true;
          }
          bool notCFGym = con["site"] == "CodeForces::Gym";

          if (isBeforeNow && isTomorrow && !notCFGym) {
            allContest.add(AllModel.fromJson(con));
          }
        }
      }
      allContest.sort((a, b) => (a.startTime).compareTo(b.startTime));
    } else {
      return onError(context, "Having problem connecting to the server")
          .then((value) => Navigator.of(context).pop());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDataOnline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xff75cfb8),
          title: Text(
            widget.types,
            style: GoogleFonts.gabriela(
                color: Color(0xFF292f38), fontSize: deviceHeight * 0.026),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : allContest.isEmpty
                ? Center(
                    child: Text(
                      "No Contest Available",
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
