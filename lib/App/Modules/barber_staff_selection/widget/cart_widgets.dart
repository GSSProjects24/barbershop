
import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/customer_widgets.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/payment_widgets.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/points_redemption_widget.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartWidgets {
  // ✅ Build Cart List
  static Widget buildCartList(
      CartController controller, {
        double maxHeight = 400,
        double? containerHeight, // ✅ NEW: Optional container height
      }) {
    return Obx(() => Container(
      height: containerHeight, // ✅ Use passed height or null for flexible
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCartHeader(controller),
          const SizedBox(height: 12),
          controller.cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartItemsList(controller, maxHeight),
        ],
      ),
    ));
  }

  static Widget _buildCartHeader(CartController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cart Item',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              if (controller.selectedCustomer.value != null) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.amber.shade600]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.selectedCustomer.value!.totalPoints}',
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'pts',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            if (controller.cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${controller.totalItemCount} items',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.orangeAccent),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static Widget _buildEmptyCart() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Cart is empty', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }

  static Widget _buildCartItemsList(CartController controller, double maxHeight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final calculatedMaxHeight = maxHeight == double.infinity ? screenHeight * 0.5 : maxHeight;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: calculatedMaxHeight, minHeight: 100),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.cartItems.length,
            separatorBuilder: (_, __) => Divider(height: 8, thickness: 0.5, color: Colors.grey.shade200),
            itemBuilder: (_, index) => _buildCartItem(controller, index),
          ),
        );
      },
    );
  }

  static Widget _buildCartItem(CartController controller, int index) {
    final cartItem = controller.cartItems[index];
    final item = cartItem.item;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.star, size: 11, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    if (cartItem.quantity > 1) ...[
                      Text(
                        '${item.pointsEarned} × ${cartItem.quantity} = ',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      Text(
                        '${cartItem.totalPoints}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w700),
                      ),
                    ] else
                      Text(
                        '${cartItem.totalPoints}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600),
                      ),
                    Text(' pts', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildQuantityControls(controller, index, cartItem),
          const SizedBox(width: 8),
          _buildPriceColumn(cartItem, item),
        ],
      ),
    );
  }

  static Widget _buildQuantityControls(CartController controller, int index, cartItem) {
    return Row(
      children: [
        InkWell(
          onTap: () => controller.decrementQuantity(index),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.shade200, width: 1),
            ),
            child: Icon(
              cartItem.quantity == 1 ? Icons.delete_outline : Icons.remove,
              size: 14,
              color: Colors.red.shade700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        InkWell(
          onTap: () => controller.incrementQuantity(index),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green.shade200, width: 1),
            ),
            child: Icon(Icons.add, size: 14, color: Colors.green.shade700),
          ),
        ),
      ],
    );
  }

  static Widget _buildPriceColumn(cartItem, item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'RM ${cartItem.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981), fontSize: 13),
        ),
        if (cartItem.quantity > 1)
          Text(
            '@${item.price.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
          ),
      ],
    );
  }

  // ✅ Mobile Bottom Sheet
  static void showCartBottomSheet(BuildContext context, CartController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomerWidgets.buildBarberSelection(controller, isMobile: true),
                    const SizedBox(height: 16),
                    buildCartList(controller, maxHeight: 500), // ✅ Mobile: 500
                    const SizedBox(height: 16),
                    PointsRedemptionWidget(controller: controller),
                    const SizedBox(height: 16),
                    PaymentWidgets.buildPaymentSection(controller),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}