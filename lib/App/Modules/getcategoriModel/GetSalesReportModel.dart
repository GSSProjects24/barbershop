// To parse this JSON data, do
//
//     final getSalesReportModel = getSalesReportModelFromJson(jsonString);

import 'dart:convert';

GetSalesReportModel getSalesReportModelFromJson(String str) =>
    GetSalesReportModel.fromJson(json.decode(str));

String getSalesReportModelToJson(GetSalesReportModel data) =>
    json.encode(data.toJson());

class GetSalesReportModel {
  bool? success;
  List<SaleTransaction>? data;
  Pagination? pagination;

  GetSalesReportModel({
    this.success,
    this.data,
    this.pagination,
  });

  factory GetSalesReportModel.fromJson(Map<String, dynamic> json) => GetSalesReportModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<SaleTransaction>.from(json["data"]!.map((x) => SaleTransaction.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };

  // ✅ Calculate summary from transactions
  SalesSummary getSummary() {
    if (data == null || data!.isEmpty) {
      return SalesSummary(
        totalSales: 0,
        totalOrders: 0,
        averageOrderValue: 0,
        totalItemsSold: 0,
        totalDiscounts: 0,
        totalTaxes: 0,
      );
    }

    double totalSales = 0;
    int totalOrders = data!.length;
    int totalItemsSold = 0;
    double totalDiscounts = 0;
    double totalTaxes = 0;

    for (var sale in data!) {
      totalSales += double.tryParse(sale.totalAmount ?? '0') ?? 0;
      totalDiscounts += double.tryParse(sale.discountAmount ?? '0') ?? 0;
      totalTaxes += double.tryParse(sale.taxAmount ?? '0') ?? 0;
      totalItemsSold += sale.items?.length ?? 0;
    }

    double averageOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0;

    return SalesSummary(
      totalSales: totalSales,
      totalOrders: totalOrders,
      averageOrderValue: averageOrderValue,
      totalItemsSold: totalItemsSold,
      totalDiscounts: totalDiscounts,
      totalTaxes: totalTaxes,
    );
  }
}

// ✅ Summary class to hold calculated values
class SalesSummary {
  final double totalSales;
  final int totalOrders;
  final double averageOrderValue;
  final int totalItemsSold;
  final double totalDiscounts;
  final double totalTaxes;

  SalesSummary({
    required this.totalSales,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.totalItemsSold,
    required this.totalDiscounts,
    required this.totalTaxes,
  });
}

class SaleTransaction {
  int? id;
  String? invoiceNumber;
  String? branchName;
  String? cashierName;
  String? customerName;
  String? customerPhone;
  String? subtotal;
  String? discountAmount;
  String? taxAmount;
  String? totalAmount;
  String? paymentMethod;
  String? paymentStatus;
  String? saleDate;
  String? createdAt;
  List<SaleItem>? items;

  SaleTransaction({
    this.id,
    this.invoiceNumber,
    this.branchName,
    this.cashierName,
    this.customerName,
    this.customerPhone,
    this.subtotal,
    this.discountAmount,
    this.taxAmount,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.saleDate,
    this.createdAt,
    this.items,
  });

  factory SaleTransaction.fromJson(Map<String, dynamic> json) => SaleTransaction(
    id: json["id"],
    invoiceNumber: json["invoice_number"],
    branchName: json["branch_name"],
    cashierName: json["cashier_name"],
    customerName: json["customer_name"],
    customerPhone: json["customer_phone"],
    subtotal: json["subtotal"],
    discountAmount: json["discount_amount"],
    taxAmount: json["tax_amount"],
    totalAmount: json["total_amount"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    saleDate: json["sale_date"],
    createdAt: json["created_at"],
    items: json["items"] == null ? [] : List<SaleItem>.from(json["items"]!.map((x) => SaleItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_number": invoiceNumber,
    "branch_name": branchName,
    "cashier_name": cashierName,
    "customer_name": customerName,
    "customer_phone": customerPhone,
    "subtotal": subtotal,
    "discount_amount": discountAmount,
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "sale_date": saleDate,
    "created_at": createdAt,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class SaleItem {
  String? itemType;
  String? itemName;
  String? quantity;
  String? unitPrice;
  String? discountAmount;
  String? totalAmount;

  SaleItem({
    this.itemType,
    this.itemName,
    this.quantity,
    this.unitPrice,
    this.discountAmount,
    this.totalAmount,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
    itemType: json["item_type"],
    itemName: json["item_name"],
    quantity: json["quantity"],
    unitPrice: json["unit_price"],
    discountAmount: json["discount_amount"],
    totalAmount: json["total_amount"],
  );

  Map<String, dynamic> toJson() => {
    "item_type": itemType,
    "item_name": itemName,
    "quantity": quantity,
    "unit_price": unitPrice,
    "discount_amount": discountAmount,
    "total_amount": totalAmount,
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;

  Pagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
  };
}