class CovidModel {
  CovidModel({
    required this.data,
  });

  Data data;

  factory CovidModel.fromJson(Map<String, dynamic> json) => CovidModel(
        data: Data.fromJson(json["data"]),
      );
}

class Data {
  Data({
    required this.date,
    required this.lastUpdate,
    required this.confirmed,
    required this.confirmedDiff,
    required this.deaths,
    required this.deathsDiff,
    required this.recovered,
    required this.recoveredDiff,
    required this.active,
    required this.activeDiff,
    required this.fatalityRate,
  });

  DateTime date;
  DateTime lastUpdate;
  int confirmed;
  int confirmedDiff;
  int deaths;
  int deathsDiff;
  int recovered;
  int recoveredDiff;
  int active;
  int activeDiff;
  double fatalityRate;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: DateTime.parse(json["date"]),
        lastUpdate: DateTime.parse(json["last_update"]),
        confirmed: json["confirmed"],
        confirmedDiff: json["confirmed_diff"],
        deaths: json["deaths"],
        deathsDiff: json["deaths_diff"],
        recovered: json["recovered"],
        recoveredDiff: json["recovered_diff"],
        active: json["active"],
        activeDiff: json["active_diff"],
        fatalityRate: json["fatality_rate"].toDouble(),
      );
}
