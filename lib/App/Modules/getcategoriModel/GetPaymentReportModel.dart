// To parse this JSON data, do
//
//     final getPaymentReportModel = getPaymentReportModelFromJson(jsonString);

import 'dart:convert';

GetPaymentReportModel getPaymentReportModelFromJson(String str) =>
    GetPaymentReportModel.fromJson(json.decode(str));

String getPaymentReportModelToJson(GetPaymentReportModel data) =>
    json.encode(data.toJson());

class GetPaymentReportModel {
  bool? success;
  List<PaymentDatum>? data;
  Pagination? pagination;

  GetPaymentReportModel({
    this.success,
    this.data,
    this.pagination,
  });

  factory GetPaymentReportModel.fromJson(Map<String, dynamic> json) => GetPaymentReportModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<PaymentDatum>.from(json["data"]!.map((x) => PaymentDatum.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };

  // ✅ Calculate payment method breakdown from payments list
  List<PaymentMethodBreakdown> getPaymentMethodBreakdown() {
    if (data == null || data!.isEmpty) {
      return [];
    }

    // Group by payment method
    Map<String, PaymentMethodBreakdown> methodMap = {};

    for (var payment in data!) {
      final method = payment.paymentMethod ?? 'unknown';
      final amount = double.tryParse(payment.totalAmount ?? '0') ?? 0;

      if (methodMap.containsKey(method)) {
        methodMap[method]!.totalAmount += amount;
        methodMap[method]!.count += 1;
      } else {
        methodMap[method] = PaymentMethodBreakdown(
          paymentMethod: method,
          totalAmount: amount,
          count: 1,
        );
      }
    }

    return methodMap.values.toList();
  }
}

// ✅ Breakdown class for payment methods
class PaymentMethodBreakdown {
  final String paymentMethod;
  double totalAmount;
  int count;

  PaymentMethodBreakdown({
    required this.paymentMethod,
    required this.totalAmount,
    required this.count,
  });
}

class PaymentDatum {
  int? id;
  String? invoiceNumber;
  String? branchName;
  String? customerName;
  String? totalAmount;
  String? paymentMethod;
  String? paymentStatus;
  String? paidAmount;
  String? changeAmount;
  String? paymentDate;
  String? saleDate;
  String? createdAt;

  PaymentDatum({
    this.id,
    this.invoiceNumber,
    this.branchName,
    this.customerName,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.paidAmount,
    this.changeAmount,
    this.paymentDate,
    this.saleDate,
    this.createdAt,
  });

  factory PaymentDatum.fromJson(Map<String, dynamic> json) => PaymentDatum(
    id: json["id"],
    invoiceNumber: json["invoice_number"],
    branchName: json["branch_name"],
    customerName: json["customer_name"],
    totalAmount: json["total_amount"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    paidAmount: json["paid_amount"],
    changeAmount: json["change_amount"],
    paymentDate: json["payment_date"],
    saleDate: json["sale_date"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_number": invoiceNumber,
    "branch_name": branchName,
    "customer_name": customerName,
    "total_amount": totalAmount,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "paid_amount": paidAmount,
    "change_amount": changeAmount,
    "payment_date": paymentDate,
    "sale_date": saleDate,
    "created_at": createdAt,
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