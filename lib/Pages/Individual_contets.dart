import 'package:code_in_veins/models/IndividualModel.dart';
import 'package:code_in_veins/widget/ErrorDialog.dart';
import 'package:code_in_veins/widget/contest_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class IndividualContest extends StatefulWidget {
  static const routeName = "All_future_contest";

  const IndividualContest({
    Key key,
    @required this.types,
  }) : super(key: key);

  final String types;

  @override
  _CodeForcesState createState() => _CodeForcesState();
}

class _CodeForcesState extends State<IndividualContest> {
  List<IndividualModel> individualModelList = [];

  bool isLoading = false;

  _main() async {
    var url;

    if (widget.types == "CodeForces") {
      url = 'https://www.kontests.net/api/v1/codeforces';
    } else if (widget.types == "CodeChef") {
      url = 'https://www.kontests.net/api/v1/code_chef';
    } else if (widget.types == "TopCoder") {
      url = 'https://www.kontests.net/api/v1/top_coder';
    } else if (widget.types == "AtCoder") {
      url = 'https://www.kontests.net/api/v1/at_coder';
    } else if (widget.types == "CSAcademy") {
      url = 'https://www.kontests.net/api/v1/cs_academy';
    } else if (widget.types == "HackerRank") {
      url = 'https://www.kontests.net/api/v1/hacker_rank';
    } else if (widget.types == "HackerEarth") {
      url = 'https://www.kontests.net/api/v1/hacker_earth';
    } else if (widget.types == "LeetCode") {
      url = 'https://www.kontests.net/api/v1/leet_code';
    }

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
      var jsonResponse = convert.jsonDecode(response.body);
      for (var con in jsonResponse) {
        bool isBeforeNow = DateTime.now()
            .isBefore(DateTime.parse(con["start_time"]).toLocal());

        if (isBeforeNow) {
          individualModelList.add(IndividualModel.fromJson(con));
        }
      }

      individualModelList.sort((a, b) => (a.startTime).compareTo(b.startTime));
    } else {
      return onError(context, "Having problem connecting to the server")
          .then((value) => Navigator.of(context).pop());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _main();
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
                color: Color(0xFF292f38), fontSize: deviceHeight * 0.027),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : individualModelList.isEmpty
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
                        duration: individualModelList[index].duration,
                        name: individualModelList[index].name,
                        site: widget.types,
                        endTime: individualModelList[index].endTime,
                        startTime: individualModelList[index].startTime,
                        url: individualModelList[index].url,
                      );
                    },
                    itemCount: individualModelList.length,
                  ),
      ),
    );
  }
}
