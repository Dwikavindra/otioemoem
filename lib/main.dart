import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'models/covid_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<CovidModel> yesterdayData;
  late Future<CovidModel> todayData;

  Future<CovidModel> getyesterdayData() async {
    final DateTime yesterdayDateTime =
        DateTime.now().subtract(Duration(days: 2));
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String yesterdayDate = formatter.format(yesterdayDateTime);
    print(yesterdayDate);

    final queryParameters = {
      // this Map<String,dynamic> apparently
      'date': yesterdayDate,
    };

    final headers = {
      'X-RapidAPI-Key': '5694e283f2msh8670cf5b9be961dp16a683jsn090e979d217b',
      'X-RapidAPI-Host': 'covid-19-statistics.p.rapidapi.com'
    };

    final url = Uri.https(
        'covid-19-statistics.p.rapidapi.com', 'reports/total', queryParameters);
    final response = await http.get(url, headers: headers);
    print(response.body);
    return CovidModel.fromJson(jsonDecode(response.body));
  }

  Future<CovidModel> gettodayData() async {
    final headers = {
      'X-RapidAPI-Key': '5694e283f2msh8670cf5b9be961dp16a683jsn090e979d217b',
      'X-RapidAPI-Host': 'covid-19-statistics.p.rapidapi.com'
    };

    final url =
        Uri.https('covid-19-statistics.p.rapidapi.com', 'reports/total');
    final response = await http.get(url, headers: headers);
    return CovidModel.fromJson(jsonDecode(response.body));
  }

  @override
  void initState() {
    yesterdayData = getyesterdayData();
    todayData = gettodayData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Worldwide Covid",
          style: GoogleFonts.dmSans(
              textStyle: const TextStyle(color: Colors.black)),
        ),
      ),
      body: ListView(shrinkWrap: true, children: [
        Column(
          children: <Widget>[
            Image.asset("assets/Rectangle.png"),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                margin: const EdgeInsets.only(
                    top: 45, left: 14.5, right: 9.5, bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Latest Update",
                                style: GoogleFonts.dmSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            FutureBuilder<CovidModel>(
                                future: todayData,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(snapshot
                                            .data!.data.lastUpdate
                                            .toString()));
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                })
                          ],
                        ),
                      ),
                      FutureBuilder<List<CovidModel>>(
                        future: Future.wait([todayData, yesterdayData]),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            CovidModel todayData = snapshot.data![0];
                            CovidModel yesterdayData = snapshot.data![1];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 17.5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CovidStatuses(
                                        statusTitle: "Total Cases",
                                        previousStatusNumberDiff:
                                            yesterdayData.data.confirmedDiff,
                                        currentStatusNumberDiff:
                                            todayData.data.confirmedDiff,
                                        currentNumber: todayData.data.confirmed,
                                      ),
                                      CovidStatuses(
                                        statusTitle: "Recovered",
                                        previousStatusNumberDiff:
                                            yesterdayData.data.recoveredDiff,
                                        currentStatusNumberDiff:
                                            todayData.data.recoveredDiff,
                                        currentNumber: todayData.data.recovered,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: 20.59, bottom: 78),
                                  child: CovidStatuses(
                                    statusTitle: "Active Cases",
                                    previousStatusNumberDiff:
                                        yesterdayData.data.activeDiff,
                                    currentStatusNumberDiff:
                                        todayData.data.activeDiff,
                                    currentNumber: todayData.data.active,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      )
                    ])),
          ],
        ),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CovidStatuses extends StatefulWidget {
  CovidStatuses(
      {Key? key,
      required this.currentNumber,
      required this.statusTitle,
      required this.currentStatusNumberDiff,
      required this.previousStatusNumberDiff})
      : super(key: key) {
    if (currentStatusNumberDiff > previousStatusNumberDiff) {
      imageAsset = "assets/vector_inclining.png";
      textColor = const Color.fromRGBO(255, 0, 0, 1);
    }
    if (currentStatusNumberDiff < previousStatusNumberDiff) {
      imageAsset = "assets/vector_declining.png";
      textColor = const Color.fromRGBO(13, 172, 48, 1);
    }

    if (currentStatusNumberDiff == previousStatusNumberDiff) {
      imageAsset = "";
      textColor = const Color.fromRGBO(152, 151, 151, 1);
    }
  }
  late final String imageAsset;
  late final Color textColor;

  final hello =
      "Dwika"; // if you want to be redeclareable use var or Int String if its not redecalrable final /const with final u cant do hello="Duar"
  String statusTitle;
  int currentNumber;
  int currentStatusNumberDiff;
  int previousStatusNumberDiff;

  @override
  State<CovidStatuses> createState() => _CovidStatusesState();
}

class _CovidStatusesState extends State<CovidStatuses> {
  final NumberFormat numberFormatter = NumberFormat.decimalPattern('en_us');
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      constraints: BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey)),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15.4),
              child: Text(
                widget.statusTitle,
                style: GoogleFonts.dmSans(
                    color: const Color.fromRGBO(153, 153, 153, 1),
                    fontSize: 17,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 10, left: 10),
                child: widget.imageAsset != ""
                    ? Image.asset("assets/Vector.png")
                    : const SizedBox.shrink()),
          ],
        ),
        Container(
            constraints: const BoxConstraints(maxWidth: 115),
            margin: const EdgeInsets.only(top: 25, bottom: 40.29),
            child: Text(numberFormatter.format(widget.currentNumber).toString(),
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  color: widget.textColor,
                )))
      ]),
    );
  }
}
