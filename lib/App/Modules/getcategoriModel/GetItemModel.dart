class ItemModel {
  final int id;
  final String name;
  final String type; // 'service' or 'product'
  final String code;
  final int categoryId;
  final String categoryName;
  final double price;
  final String? pointsEarned;
  final int? pointsRequired;
  final bool? isRedeemable;
  final int? stock;
  final bool? inStock;
  final String? image;

  ItemModel({
    required this.id,
    required this.name,
    required this.type,
    required this.code,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.pointsEarned,
    this.pointsRequired,
    this.isRedeemable,
    this.stock,
    this.inStock,
    this.image,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      type: json['type'] ?? 'service',
      code: json['code'] ?? '',
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? 'Uncategorized',
      price: (json['price'] ?? 0).toDouble(),
      pointsEarned: json['points_earned']?.toString(),
      pointsRequired: json['points_required'],
      isRedeemable: json['is_redeemable'],
      stock: json['stock'],
      inStock: json['in_stock'],
      image: json['image'],
    );
  }

  String get title => name;
  String get sku => code;

  String get imageUrl {
    if (image != null && image!.isNotEmpty) {
      return 'https://apibarbershop.graspsoftwaresolutions.xyz/public/storage/$image';
    }
    return 'https://via.placeholder.com/150';
  }

  // ✅ FIXED: Handle decimal strings like "100.00"
  int get points {
    if (type == 'service' && pointsEarned != null && pointsEarned!.isNotEmpty) {
      // Parse as double first, then convert to int
      final doubleValue = double.tryParse(pointsEarned!);
      if (doubleValue != null) {
        return doubleValue.toInt();
      }
      return 0;
    } else if (type == 'product' && pointsRequired != null) {
      return pointsRequired!;
    }
    return 0;
  }

  // Helper getters
  int get earnedPoints {
    if (type == 'service' && pointsEarned != null) {
      final doubleValue = double.tryParse(pointsEarned!);
      return doubleValue?.toInt() ?? 0;
    }
    return 0;
  }

  int get requiredPoints {
    if (type == 'product' && pointsRequired != null) {
      return pointsRequired!;
    }
    return 0;
  }
}

