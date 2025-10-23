// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool? success;
  String? message;
  Data? data;

  LoginModel({
    this.success,
    this.message,
    this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? token;
  String? tokenType;
  User? user;

  Data({
    this.token,
    this.tokenType,
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    tokenType: json["token_type"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "token_type": tokenType,
    "user": user?.toJson(),
  };
}

class User {
  int? id;
  String? username;
  String? fullName;
  String? email;
  String? phone;
  dynamic avatar;
  bool? isSuperAdmin;
  bool? canAccessAllBranches;
  bool? status;
  DateTime? lastLoginAt;
  Role? role;
  dynamic employee;
  Branch? branch;
  Organization? organization;
  List<dynamic>? permissions;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.username,
    this.fullName,
    this.email,
    this.phone,
    this.avatar,
    this.isSuperAdmin,
    this.canAccessAllBranches,
    this.status,
    this.lastLoginAt,
    this.role,
    this.employee,
    this.branch,
    this.organization,
    this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    fullName: json["full_name"],
    email: json["email"],
    phone: json["phone"],
    avatar: json["avatar"],
    isSuperAdmin: json["is_super_admin"],
    canAccessAllBranches: json["can_access_all_branches"],
    status: json["status"],
    lastLoginAt: json["last_login_at"] == null ? null : DateTime.parse(json["last_login_at"]),
    role: json["role"] == null ? null : Role.fromJson(json["role"]),
    employee: json["employee"],
    branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
    organization: json["organization"] == null ? null : Organization.fromJson(json["organization"]),
    permissions: json["permissions"] == null ? [] : List<dynamic>.from(json["permissions"]!.map((x) => x)),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "full_name": fullName,
    "email": email,
    "phone": phone,
    "avatar": avatar,
    "is_super_admin": isSuperAdmin,
    "can_access_all_branches": canAccessAllBranches,
    "status": status,
    "last_login_at": lastLoginAt?.toIso8601String(),
    "role": role?.toJson(),
    "employee": employee,
    "branch": branch?.toJson(),
    "organization": organization?.toJson(),
    "permissions": permissions == null ? [] : List<dynamic>.from(permissions!.map((x) => x)),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Branch {
  int? id;
  String? name;
  String? branchCode;
  String? type;
  String? address;
  String? city;
  String? state;
  String? phone;
  String? email;
  bool? isPointsEnabled;
  bool? isInventoryEnabled;
  bool? status;

  Branch({
    this.id,
    this.name,
    this.branchCode,
    this.type,
    this.address,
    this.city,
    this.state,
    this.phone,
    this.email,
    this.isPointsEnabled,
    this.isInventoryEnabled,
    this.status,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json["id"],
    name: json["name"],
    branchCode: json["branch_code"],
    type: json["type"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    phone: json["phone"],
    email: json["email"],
    isPointsEnabled: json["is_points_enabled"],
    isInventoryEnabled: json["is_inventory_enabled"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "branch_code": branchCode,
    "type": type,
    "address": address,
    "city": city,
    "state": state,
    "phone": phone,
    "email": email,
    "is_points_enabled": isPointsEnabled,
    "is_inventory_enabled": isInventoryEnabled,
    "status": status,
  };
}

class Organization {
  int? id;
  String? name;
  String? code;
  String? type;
  dynamic logo;
  String? email;
  String? phone;

  Organization({
    this.id,
    this.name,
    this.code,
    this.type,
    this.logo,
    this.email,
    this.phone,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    type: json["type"],
    logo: json["logo"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "type": type,
    "logo": logo,
    "email": email,
    "phone": phone,
  };
}

class Role {
  int? id;
  String? name;
  String? slug;
  String? description;
  int? level;

  Role({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.level,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    level: json["level"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "level": level,
  };
}
