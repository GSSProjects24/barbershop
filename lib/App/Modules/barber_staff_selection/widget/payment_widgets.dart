// lib/App/Widgets/payment_widgets.dart

import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/config/app_colors.dart';
import 'package:babershop_project/App/config/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Main Payment Widgets Class
/// Contains all payment-related UI components including single and split payment
class PaymentWidgets {
  /// Build the main payment section container
  static Widget buildPaymentSection(CartController controller) {
    return Builder(
      builder: (context) {
        final sizes = ResponsiveSizes(context);

        return Obx(() => Container(
          padding: EdgeInsets.all(sizes.components.containerPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGold, AppColors.primaryGold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grand Total Row
              _buildTotalRow(controller, sizes),
              const SizedBox(height: 6),

              // Points Row
              _buildPointsRow(controller, sizes),
              const SizedBox(height: 12),

              // Divider
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),

              // Payment Method Label
              Text(
                'Payment Method',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sizes.typography.bodySmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Payment Method Chips
              _buildPaymentMethodChips(controller, sizes, context),

              // Show split payment details if split payment is selected
              if (controller.isSplitPayment.value) ...[
                const SizedBox(height: 12),
                _buildSplitPaymentSummary(controller, sizes),
              ],

              const SizedBox(height: 12),

              // Payment Button
              _buildPaymentButton(controller, sizes, context),
            ],
          ),
        ));
      },
    );
  }

  /// Build Grand Total Row
  static Widget _buildTotalRow(CartController controller, ResponsiveSizes sizes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Grand Total',
          style: TextStyle(
            color: Colors.white,
            fontSize: sizes.typography.bodySmall,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'RM ${controller.grandTotal}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: sizes.typography.headerMedium,
          ),
        ),
      ],
    );
  }

  /// Build Points Row
  static Widget _buildPointsRow(CartController controller, ResponsiveSizes sizes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Points',
          style: TextStyle(
            color: Colors.white,
            fontSize: sizes.typography.bodySmall,
          ),
        ),
        Row(
          children: [
            Icon(Icons.stars, color: Colors.amber, size: sizes.components.iconSizeSmall),
            const SizedBox(width: 4),
            Text(
              '${controller.totalPoints}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: sizes.typography.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Payment Method Chips (Cash, QR, Card, Online, Split)
  static Widget _buildPaymentMethodChips(
      CartController controller,
      ResponsiveSizes sizes,
      BuildContext context,
      ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _paymentChip(
            'Cash',
            Icons.money,
            controller.isCash,
                () => controller.selectPaymentMethod('cash'),
            sizes
        ),
        _paymentChip(
            'QR',
            Icons.qr_code_scanner,
            controller.isQR,
                () => controller.selectPaymentMethod('qr'),
            sizes
        ),
        _paymentChip(
            'Card',
            Icons.credit_card,
            controller.isCard,
                () => controller.selectPaymentMethod('card'),
            sizes
        ),
        // _paymentChip(
        //     'Online',
        //     Icons.payment,
        //     controller.isOnline,
        //         () => controller.selectPaymentMethod('online'),
        //     sizes
        // ),
        _splitPaymentChip(controller, sizes, context),
      ],
    );
  }

  /// Build Single Payment Method Chip
  static Widget _paymentChip(
      String label,
      IconData icon,
      RxBool value,
      VoidCallback onTap,
      ResponsiveSizes sizes,
      ) {
    return Obx(() => FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: sizes.components.iconSizeSmall,
            color: value.value ? AppColors.success : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: value.value ? AppColors.darkGold : AppColors.success,
              fontWeight: value.value ? FontWeight.w600 : FontWeight.w500,
              fontSize: sizes.typography.bodySmall,
            ),
          ),
        ],
      ),
      selected: value.value,
      onSelected: (val) {
        if (val) {
          onTap();
        }
      },
      selectedColor: AppColors.success.withOpacity(0.25),
      backgroundColor: AppColors.success.withOpacity(0.1),
      checkmarkColor: AppColors.success,
      side: BorderSide(
        color: value.value
            ? AppColors.success.withOpacity(0.5)
            : AppColors.success.withOpacity(0.2),
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ));
  }

  /// Build Split Payment Chip
  static Widget _splitPaymentChip(
      CartController controller,
      ResponsiveSizes sizes,
      BuildContext context,
      ) {
    return Obx(() => FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.splitscreen,
            size: sizes.components.iconSizeSmall,
            color: controller.isSplitPayment.value ? AppColors.success : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            'Split',
            style: TextStyle(
              color: controller.isSplitPayment.value ? AppColors.darkGold : AppColors.success,
              fontWeight: controller.isSplitPayment.value ? FontWeight.w600 : FontWeight.w500,
              fontSize: sizes.typography.bodySmall,
            ),
          ),
        ],
      ),
      selected: controller.isSplitPayment.value,
      onSelected: (val) {
        if (val) {
          _showSplitPaymentDialog(context, controller, sizes);
        }
      },
      selectedColor: AppColors.success.withOpacity(0.25),
      backgroundColor: AppColors.success.withOpacity(0.1),
      checkmarkColor: AppColors.success,
      side: BorderSide(
        color: controller.isSplitPayment.value
            ? AppColors.success.withOpacity(0.5)
            : AppColors.success.withOpacity(0.2),
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ));
  }

  /// Build Split Payment Summary (shows after split payment is configured)
  static Widget _buildSplitPaymentSummary(CartController controller, ResponsiveSizes sizes) {
    return Obx(() {
      if (controller.splitPayments.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Split Payment Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sizes.typography.bodySmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showSplitPaymentDialog(
                    Get.context!,
                    controller,
                    sizes,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // List of Split Payments
            ...controller.splitPayments.map((payment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getPaymentIcon(payment['payment_method']),
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          payment['payment_method'].toString().toUpperCase(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: sizes.typography.bodySmall - 1,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'RM ${payment['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sizes.typography.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  /// Get Payment Icon based on payment method
  static IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'qr':
        return Icons.qr_code_scanner;
      case 'card':
        return Icons.credit_card;

      default:
        return Icons.payment;
    }
  }

  /// Build Payment Button (Proceed to Payment)
  static Widget _buildPaymentButton(
      CartController controller,
      ResponsiveSizes sizes,
      BuildContext context,
      ) {
    return Obx(() {
      bool isEnabled = controller.cartItems.isNotEmpty &&
          (controller.isSplitPayment.value
              ? controller.splitPayments.isNotEmpty
              : controller.hasPaymentMethodSelected);

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.primaryGold,
            padding: EdgeInsets.symmetric(vertical: sizes.components.buttonHeight / 4),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: isEnabled ? () => controller.makePayment() : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment,
                size: sizes.components.iconSizeSmall,
                color: AppColors.cardBackground,
              ),
              const SizedBox(width: 6),
              Text(
                'Proceed to Payment',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: sizes.typography.bodyMedium,
                  color: AppColors.cardBackground,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Show Split Payment Dialog
  static void _showSplitPaymentDialog(
      BuildContext context,
      CartController controller,
      ResponsiveSizes sizes,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SplitPaymentDialog(
        controller: controller,
        totalAmount: double.parse(controller.grandTotal),
        sizes: sizes,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SPLIT PAYMENT DIALOG - MATCHING PAYMENT CART STYLE
// ════════════════════════════════════════════════════════════════

/// Split Payment Dialog with Gold Theme matching Payment Cart
class SplitPaymentDialog extends StatefulWidget {
  final CartController controller;
  final double totalAmount;
  final ResponsiveSizes sizes;

  const SplitPaymentDialog({
    Key? key,
    required this.controller,
    required this.totalAmount,
    required this.sizes,
  }) : super(key: key);

  @override
  State<SplitPaymentDialog> createState() => _SplitPaymentDialogState();
}

class _SplitPaymentDialogState extends State<SplitPaymentDialog> {
  final List<Map<String, dynamic>> payments = [];
  String selectedMethod = 'cash';
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing split payments if any
    if (widget.controller.splitPayments.isNotEmpty) {
      payments.addAll(widget.controller.splitPayments);
    }
  }

  /// Calculate total amount paid so far
  double get totalPaid {
    return payments.fold(0.0, (sum, payment) => sum + (payment['amount'] as double));
  }

  /// Calculate remaining amount to be paid
  double get remaining {
    return widget.totalAmount - totalPaid;
  }

  /// Check if payment is complete (total matches)
  bool get isComplete {
    return (remaining).abs() < 0.01; // Allow for floating point precision
  }

  /// Add a new payment to the list
  void _addPayment() {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (amount > remaining) {
      Get.snackbar(
        'Error',
        'Amount exceeds remaining balance',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final payment = <String, dynamic>{
      'payment_method': selectedMethod,
      'amount': amount,
    };

    // Add reference if QR payment
    if (selectedMethod == 'qr' && referenceController.text.isNotEmpty) {
      payment['transaction_reference'] = referenceController.text;
    }

    setState(() {
      payments.add(payment);
      amountController.clear();
      referenceController.clear();
    });

    Get.snackbar(
      'Payment Added',
      '${selectedMethod.toUpperCase()}: RM ${amount.toStringAsFixed(2)}',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  /// Remove a payment from the list
  void _removePayment(int index) {
    setState(() {
      payments.removeAt(index);
    });

    Get.snackbar(
      'Payment Removed',
      'Payment has been removed',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  /// Confirm and save split payment
  void _confirmSplitPayment() {
    if (!isComplete) {
      Get.snackbar(
        'Incomplete Payment',
        'Total paid (RM ${totalPaid.toStringAsFixed(2)}) does not match total amount (RM ${widget.totalAmount.toStringAsFixed(2)})',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    widget.controller.setSplitPayments(payments);
    Navigator.pop(context);

    Get.snackbar(
      'Split Payment Set',
      '${payments.length} payment methods configured',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryGold, AppColors.primaryGold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ═══════════════════════════════════════
                    // HEADER
                    // ═══════════════════════════════════════
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Split Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.sizes.typography.headerMedium,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ═══════════════════════════════════════
                    // TOTAL AND REMAINING SUMMARY (Gold Style)
                    // ═══════════════════════════════════════
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          // Total Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.sizes.typography.bodySmall,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'RM ${widget.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: widget.sizes.typography.headerMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Total Paid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Paid',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.sizes.typography.bodySmall,
                                ),
                              ),
                              Text(
                                'RM ${totalPaid.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: widget.sizes.typography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 16),

                          // Remaining
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Remaining',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: widget.sizes.typography.bodySmall,
                                ),
                              ),
                              Text(
                                'RM ${remaining.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isComplete ? AppColors.success : Colors.amber,
                                  fontWeight: FontWeight.w700,
                                  fontSize: widget.sizes.typography.headerSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // PAYMENT METHOD SELECTION (Chips Style)
                    // ═══════════════════════════════════════
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.sizes.typography.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _methodChip('Cash', 'cash', Icons.money),
                        _methodChip('QR', 'qr', Icons.qr_code_scanner),
                        _methodChip('Card', 'online', Icons.credit_card),
                        //_methodChip('Online', 'online', Icons.payment),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ═══════════════════════════════════════
                    // AMOUNT INPUT (White Style)
                    // ═══════════════════════════════════════
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixText: 'RM ',
                        prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calculate, color: Colors.white70),
                          onPressed: () {
                            // Auto-fill remaining amount
                            if (remaining > 0) {
                              amountController.text = remaining.toStringAsFixed(2);
                            }
                          },
                          tooltip: 'Fill remaining amount',
                        ),
                      ),
                    ),

                    // ═══════════════════════════════════════
                    // TRANSACTION REFERENCE (for QR payments)
                    // ═══════════════════════════════════════
                    if (selectedMethod == 'qr') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: referenceController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Transaction Reference (Optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'e.g., QR-TXN-12345',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.tag, color: Colors.white70),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // ═══════════════════════════════════════
                    // ADD PAYMENT BUTTON (Success Green)
                    // ═══════════════════════════════════════
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: remaining > 0 ? _addPayment : null,
                      ),
                    ),

                    // ═══════════════════════════════════════
                    // PAYMENTS LIST (Gold Cards)
                    // ═══════════════════════════════════════
                    if (payments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Payments Added (${payments.length})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.sizes.typography.bodyMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      ...payments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final payment = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              // Payment Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  PaymentWidgets._getPaymentIcon(payment['payment_method']),
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Payment Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment['payment_method'].toString().toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (payment['transaction_reference'] != null)
                                      Text(
                                        payment['transaction_reference'],
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: widget.sizes.typography.bodySmall - 1,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Amount
                              Text(
                                'RM ${payment['amount'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                onPressed: () => _removePayment(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════
                    // CONFIRM BUTTON (Success Green or Disabled)
                    // ═══════════════════════════════════════
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isComplete ? AppColors.success : Colors.white.withOpacity(0.3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: payments.isNotEmpty ? _confirmSplitPayment : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isComplete ? Icons.check_circle : Icons.hourglass_empty,
                              size: widget.sizes.components.iconSizeSmall,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isComplete ? 'Confirm Split Payment' : 'Add More Payments',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Extra bottom padding for scrolling
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build payment method selection chip (Matching main payment style)
  Widget _methodChip(String label, String value, IconData icon) {
    final isSelected = selectedMethod == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.success : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.darkGold : AppColors.success,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => selectedMethod = value);
        }
      },
      selectedColor: AppColors.success.withOpacity(0.25),
      backgroundColor: AppColors.success.withOpacity(0.1),
      checkmarkColor: AppColors.success,
      side: BorderSide(
        color: isSelected
            ? AppColors.success.withOpacity(0.5)
            : AppColors.success.withOpacity(0.2),
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    referenceController.dispose();
    super.dispose();
  }
}