// lib/App/Modules/barber_staff_selection/categories_controller.dart

import 'package:babershop_project/App/Modules/getcategoriModel/GetCateoriesModel.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetItemModel.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetbarberModel.dart';
import 'package:babershop_project/App/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../provider/sharedprefference.dart';

// Customer Model
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
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  // Customer variables
  var customers = <Customer>[].obs;
  var isLoadingCustomers = false.obs;
  var selectedCustomer = Rx<Customer?>(null);
  var mobileNumber = ''.obs;

  // Add customer form variables
  var showAddField = false.obs;
  final addFieldController = TextEditingController();
  final nameController = TextEditingController();

  // Points redemption variables
  var pointsToRedeem = 0.obs;
  var pointsRedemptionRate = 1.0; // 1 point = RM 1.0 (adjust as needed)
  final pointsController = TextEditingController();

  // Cart items
  var cartItems = <CartItem>[].obs;

  // ✅ SINGLE PAYMENT METHOD FLAGS
  var isCash = false.obs;
  var isOnline = false.obs;
  var isQR = false.obs;
  var isCard = false.obs;

  // ✅ SPLIT PAYMENT FLAGS AND DATA
  var isSplitPayment = false.obs;
  RxList<Map<String, dynamic>> splitPayments = <Map<String, dynamic>>[].obs;

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

    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterItemsByCategory();
    });

    pointsController.addListener(() {
      final value = int.tryParse(pointsController.text) ?? 0;
      if (value != pointsToRedeem.value) {
        setPointsToRedeem(value);
      }
    });
  }

  // ════════════════════════════════════════════════════════════════
  // PAYMENT METHOD FUNCTIONS
  // ════════════════════════════════════════════════════════════════

  /// ✅ Select payment method for SINGLE payment
  void selectPaymentMethod(String method) {
    // Reset all payment methods
    isCash.value = false;
    isOnline.value = false;
    isQR.value = false;
    isCard.value = false;
    isSplitPayment.value = false;
    splitPayments.clear();

    // Set selected method
    switch (method.toLowerCase()) {
      case 'cash':
        isCash.value = true;
        break;
      case 'online':
        isOnline.value = true;
        break;
      case 'qr':
        isQR.value = true;
        break;
      case 'card':
        isCard.value = true;
        break;
    }

    print('💳 Payment method selected: $method');
  }

  /// ✅ Set split payments and update UI state
  void setSplitPayments(List<Map<String, dynamic>> payments) {
    // Reset single payment methods
    isCash.value = false;
    isOnline.value = false;
    isQR.value = false;
    isCard.value = false;

    // Set split payment
    isSplitPayment.value = true;
    splitPayments.value = payments;

    print('✅ Split payments set: $payments');
  }

  /// ✅ Clear split payments and reset to single payment
  void clearSplitPayments() {
    isSplitPayment.value = false;
    splitPayments.clear();
  }

  /// ✅ Get current payment method string
  /// Note: Card displays as "Card" in UI but sends "online" to backend
  String get currentPaymentMethod {
    if (isSplitPayment.value) return 'mixed';
    if (isCash.value) return 'cash';
    if (isOnline.value) return 'online';
    if (isQR.value) return 'qr';
    if (isCard.value) return 'online'; // ✅ Card button displays "Card" but sends "online"
    return '';
  }

  /// ✅ Check if any payment method is selected
  bool get hasPaymentMethodSelected {
    return isCash.value ||
        isOnline.value ||
        isQR.value ||
        isCard.value ||
        isSplitPayment.value;
  }

  // ════════════════════════════════════════════════════════════════
  // POINTS REDEMPTION FUNCTIONS
  // ════════════════════════════════════════════════════════════════

  /// Calculate available points for redemption
  int get availablePoints {
    return selectedCustomer.value?.totalPoints ?? 0;
  }

  /// Calculate points redemption value in currency
  double get pointsRedeemedValue {
    return pointsToRedeem.value * pointsRedemptionRate;
  }

  /// Validate and set points to redeem
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

  /// Clear points redemption
  void clearPointsRedemption() {
    pointsToRedeem.value = 0;
    pointsController.clear();
  }

  // ════════════════════════════════════════════════════════════════
  // BARBER FUNCTIONS
  // ════════════════════════════════════════════════════════════════

  /// Fetch Barbers
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

  /// Select Barber
  void selectBarber(Datum? barber) {
    selectedBarber.value = barber;
    if (barber != null) {
      print('🔧 Selected Barber ID: ${barber.id}');
      print('🔧 Selected Barber Name: ${barber.fullName}');
      print('🔧 Selected Barber Code: ${barber.employeeCode}');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CUSTOMER FUNCTIONS
  // ════════════════════════════════════════════════════════════════

  /// Fetch Customers
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

  /// Create New Customer
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

  /// Select Customer
  void selectCustomer(Customer? customer) {
    selectedCustomer.value = customer;
    if (customer != null) {
      mobileNumber.value = customer.phone;
    }
  }

  /// Search customer by phone
  Future<Customer?> searchCustomerByPhone(String phone) async {
    try {
      if (phone.isEmpty) return null;

      final response = await ApiProvider.instance.searchCustomer(phone);

      if (response['success'] == true && response['found'] == true) {
        final customerData = response['customer'];
        if (customerData != null) {
          return Customer.fromJson(customerData);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error searching customer: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CATEGORY AND ITEM FUNCTIONS
  // ════════════════════════════════════════════════════════════════

  /// Fetch Categories
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

  /// Fetch All Items
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

  /// Filter items by category and search
  void filterItemsByCategory() {
    List<ItemModel> filtered = List.from(allItems);

    // Filter by category
    if (selectedCategoryId.value != 0) {
      filtered = filtered
          .where((item) => item.categoryId == selectedCategoryId.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.title.toLowerCase().contains(query) ||
            item.sku.toLowerCase().contains(query);
      }).toList();
    }

    products.value = filtered;

    print('📊 Filtered ${products.length} items | Category: $selectedCategoryName | Search: "${searchQuery.value}"');
  }

  /// Select category
  void selectCategory(int categoryId, String categoryName) {
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;
    filterItemsByCategory();
  }

  /// Clear category filter
  void clearCategoryFilter() {
    selectedCategoryId.value = 0;
    selectedCategoryName.value = 'ALL';
    filterItemsByCategory();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterItemsByCategory();
  }

  // ════════════════════════════════════════════════════════════════
  // CART MANAGEMENT FUNCTIONS
  // ════════════════════════════════════════════════════════════════
  /// Reorder cart items manually
  void reorderCartItems(int oldIndex, int newIndex) {
    // Adjust newIndex if moving item down the list
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Remove item from old position
    final CartItem item = cartItems.removeAt(oldIndex);

    // Insert at new position
    cartItems.insert(newIndex, item);

    print('🔄 Reordered: ${item.item.name} from position $oldIndex to $newIndex');
    _printCartStatus();
  }
  /// Add to cart with proper multiple items support
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
      //
      // Get.snackbar(
      //   'Added to Cart',
      //   '${item.name} added',
      //   snackPosition: SnackPosition.TOP,
      //   duration: const Duration(seconds: 1),
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    }

    // Print current cart status
    _printCartStatus();
  }

  /// Increment quantity
  void incrementQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].quantity++;
      cartItems.refresh();

      print('➕ Increased: ${cartItems[index].item.name} - Qty: ${cartItems[index].quantity}');
      _printCartStatus();
    }
  }

  /// Decrement quantity
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

  /// Remove from cart
  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      final itemName = cartItems[index].item.name;
      cartItems.removeAt(index);

      print('🗑️ Removed: $itemName');
      print('📊 Total items in cart: ${cartItems.length}');


      _printCartStatus();
    }
  }

  /// Helper method to print cart status (for debugging)
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

  /// Get total item count (total quantity of all items)
  int get totalItemCount {
    return cartItems.fold(0, (sum, cartItem) => sum + cartItem.quantity);
  }

  /// Calculate grand total (includes points redemption)
  String get grandTotal {
    double subtotal = cartItems.fold(0.0, (sum, cartItem) => sum + cartItem.totalPrice);
    double pointsValue = pointsRedeemedValue;
    double total = (subtotal - pointsValue).clamp(0.0, double.infinity);
    return total.toStringAsFixed(2);
  }

  /// Calculate subtotal (before points redemption)
  String get subtotalAmount {
    double subtotal = cartItems.fold(0.0, (sum, cartItem) => sum + cartItem.totalPrice);
    return subtotal.toStringAsFixed(2);
  }

  /// Calculate total points
  int get totalPoints {
    return cartItems.fold(0, (sum, cartItem) => sum + cartItem.totalPoints);
  }

  /// Clear entire cart
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

  // ════════════════════════════════════════════════════════════════
  // PAYMENT PROCESSING
  // ════════════════════════════════════════════════════════════════

  /// ✅ Validate payment before processing
  bool _validatePayment() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add items to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      );
      return false;
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
      return false;
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
      return false;
    }

    // Validate payment method selected
    if (!hasPaymentMethodSelected) {
      Get.snackbar(
        'Payment Method Required',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.payment, color: Colors.white),
      );
      return false;
    }

    // Validate split payment if selected
    if (isSplitPayment.value) {
      if (splitPayments.isEmpty) {
        Get.snackbar(
          'Split Payment Required',
          'Please add split payments',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final totalSplit = splitPayments.fold<double>(
          0.0,
              (sum, payment) => sum + (payment['amount'] as double)
      );

      final grandTotalValue = double.parse(grandTotal);
      if ((totalSplit - grandTotalValue).abs() > 0.01) {
        Get.snackbar(
          'Split Payment Mismatch',
          'Split payment total (RM ${totalSplit.toStringAsFixed(2)}) does not match grand total (RM ${grandTotalValue.toStringAsFixed(2)})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    }

    return true;
  }

  /// ✅ Make Payment - Handles both Single and Split Payments
  Future<void> makePayment() async {
    if (!_validatePayment()) return;

    try {
      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Prepare items for API
      final List<Map<String, dynamic>> apiItems = cartItems.map((cartItem) {
        return {
          'item_type': cartItem.item.type,
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
      final int pointsRedeemed = pointsToRedeem.value;
      final double pointsValue = pointsRedeemedValue;
      final double totalAmount = (subtotal - discountAmount - pointsValue).clamp(0.0, double.infinity);
      final double paidAmount = totalAmount;

      // Get branch ID
      final int? branchId = SharedPrefService.instance.getBranchId();

      if (branchId == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Branch ID not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Determine payment method
      String paymentMethod = currentPaymentMethod;

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
      print('💳 Payment Method: $paymentMethod');

      if (isSplitPayment.value) {
        print('💳 Split Payments:');
        for (var payment in splitPayments) {
          print('   - ${payment['payment_method']}: RM ${payment['amount']}');
          if (payment['transaction_reference'] != null) {
            print('     Ref: ${payment['transaction_reference']}');
          }
        }
      }

      print('🛒 Items: $apiItems');
      print('============================');

      // ✅ Call API with conditional split payments
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
        paymentMethod: paymentMethod,
        paidAmount: paidAmount,
        splitPayments: isSplitPayment.value ? splitPayments : null,
      );

      // Close loading
      Get.back();

      if (response['success'] == true) {
        // Clear cart first (instant)
        _clearAfterPayment();

        // Update customer points locally (instant UI update)
        if (selectedCustomer.value != null && pointsRedeemed > 0) {
          final currentCustomer = selectedCustomer.value!;
          final newPointsTotal = (currentCustomer.totalPoints - pointsRedeemed).clamp(0, double.infinity).toInt();

          // Update selected customer with new points
          selectedCustomer.value = Customer(
            id: currentCustomer.id,
            customerCode: currentCustomer.customerCode,
            phone: currentCustomer.phone,
            name: currentCustomer.name,
            email: currentCustomer.email,
            totalPoints: newPointsTotal,
          );

          // Also update in the customers list
          final customerIndex = customers.indexWhere((c) => c.id == currentCustomer.id);
          if (customerIndex != -1) {
            customers[customerIndex] = selectedCustomer.value!;
          }

          print('✅ Customer points updated locally: ${currentCustomer.totalPoints} → $newPointsTotal');
        }

        // 🧾 Show receipt dialog
        _showReceiptDialog(response: response);

        // Refresh customer data in background (non-blocking)
        fetchCustomers().then((_) {
          print('✅ Customer data synced with server');
        }).catchError((error) {
          print('⚠️ Background customer refresh failed: $error');
        });

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

// 🧾 Receipt Dialog
// 🧾 Receipt Dialog - Updated to use API response
// 🧾 Receipt Dialog - Updated to use API response
  void _showReceiptDialog({
    required Map<String, dynamic> response,
  }) {
    final data = response['data'] ?? {};
    final sale = data['sale'] ?? {};
    final customer = data['customer'] ?? {};
    final barber = data['barber'] ?? {};
    final items = data['items'] ?? [];

    // Extract sale details
    final String invoiceNumber = sale['invoice_number'] ?? 'N/A';
    final String saleDate = sale['sale_date'] ?? DateTime.now().toString();
    final double subtotal = (sale['subtotal'] ?? 0).toDouble();
    final double discountAmount = (sale['discount_amount'] ?? 0).toDouble();
    final int pointsRedeemed = sale['points_redeemed'] ?? 0;
    final double pointsRedeemedValue = (sale['points_redeemed_value'] ?? 0).toDouble();
    final double totalAmount = (sale['total_amount'] ?? 0).toDouble();
    final double paidAmount = (sale['paid_amount'] ?? 0).toDouble();
    final double changeAmount = (sale['change_amount'] ?? 0).toDouble();
    final String paymentMethod = sale['payment_method'] ?? 'N/A';
    final int pointsEarned = sale['points_earned'] ?? 0;
    final bool isSplitPayment = sale['is_split_payment'] ?? false;
    final List<dynamic> payments = sale['payments'] ?? [];

    // Extract customer details
    final String customerName = customer['name'] ?? 'N/A';
    final String customerPhone = customer['phone'] ?? 'N/A';
    final int customerTotalPoints = customer['total_points'] ?? 0;

    // Extract barber details
    final String barberName = barber['full_name'] ?? 'N/A';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 450,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Business Info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // Business Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.content_cut,
                        color: Colors.green.shade700,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Business Name
                    const Text(
                      'Legend Studio Barber Shop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Business Address
                    const Text(
                      'Bandar Seri Alam, Masai',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      '66, Jalan Lembah 19, Bandar Baru Seri Alam',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      '81750 Masai, Johor',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Phone Number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '0173301012',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 8),

                    // Invoice Number Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        invoiceNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Receipt Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Info
                      _buildSectionTitle('Transaction Details'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Date & Time', _formatDate(saleDate)),
                      _buildInfoRow('Customer', '$customerName ($customerPhone)'),
                      _buildInfoRow('Barber', barberName),

                      const SizedBox(height: 24),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 24),

                      // Items
                      _buildSectionTitle('Items (${items.length})'),
                      const SizedBox(height: 12),
                      ...items.map((item) {
                        final String itemName = item['item_name'] ?? '';
                        final String itemType = item['item_type'] ?? '';
                        final int quantity = item['quantity'] ?? 0;
                        final double unitPrice = (item['unit_price'] ?? 0).toDouble();
                        final double totalAmount = (item['total_amount'] ?? 0).toDouble();
                        final int itemPointsEarned = item['points_earned'] ?? 0;

                        return _buildItemRow(
                          name: itemName,
                          type: itemType,
                          quantity: quantity,
                          unitPrice: unitPrice,
                          total: totalAmount,
                          pointsEarned: itemPointsEarned,
                        );
                      }).toList(),

                      const SizedBox(height: 24),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 16),

                      // Financial Summary
                      _buildAmountRow('Subtotal', subtotal),
                      if (discountAmount > 0)
                        _buildAmountRow('Discount', -discountAmount, isDiscount: true),
                      if (pointsRedeemed > 0)
                        _buildAmountRow(
                          'Points Redeemed ($pointsRedeemed pts)',
                          -pointsRedeemedValue,
                          isDiscount: true,
                        ),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildAmountRow(
                          'Total Amount',
                          totalAmount,
                          isTotal: true,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 16),

                      // Payment Details
                      _buildSectionTitle('Payment Information'),
                      const SizedBox(height: 12),

                      if (!isSplitPayment) ...[
                        _buildInfoRow('Payment Method', paymentMethod.toUpperCase()),
                        _buildInfoRow('Amount Paid', 'RM ${paidAmount.toStringAsFixed(2)}'),
                        if (changeAmount > 0)
                          _buildInfoRow('Change', 'RM ${changeAmount.toStringAsFixed(2)}'),
                      ] else ...[
                        _buildInfoRow('Payment Type', 'Split Payment'),
                        const SizedBox(height: 8),
                        ...payments.map((payment) {
                          final String method = payment['payment_method'] ?? '';
                          final double amount = (payment['amount'] ?? 0).toDouble();
                          final String? reference = payment['transaction_reference'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      method.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'RM ${amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (reference != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ref: $reference',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ],

                      // Points Summary
                      if (pointsEarned > 0 || pointsRedeemed > 0) ...[
                        const SizedBox(height: 24),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber.shade50, Colors.orange.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.stars, color: Colors.orange.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Loyalty Points',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (pointsEarned > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Points Earned:', style: TextStyle(fontSize: 14)),
                                    Text(
                                      '+$pointsEarned pts',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              if (pointsRedeemed > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Points Used:', style: TextStyle(fontSize: 14)),
                                    Text(
                                      '-$pointsRedeemed pts',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Points Balance:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$customerTotalPoints pts',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Footer Note
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Thank you for your visit!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    // Expanded(
                    //   child: OutlinedButton.icon(
                    //     onPressed: () {
                    //       // TODO: Implement print receipt
                    //       print('🖨️ Print receipt: $invoiceNumber');
                    //       Get.back();
                    //     },
                    //     icon: const Icon(Icons.print_outlined),
                    //     label: const Text('Print Receipt'),
                    //     style: OutlinedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(vertical: 14),
                    //       side: BorderSide(color: Colors.grey.shade400),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

// Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String name,
    required String type,
    required int quantity,
    required double unitPrice,
    required double total,
    required int pointsEarned,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$quantity x RM ${unitPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (pointsEarned > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.stars, size: 12, color: Colors.orange.shade600),
                        const SizedBox(width: 2),
                        Text(
                          '+$pointsEarned pts',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTotal ? 12 : 0,
        vertical: isTotal ? 0 : 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green.shade700 : (isTotal ? Colors.black : Colors.grey.shade700),
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}RM ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? Colors.green.shade700 : (isTotal ? Colors.green.shade700 : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }


  /// Helper method to clear cart after successful payment
  void _clearAfterPayment() {
    cartItems.clear();
    isCash.value = false;
    isOnline.value = false;
    isQR.value = false;
    isCard.value = false;
    isSplitPayment.value = false;
    splitPayments.clear();
    clearPointsRedemption();

    // Optionally clear barber and customer selection
    selectedBarber.value = null;
    selectedCustomer.value = null;
  }

  // ════════════════════════════════════════════════════════════════
  // RESET FUNCTIONS
  // ════════════════════════════════════════════════════════════════

  /// Reset/Refresh everything with confirmation
  void resetAll() {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Cancel Order?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this order?\n\nAll selections will be cleared.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'No, Keep It',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _performReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Yes, Cancel Order',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Perform the actual reset
  void _performReset() {
    // Clear cart items
    cartItems.clear();

    // Clear selections
    selectedBarber.value = null;
    selectedCustomer.value = null;
    mobileNumber.value = '';

    // Clear payment methods
    isCash.value = false;
    isOnline.value = false;
    isQR.value = false;
    isCard.value = false;
    isSplitPayment.value = false;
    splitPayments.clear();

    // Clear points redemption
    clearPointsRedemption();

    // Clear text fields
    addFieldController.clear();
    nameController.clear();

    // Hide add customer field if shown
    showAddField.value = false;

    print('🔄 All data has been reset');

    Get.snackbar(
      'Reset Complete',
      'All selections and cart have been cleared',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    addFieldController.dispose();
    nameController.dispose();
    pointsController.dispose();
    searchController.dispose();
    super.onClose();
  }
}