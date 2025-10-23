// lib/App/Modules/barber_staff_selection/categories_controller.dart

import 'package:babershop_project/App/Modules/getcategoriModel/GetCateoriesModel.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetItemModel.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetbarberModel.dart';
import 'package:babershop_project/App/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Customer Model - UPDATED with totalPoints
class Customer {
  final int id;
  final String customerCode;
  final String phone;
  final String name;
  final String? email;
  final int totalPoints;

  Customer({
    required this.id,
    required this.customerCode,
    required this.phone,
    required this.name,
    this.email,
    required this.totalPoints,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerCode: json['customer_code'],
      phone: json['phone'],
      name: json['name'],
      email: json['email'],
      totalPoints: json['total_points'] ?? 0,
    );
  }
}

// Cart Item Model with quantity
class CartItem {
  final ItemModel item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get totalPrice => item.price * quantity;
  int get totalPoints => item.points * quantity;
  int get singleItemPoints => item.points;
}

class CartController extends GetxController {
  // Barber variables
  var barbers = <Datum>[].obs;
  var isLoadingBarbers = false.obs;
  var selectedBarber = Rx<Datum?>(null);

  // Customer variables
  var customers = <Customer>[].obs;
  var isLoadingCustomers = false.obs;
  var selectedCustomer = Rx<Customer?>(null);
  var mobileNumber = ''.obs;

  // Add customer form variables
  var showAddField = false.obs;
  final addFieldController = TextEditingController();
  final nameController = TextEditingController();

  // ✅ NEW: Points redemption variables
  var pointsToRedeem = 0.obs;
  var pointsRedemptionRate = 1.0; // 1 point = RM 1.0 (adjust as needed)
  final pointsController = TextEditingController();

  var cartItems = <CartItem>[].obs;
  var isCash = false.obs;
  var isOnline = false.obs;
  var isQr = false.obs;

  // Categories
  var categories = <Category>[].obs;
  var isLoadingCategories = false.obs;
  var selectedCategoryId = 0.obs;
  var selectedCategoryName = 'ALL'.obs;

  // Items
  var allItems = <ItemModel>[].obs;
  var products = <ItemModel>[].obs;
  var isLoadingItems = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBarbers();
    fetchCategories();
    fetchAllItems();
    fetchCustomers();

    // ✅ Listen to points controller changes
    pointsController.addListener(() {
      final value = int.tryParse(pointsController.text) ?? 0;
      if (value != pointsToRedeem.value) {
        setPointsToRedeem(value);
      }
    });
  }

  // ✅ Calculate available points for redemption
  int get availablePoints {
    return selectedCustomer.value?.totalPoints ?? 0;
  }

  // ✅ Calculate points redemption value in currency
  double get pointsRedeemedValue {
    return pointsToRedeem.value * pointsRedemptionRate;
  }

  // ✅ Validate and set points to redeem
  void setPointsToRedeem(int points) {
    if (selectedCustomer.value == null) {
      Get.snackbar(
        'Error',
        'Please select a customer first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      pointsController.clear();
      pointsToRedeem.value = 0;
      return;
    }

    final maxPoints = availablePoints;
    final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    if (points > maxPoints) {
      Get.snackbar(
        'Error',
        'Maximum available points: $maxPoints',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      pointsToRedeem.value = maxPoints;
      pointsController.text = maxPoints.toString();
      return;
    }

    // Prevent redeeming more points than the subtotal value
    final maxRedeemablePoints = (subtotal / pointsRedemptionRate).floor();
    if (points > maxRedeemablePoints) {
      Get.snackbar(
        'Error',
        'Cannot redeem more than subtotal value. Max: $maxRedeemablePoints points',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      pointsToRedeem.value = maxRedeemablePoints;
      pointsController.text = maxRedeemablePoints.toString();
      return;
    }

    pointsToRedeem.value = points;
  }

  // ✅ Clear points redemption
  void clearPointsRedemption() {
    pointsToRedeem.value = 0;
    pointsController.clear();
  }

  // ✅ Fetch Barbers
  Future<void> fetchBarbers() async {
    try {
      isLoadingBarbers.value = true;

      final response = await ApiProvider.instance.getBarbers();

      if (response['success'] == true && response['data'] != null) {
        final barberModel = GetBarberlistModel.fromJson(response);

        if (barberModel.data?.data != null) {
          barbers.value = barberModel.data!.data!;
          print('✅ Loaded ${barbers.length} barbers');
        }
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to load barbers',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error fetching barbers: $e');
      Get.snackbar(
        'Error',
        'Failed to load barbers: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingBarbers.value = false;
    }
  }

  // ✅ Select Barber
  void selectBarber(Datum? barber) {
    selectedBarber.value = barber;
    if (barber != null) {
      print('🔧 Selected Barber ID: ${barber.id}');
      print('🔧 Selected Barber Name: ${barber.fullName}');
      print('🔧 Selected Barber Code: ${barber.employeeCode}');
    }
  }

  // ✅ Fetch Customers
  Future<void> fetchCustomers() async {
    try {
      isLoadingCustomers.value = true;

      final response = await ApiProvider.instance.getCustomers();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> customersData = response['data']['data'];
        customers.value = customersData
            .map((json) => Customer.fromJson(json))
            .toList();

        print('✅ Loaded ${customers.length} customers');
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to load customers',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error fetching customers: $e');
      Get.snackbar(
        'Error',
        'Failed to load customers: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  // ✅ Create New Customer
  Future<void> createCustomer() async {
    final phone = addFieldController.text.trim();
    final name = nameController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter customer name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await ApiProvider.instance.createCustomer(
        phone: phone,
        name: name,
        gender: 'male',
      );

      Get.back();

      if (response['success'] == true) {
        await fetchCustomers();

        final newCustomerData = response['data'];
        if (newCustomerData != null) {
          final newCustomer = Customer.fromJson(newCustomerData);
          selectedCustomer.value = newCustomer;
          mobileNumber.value = newCustomer.phone;
        }

        addFieldController.clear();
        nameController.clear();
        showAddField.value = false;

        Get.snackbar(
          'Success',
          'Customer created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to create customer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      print('❌ Error creating customer: $e');
      Get.snackbar(
        'Error',
        'Failed to create customer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ✅ Select Customer
  void selectCustomer(Customer? customer) {
    selectedCustomer.value = customer;
    if (customer != null) {
      mobileNumber.value = customer.phone;
    }
  }

  // Fetch Categories
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;

      final response = await ApiProvider.instance.getCategories();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> categoriesData = response['data']['categories'];
        categories.value = categoriesData
            .map((json) => Category.fromJson(json))
            .toList();

        print('✅ Loaded ${categories.length} categories');
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to load categories',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Fetch All Items
  Future<void> fetchAllItems() async {
    try {
      isLoadingItems.value = true;

      final response = await ApiProvider.instance.getAllItems();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> itemsData = response['data']['items'];
        allItems.value = itemsData
            .map((json) => ItemModel.fromJson(json))
            .toList();

        filterItemsByCategory();

        print('✅ Loaded ${allItems.length} items');
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to load items',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error fetching items: $e');
      Get.snackbar(
        'Error',
        'Failed to load items: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingItems.value = false;
    }
  }

  // Filter items by selected category
  void filterItemsByCategory() {
    if (selectedCategoryId.value == 0) {
      products.value = List.from(allItems);
    } else {
      products.value = allItems
          .where((item) => item.categoryId == selectedCategoryId.value)
          .toList();
    }
    print('📊 Filtered ${products.length} items for category: $selectedCategoryName');
  }

  // Select category
  void selectCategory(int categoryId, String categoryName) {
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;
    filterItemsByCategory();
  }

  // Clear category filter
  void clearCategoryFilter() {
    selectedCategoryId.value = 0;
    selectedCategoryName.value = 'ALL';
    filterItemsByCategory();
  }

  // ✅ FIXED: Add to cart with proper multiple items support
  void addToCart(ItemModel item) {
    // Check if customer is selected first
    if (selectedCustomer.value == null) {
      Get.snackbar(
        'Customer Required',
        'Please select a customer first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.person_outline, color: Colors.white),
      );
      return;
    }

    // Find if this exact item already exists in cart
    final existingIndex = cartItems.indexWhere(
            (cartItem) => cartItem.item.id == item.id && cartItem.item.type == item.type
    );

    if (existingIndex != -1) {
      // Item already exists, increment quantity
      cartItems[existingIndex].quantity++;
      cartItems.refresh();

      print('✅ Updated: ${item.name} (${item.type}) - Qty: ${cartItems[existingIndex].quantity}');

      Get.snackbar(
        'Updated',
        '${item.name} quantity: ${cartItems[existingIndex].quantity}',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      // New item, add to cart
      cartItems.add(CartItem(item: item, quantity: 1));

      print('✅ Added: ${item.name} (${item.type}) - Qty: 1');
      print('📊 Total items in cart: ${cartItems.length}');

      Get.snackbar(
        'Added to Cart',
        '${item.name} added',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }

    // Print current cart status
    _printCartStatus();
  }

  // ✅ IMPROVED: Increment quantity
  void incrementQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].quantity++;
      cartItems.refresh();

      print('➕ Increased: ${cartItems[index].item.name} - Qty: ${cartItems[index].quantity}');
      _printCartStatus();
    }
  }

  // ✅ IMPROVED: Decrement quantity
  void decrementQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();

        print('➖ Decreased: ${cartItems[index].item.name} - Qty: ${cartItems[index].quantity}');
      } else {
        // If quantity is 1, remove from cart
        removeFromCart(index);
      }
      _printCartStatus();
    }
  }

  // ✅ IMPROVED: Remove from cart
  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      final itemName = cartItems[index].item.name;
      cartItems.removeAt(index);

      print('🗑️ Removed: $itemName');
      print('📊 Total items in cart: ${cartItems.length}');

      Get.snackbar(
        'Removed',
        '$itemName removed from cart',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      _printCartStatus();
    }
  }

  // ✅ NEW: Helper method to print cart status (for debugging)
  void _printCartStatus() {
    print('═══════════════════════════════════════');
    print('🛒 CART STATUS');
    print('═══════════════════════════════════════');

    if (cartItems.isEmpty) {
      print('📦 Cart is empty');
    } else {
      for (int i = 0; i < cartItems.length; i++) {
        final cartItem = cartItems[i];
        print('${i + 1}. ${cartItem.item.name} (${cartItem.item.type})');
        print('   Qty: ${cartItem.quantity} × RM ${cartItem.item.price.toStringAsFixed(2)}');
        print('   Subtotal: RM ${cartItem.totalPrice.toStringAsFixed(2)}');
        print('   Points: ${cartItem.totalPoints}');
        print('   ---');
      }
      print('📊 Total Items: ${cartItems.length}');
      print('📦 Total Quantity: $totalItemCount');
      print('💰 Grand Total: RM $grandTotal');
      print('⭐ Total Points: $totalPoints');
    }
    print('═══════════════════════════════════════');
  }

  // ✅ IMPROVED: Get total item count (total quantity of all items)
  int get totalItemCount {
    return cartItems.fold(0, (sum, cartItem) => sum + cartItem.quantity);
  }

  // ✅ Calculate grand total (now includes points redemption)
  String get grandTotal {
    double subtotal = cartItems.fold(0.0, (sum, cartItem) => sum + cartItem.totalPrice);
    double pointsValue = pointsRedeemedValue;
    double total = (subtotal - pointsValue).clamp(0.0, double.infinity);
    return total.toStringAsFixed(2);
  }

  // ✅ Calculate subtotal (before points redemption)
  String get subtotalAmount {
    double subtotal = cartItems.fold(0.0, (sum, cartItem) => sum + cartItem.totalPrice);
    return subtotal.toStringAsFixed(2);
  }

  // ✅ Calculate total points
  int get totalPoints {
    return cartItems.fold(0, (sum, cartItem) => sum + cartItem.totalPoints);
  }

  // ✅ NEW: Clear entire cart
  void clearCart() {
    cartItems.clear();
    clearPointsRedemption();
    print('🗑️ Cart cleared');
    Get.snackbar(
      'Cart Cleared',
      'All items removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // ✅ UPDATED: Make Payment with Points Redemption
  Future<void> makePayment() async {
    // Validation checks
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add items to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      );
      return;
    }

    if (selectedBarber.value == null) {
      Get.snackbar(
        'Barber Required',
        'Please select a barber',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.person_outline, color: Colors.white),
      );
      return;
    }

    if (selectedCustomer.value == null) {
      Get.snackbar(
        'Customer Required',
        'Please select a customer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.person_outline, color: Colors.white),
      );
      return;
    }

    if (!isCash.value && !isOnline.value && !isQr.value) {
      Get.snackbar(
        'Payment Method Required',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.payment, color: Colors.white),
      );
      return;
    }

    try {
      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Prepare items for API
      final List<Map<String, dynamic>> apiItems = cartItems.map((cartItem) {
        return {
          'item_type': cartItem.item.type, // 'service' or 'product'
          'item_id': cartItem.item.id,
          'quantity': cartItem.quantity,
          'unit_price': cartItem.item.price,
          'is_redeemed': false,
          'points_used': 0,
        };
      }).toList();

      // Calculate amounts
      final double subtotal = double.parse(subtotalAmount);
      final double discountAmount = 0;

      // ✅ Calculate points redeemed value
      final int pointsRedeemed = pointsToRedeem.value;
      final double pointsValue = pointsRedeemedValue;

      // ✅ Calculate total amount: subtotal - discount - points value
      final double totalAmount = (subtotal - discountAmount - pointsValue).clamp(0.0, double.infinity);

      // Paid amount equals total amount
      final double paidAmount = totalAmount;

      // Determine payment method(s)
      String primaryPaymentMethod = '';
      List<Map<String, dynamic>>? splitPayments;

      // Count selected payment methods
      int paymentMethodCount = 0;
      if (isCash.value) paymentMethodCount++;
      if (isOnline.value) paymentMethodCount++;
      if (isQr.value) paymentMethodCount++;

      if (paymentMethodCount == 1) {
        // Single payment method
        if (isCash.value) {
          primaryPaymentMethod = 'cash';
        } else if (isOnline.value) {
          primaryPaymentMethod = 'online';
        } else if (isQr.value) {
          primaryPaymentMethod = 'qr';
        }
      } else if (paymentMethodCount > 1) {
        // Split payment
        primaryPaymentMethod = 'split';
        splitPayments = [];

        // Divide amount equally among selected methods
        final double amountPerMethod = totalAmount / paymentMethodCount;

        if (isCash.value) {
          splitPayments.add({
            'payment_method': 'cash',
            'amount': amountPerMethod,
          });
        }
        if (isOnline.value) {
          splitPayments.add({
            'payment_method': 'online',
            'amount': amountPerMethod,
          });
        }
        if (isQr.value) {
          splitPayments.add({
            'payment_method': 'qr',
            'amount': amountPerMethod,
          });
        }
      }

      // Get branch_id from selected barber
      final int branchId = selectedBarber.value?.branch?.id ?? 1;

      print('💰 ===== PAYMENT DETAILS =====');
      print('🔧 Barber ID: ${selectedBarber.value?.id}');
      print('👤 Barber Name: ${selectedBarber.value?.fullName}');
      print('🏢 Branch ID: $branchId');
      print('👥 Customer ID: ${selectedCustomer.value?.id}');
      print('📱 Customer: ${selectedCustomer.value?.name}');
      print('💵 Subtotal: RM ${subtotal.toStringAsFixed(2)}');
      print('🎁 Points Redeemed: $pointsRedeemed points');
      print('💰 Points Value: RM ${pointsValue.toStringAsFixed(2)}');
      print('💵 Total Amount: RM ${totalAmount.toStringAsFixed(2)}');
      print('💳 Payment Method: $primaryPaymentMethod');
      if (splitPayments != null) {
        print('💳 Split Payments: $splitPayments');
      }
      print('🛒 Items: $apiItems');
      print('============================');

      // ✅ Call API with points redemption
      final response = await ApiProvider.instance.createSale(
        customerId: selectedCustomer.value!.id,
        barberId: selectedBarber.value!.id!,
        branchId: branchId,
        items: apiItems,
        subtotal: subtotal,
        discountAmount: discountAmount,
        pointsRedeemed: pointsRedeemed,
        pointsRedeemedValue: pointsValue,
        totalAmount: totalAmount,
        paymentMethod: primaryPaymentMethod,
        paidAmount: paidAmount,
        splitPayments: splitPayments,
      );

      // Close loading dialog
      Get.back();

      if (response['success'] == true) {
        final saleData = response['data'];
        final sale = saleData['sale'];
        final customer = saleData['customer'];
        Get.snackbar(
          'Payment Success',
          response['message'] ?? 'Succes to process payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
        _clearAfterPayment();
        // Show success dialog with sale details
        // Get.dialog(
        //   AlertDialog(
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(16),
        //     ),
        //     title: Row(
        //       children: [
        //         Container(
        //           padding: const EdgeInsets.all(8),
        //           decoration: BoxDecoration(
        //             color: Colors.green.withOpacity(0.2),
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //           child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
        //         ),
        //         const SizedBox(width: 12),
        //         const Text(
        //           'Payment Successful!',
        //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        //         ),
        //       ],
        //     ),
        //     content: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         _buildDetailRow('Invoice', sale['invoice_number'] ?? '-'),
        //         _buildDetailRow('Subtotal', 'RM ${subtotal.toStringAsFixed(2)}'),
        //         if (pointsRedeemed > 0) ...[
        //           _buildDetailRow(
        //             'Points Redeemed',
        //             '$pointsRedeemed pts (-RM ${pointsValue.toStringAsFixed(2)})',
        //             valueColor: Colors.blue,
        //           ),
        //         ],
        //         _buildDetailRow('Total', 'RM ${totalAmount.toStringAsFixed(2)}'),
        //         _buildDetailRow('Paid', 'RM ${paidAmount.toStringAsFixed(2)}'),
        //         if (sale['change_amount'] != null && sale['change_amount'] > 0)
        //           _buildDetailRow(
        //             'Change',
        //             'RM ${sale['change_amount'].toStringAsFixed(2)}',
        //             valueColor: Colors.orange,
        //           ),
        //         _buildDetailRow(
        //           'Points Earned',
        //           '${sale['points_earned']} pts',
        //           valueColor: Colors.amber.shade700,
        //         ),
        //         const Divider(height: 24),
        //         Text(
        //           'Customer Points: ${customer['total_points']} pts',
        //           style: TextStyle(
        //             fontSize: 14,
        //             color: Colors.grey.shade700,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //       ],
        //     ),
        //     actions: [
        //       TextButton(
        //         onPressed: () {
        //           Get.back();
        //           _clearAfterPayment();
        //         },
        //         child: const Text('Close'),
        //       ),
        //       // ElevatedButton(
        //       //   onPressed: () {
        //       //     Get.back();
        //       //     _printReceipt(saleData);
        //       //     _clearAfterPayment();
        //       //   },
        //       //   style: ElevatedButton.styleFrom(
        //       //     backgroundColor: const Color(0xFF667EEA),
        //       //     shape: RoundedRectangleBorder(
        //       //       borderRadius: BorderRadius.circular(8),
        //       //     ),
        //       //   ),
        //       //   child: const Text(
        //       //     'Print Receipt',
        //       //     style: TextStyle(color: Colors.white),
        //       //   ),
        //       // ),
        //     ],
        //   ),
        //   barrierDismissible: false,
        // );

        // Refresh customer data to update points
        await fetchCustomers();
      } else {
        Get.snackbar(
          'Payment Failed',
          response['message'] ?? 'Failed to process payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('❌ Error processing payment: $e');
      Get.snackbar(
        'Error',
        'Failed to process payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Helper method to build detail rows in success dialog
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: Helper method to clear cart after successful payment
  void _clearAfterPayment() {
    cartItems.clear();
    isCash.value = false;
    isOnline.value = false;
    isQr.value = false;
    clearPointsRedemption(); // ✅ Clear points redemption
    // Optionally clear barber and customer selection
    selectedBarber.value = null;
    selectedCustomer.value = null;
  }

  // Helper method to print/share receipt (implement as needed)
  void _printReceipt(Map<String, dynamic> saleData) {
    print('📄 Printing receipt for invoice: ${saleData['sale']['invoice_number']}');
    Get.snackbar(
      'Receipt',
      'Receipt functionality to be implemented',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    _clearAfterPayment();
    addFieldController.dispose();
    nameController.dispose();
    pointsController.dispose(); // ✅ Dispose points controller
    super.onClose();
  }
}