// To parse this JSON data, do
//
//     final getCategoriesModel = getCategoriesModelFromJson(jsonString);

import 'dart:convert';

GetCategoriesModel getCategoriesModelFromJson(String str) => GetCategoriesModel.fromJson(json.decode(str));

String getCategoriesModelToJson(GetCategoriesModel data) => json.encode(data.toJson());

class GetCategoriesModel {
  bool? success;
  String? message;
  Data? data;

  GetCategoriesModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetCategoriesModel.fromJson(Map<String, dynamic> json) => GetCategoriesModel(
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
  List<Category>? categories;
  Summary? summary;

  Data({
    this.categories,
    this.summary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
  };
}

class Category {
  int? id;
  String? name;
  String? slug;
  String? type;
  String? description;
  dynamic icon;
  dynamic color;
  int? sortOrder;
  bool? status;
  int? serviceCount;
  int? productCount;

  Category({
    this.id,
    this.name,
    this.slug,
    this.type,
    this.description,
    this.icon,
    this.color,
    this.sortOrder,
    this.status,
    this.serviceCount,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    type: json["type"],
    description: json["description"],
    icon: json["icon"],
    color: json["color"],
    sortOrder: json["sort_order"],
    status: json["status"],
    serviceCount: json["service_count"],
    productCount: json["product_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "type": type,
    "description": description,
    "icon": icon,
    "color": color,
    "sort_order": sortOrder,
    "status": status,
    "service_count": serviceCount,
    "product_count": productCount,
  };
}

class Summary {
  int? totalCategories;
  int? serviceCategories;
  int? productCategories;

  Summary({
    this.totalCategories,
    this.serviceCategories,
    this.productCategories,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalCategories: json["total_categories"],
    serviceCategories: json["service_categories"],
    productCategories: json["product_categories"],
  );

  Map<String, dynamic> toJson() => {
    "total_categories": totalCategories,
    "service_categories": serviceCategories,
    "product_categories": productCategories,
  };
}
