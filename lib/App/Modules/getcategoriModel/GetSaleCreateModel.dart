// ============================================
// 1. MODEL CLASS - sale_model.dart
// ============================================
// Create this file: lib/App/Modules/sale/sale_model.dart

class SaleResponse {
  final bool success;
  final String message;
  final SaleData? data;

  SaleResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SaleData.fromJson(json['data']) : null,
    );
  }
}

class SaleData {
  final Sale sale;
  final SaleCustomer customer;
  final SaleBarber barber;
  final List<SaleItem> items;

  SaleData({
    required this.sale,
    required this.customer,
    required this.barber,
    required this.items,
  });

  factory SaleData.fromJson(Map<String, dynamic> json) {
    return SaleData(
      sale: Sale.fromJson(json['sale']),
      customer: SaleCustomer.fromJson(json['customer']),
      barber: SaleBarber.fromJson(json['barber']),
      items: (json['items'] as List)
          .map((item) => SaleItem.fromJson(item))
          .toList(),
    );
  }
}

class Sale {
  final int id;
  final String invoiceNumber;
  final String saleDate;
  final double subtotal;
  final double discountAmount;
  final int pointsRedeemed;
  final double pointsRedeemedValue;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod;
  final int pointsEarned;

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.saleDate,
    required this.subtotal,
    required this.discountAmount,
    required this.pointsRedeemed,
    required this.pointsRedeemedValue,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.pointsEarned,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      invoiceNumber: json['invoice_number'] ?? '',
      saleDate: json['sale_date'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      pointsRedeemed: json['points_redeemed'] ?? 0,
      pointsRedeemedValue: (json['points_redeemed_value'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      pointsEarned: json['points_earned'] ?? 0,
    );
  }
}

class SaleCustomer {
  final int id;
  final String name;
  final String phone;
  final int totalPoints;
  final int totalVisits;
  final double totalSpent;

  SaleCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalPoints,
    required this.totalVisits,
    required this.totalSpent,
  });

  factory SaleCustomer.fromJson(Map<String, dynamic> json) {
    return SaleCustomer(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      totalVisits: json['total_visits'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
    );
  }
}

class SaleBarber {
  final int id;
  final String fullName;

  SaleBarber({
    required this.id,
    required this.fullName,
  });

  factory SaleBarber.fromJson(Map<String, dynamic> json) {
    return SaleBarber(
      id: json['id'],
      fullName: json['full_name'] ?? '',
    );
  }
}

class SaleItem {
  final String itemType;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final int pointsEarned;
  final bool isRedeemed;

  SaleItem({
    required this.itemType,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.pointsEarned,
    required this.isRedeemed,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      itemType: json['item_type'] ?? '',
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      pointsEarned: json['points_earned'] ?? 0,
      isRedeemed: json['is_redeemed'] ?? false,
    );
  }
}
