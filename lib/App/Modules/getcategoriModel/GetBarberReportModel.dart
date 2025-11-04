// To parse this JSON data, do
//
//     final getBarberReportModel = getBarberReportModelFromJson(jsonString);

import 'dart:convert';

GetBarberReportModel getBarberReportModelFromJson(String str) => GetBarberReportModel.fromJson(json.decode(str));

String getBarberReportModelToJson(GetBarberReportModel data) => json.encode(data.toJson());

class GetBarberReportModel {
  bool? success;
  List<Datum>? data;
  Period? period;

  GetBarberReportModel({
    this.success,
    this.data,
    this.period,
  });

  factory GetBarberReportModel.fromJson(Map<String, dynamic> json) => GetBarberReportModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    period: json["period"] == null ? null : Period.fromJson(json["period"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "period": period?.toJson(),
  };
}

class Datum {
  int? id;
  String? name;
  String? branchName;
  int? totalSales;
  int? totalServices;
  String? totalRevenue;
  String? avgServiceValue;
  String? totalCommission;
  String? avgCommissionRate;

  Datum({
    this.id,
    this.name,
    this.branchName,
    this.totalSales,
    this.totalServices,
    this.totalRevenue,
    this.avgServiceValue,
    this.totalCommission,
    this.avgCommissionRate,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    branchName: json["branch_name"],
    totalSales: json["total_sales"],
    totalServices: json["total_services"],
    totalRevenue: json["total_revenue"],
    avgServiceValue: json["avg_service_value"],
    totalCommission: json["total_commission"],
    avgCommissionRate: json["avg_commission_rate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "branch_name": branchName,
    "total_sales": totalSales,
    "total_services": totalServices,
    "total_revenue": totalRevenue,
    "avg_service_value": avgServiceValue,
    "total_commission": totalCommission,
    "avg_commission_rate": avgCommissionRate,
  };
}

class Period {
  DateTime? from;
  DateTime? to;

  Period({
    this.from,
    this.to,
  });

  factory Period.fromJson(Map<String, dynamic> json) => Period(
    from: json["from"] == null ? null : DateTime.parse(json["from"]),
    to: json["to"] == null ? null : DateTime.parse(json["to"]),
  );

  Map<String, dynamic> toJson() => {
    "from": "${from!.year.toString().padLeft(4, '0')}-${from!.month.toString().padLeft(2, '0')}-${from!.day.toString().padLeft(2, '0')}",
    "to": "${to!.year.toString().padLeft(4, '0')}-${to!.month.toString().padLeft(2, '0')}-${to!.day.toString().padLeft(2, '0')}",
  };
}