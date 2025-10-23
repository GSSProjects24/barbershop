// To parse this JSON data, do
//
//     final getBarberlistModel = getBarberlistModelFromJson(jsonString);

import 'dart:convert';

GetBarberlistModel getBarberlistModelFromJson(String str) => GetBarberlistModel.fromJson(json.decode(str));

String getBarberlistModelToJson(GetBarberlistModel data) => json.encode(data.toJson());

class GetBarberlistModel {
  bool? success;
  Data? data;
  Meta? meta;

  GetBarberlistModel({
    this.success,
    this.data,
    this.meta,
  });

  factory GetBarberlistModel.fromJson(Map<String, dynamic> json) => GetBarberlistModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "meta": meta?.toJson(),
  };
}

class Data {
  int? currentPage;
  List<Datum>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Data({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  int? id;
  dynamic organizationId;
  int? branchId;
  int? departmentId;
  int? designationId;
  dynamic userId;
  String? employeeCode;
  String? fullName;
  String? phone;
  dynamic email;
  DateTime? dateOfBirth;
  String? gender;
  dynamic address;
  DateTime? joiningDate;
  String? employeeType;
  String? basicSalary;
  String? serviceCommissionPercentage;
  String? productCommissionPercentage;
  dynamic bankName;
  dynamic bankAccountNumber;
  dynamic bankAccountHolder;
  dynamic emergencyContactName;
  dynamic emergencyContactPhone;
  dynamic emergencyContactRelation;
  dynamic photo;
  dynamic notes;
  bool? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  Branch? branch;

  Datum({
    this.id,
    this.organizationId,
    this.branchId,
    this.departmentId,
    this.designationId,
    this.userId,
    this.employeeCode,
    this.fullName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.joiningDate,
    this.employeeType,
    this.basicSalary,
    this.serviceCommissionPercentage,
    this.productCommissionPercentage,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.photo,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.branch,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    organizationId: json["organization_id"],
    branchId: json["branch_id"],
    departmentId: json["department_id"],
    designationId: json["designation_id"],
    userId: json["user_id"],
    employeeCode: json["employee_code"],
    fullName: json["full_name"],
    phone: json["phone"],
    email: json["email"],
    dateOfBirth: json["date_of_birth"] == null ? null : DateTime.parse(json["date_of_birth"]),
    gender: json["gender"],
    address: json["address"],
    joiningDate: json["joining_date"] == null ? null : DateTime.parse(json["joining_date"]),
    employeeType: json["employee_type"],
    basicSalary: json["basic_salary"],
    serviceCommissionPercentage: json["service_commission_percentage"],
    productCommissionPercentage: json["product_commission_percentage"],
    bankName: json["bank_name"],
    bankAccountNumber: json["bank_account_number"],
    bankAccountHolder: json["bank_account_holder"],
    emergencyContactName: json["emergency_contact_name"],
    emergencyContactPhone: json["emergency_contact_phone"],
    emergencyContactRelation: json["emergency_contact_relation"],
    photo: json["photo"],
    notes: json["notes"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "organization_id": organizationId,
    "branch_id": branchId,
    "department_id": departmentId,
    "designation_id": designationId,
    "user_id": userId,
    "employee_code": employeeCode,
    "full_name": fullName,
    "phone": phone,
    "email": email,
    "date_of_birth": dateOfBirth?.toIso8601String(),
    "gender": gender,
    "address": address,
    "joining_date": joiningDate?.toIso8601String(),
    "employee_type": employeeType,
    "basic_salary": basicSalary,
    "service_commission_percentage": serviceCommissionPercentage,
    "product_commission_percentage": productCommissionPercentage,
    "bank_name": bankName,
    "bank_account_number": bankAccountNumber,
    "bank_account_holder": bankAccountHolder,
    "emergency_contact_name": emergencyContactName,
    "emergency_contact_phone": emergencyContactPhone,
    "emergency_contact_relation": emergencyContactRelation,
    "photo": photo,
    "notes": notes,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "branch": branch?.toJson(),
  };
}

class Branch {
  int? id;
  int? organizationId;
  String? branchCode;
  String? name;
  String? type;
  String? franchiseCommissionPercentage;
  String? branchUsername;
  String? address;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? latitude;
  String? longitude;
  String? contactPerson;
  String? phone;
  String? email;
  String? openingTime;
  String? closingTime;
  List<String>? workingDays;
  int? isPointsEnabled;
  int? isInventoryEnabled;
  bool? status;
  dynamic notes;
  DateTime? openedDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Branch({
    this.id,
    this.organizationId,
    this.branchCode,
    this.name,
    this.type,
    this.franchiseCommissionPercentage,
    this.branchUsername,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.phone,
    this.email,
    this.openingTime,
    this.closingTime,
    this.workingDays,
    this.isPointsEnabled,
    this.isInventoryEnabled,
    this.status,
    this.notes,
    this.openedDate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json["id"],
    organizationId: json["organization_id"],
    branchCode: json["branch_code"],
    name: json["name"],
    type: json["type"],
    franchiseCommissionPercentage: json["franchise_commission_percentage"],
    branchUsername: json["branch_username"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    postalCode: json["postal_code"],
    country: json["country"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    contactPerson: json["contact_person"],
    phone: json["phone"],
    email: json["email"],
    openingTime: json["opening_time"],
    closingTime: json["closing_time"],
    workingDays: json["working_days"] == null ? [] : List<String>.from(json["working_days"]!.map((x) => x)),
    isPointsEnabled: json["is_points_enabled"],
    isInventoryEnabled: json["is_inventory_enabled"],
    status: json["status"],
    notes: json["notes"],
    openedDate: json["opened_date"] == null ? null : DateTime.parse(json["opened_date"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "organization_id": organizationId,
    "branch_code": branchCode,
    "name": name,
    "type": type,
    "franchise_commission_percentage": franchiseCommissionPercentage,
    "branch_username": branchUsername,
    "address": address,
    "city": city,
    "state": state,
    "postal_code": postalCode,
    "country": country,
    "latitude": latitude,
    "longitude": longitude,
    "contact_person": contactPerson,
    "phone": phone,
    "email": email,
    "opening_time": openingTime,
    "closing_time": closingTime,
    "working_days": workingDays == null ? [] : List<dynamic>.from(workingDays!.map((x) => x)),
    "is_points_enabled": isPointsEnabled,
    "is_inventory_enabled": isInventoryEnabled,
    "status": status,
    "notes": notes,
    "opened_date": "${openedDate!.year.toString().padLeft(4, '0')}-${openedDate!.month.toString().padLeft(2, '0')}-${openedDate!.day.toString().padLeft(2, '0')}",
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}

class Meta {
  int? totalBarbers;

  Meta({
    this.totalBarbers,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    totalBarbers: json["total_barbers"],
  );

  Map<String, dynamic> toJson() => {
    "total_barbers": totalBarbers,
  };
}
