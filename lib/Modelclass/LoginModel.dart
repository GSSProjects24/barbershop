// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool? success;
  String? message;
  String? token;
  Branch? branch;

  LoginModel({
    this.success,
    this.message,
    this.token,
    this.branch,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"],
    message: json["message"],
    token: json["token"],
    branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token": token,
    "branch": branch?.toJson(),
  };
}

class Branch {
  int? id;
  String? branchCode;
  String? name;
  String? type;
  Organization? organization;
  String? contactPerson;
  String? phone;
  String? email;
  String? address;
  String? openingTime;
  String? closingTime;
  List<String>? workingDays;

  Branch({
    this.id,
    this.branchCode,
    this.name,
    this.type,
    this.organization,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.openingTime,
    this.closingTime,
    this.workingDays,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json["id"],
    branchCode: json["branch_code"],
    name: json["name"],
    type: json["type"],
    organization: json["organization"] == null ? null : Organization.fromJson(json["organization"]),
    contactPerson: json["contact_person"],
    phone: json["phone"],
    email: json["email"],
    address: json["address"],
    openingTime: json["opening_time"],
    closingTime: json["closing_time"],
    workingDays: json["working_days"] == null ? [] : List<String>.from(json["working_days"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "branch_code": branchCode,
    "name": name,
    "type": type,
    "organization": organization?.toJson(),
    "contact_person": contactPerson,
    "phone": phone,
    "email": email,
    "address": address,
    "opening_time": openingTime,
    "closing_time": closingTime,
    "working_days": workingDays == null ? [] : List<dynamic>.from(workingDays!.map((x) => x)),
  };
}

class Organization {
  int? id;
  String? name;

  Organization({
    this.id,
    this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
