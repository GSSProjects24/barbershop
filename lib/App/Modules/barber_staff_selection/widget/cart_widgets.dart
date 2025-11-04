import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/customer_widgets.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/payment_widgets.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/points_redemption_widget.dart';
import 'package:babershop_project/App/config/responsive_size.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartWidgets {
  // ✅ Build Cart List
  static Widget buildCartList(
      CartController controller, {
        double maxHeight = 400,
        double? containerHeight,
      }) {
    return Builder(
      builder: (context) {
        final sizes = ResponsiveSizes(context);

        return Obx(() => Container(
          height: containerHeight,
          padding: EdgeInsets.all(sizes.components.containerPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(sizes.components.containerBorderRadius),
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
              _buildCartHeader(controller, sizes),
              const SizedBox(height: 12),
              controller.cartItems.isEmpty
                  ? _buildEmptyCart(sizes)
                  : _buildCartItemsList(controller, maxHeight, sizes),
            ],
          ),
        ));
      },
    );
  }

  static Widget _buildCartHeader(CartController controller, ResponsiveSizes sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cart Item',
              style: TextStyle(
                fontSize: sizes.typography.headerSmall,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36),
              ),
            ),
            if (controller.cartItems.isNotEmpty ||
                controller.selectedBarber.value != null ||
                controller.selectedCustomer.value != null)
              IconButton(
                onPressed: () => controller.resetAll(),
                icon: Icon(
                  Icons.refresh,
                  color: Colors.orange.shade700,
                  size: sizes.components.iconSizeMedium,
                ),
                tooltip: 'Reset All',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              if (controller.selectedCustomer.value != null) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade700, Colors.amber.shade600],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars, color: Colors.white, size: sizes.components.iconSizeSmall),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.selectedCustomer.value!.totalPoints}',
                        style: TextStyle(
                          fontSize: sizes.typography.caption,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'pts',
                        style: TextStyle(
                          fontSize: sizes.typography.caption - 2,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: sizes.typography.caption,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static Widget _buildEmptyCart(ResponsiveSizes sizes) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Cart is empty',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: sizes.typography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCartItemsList(
      CartController controller,
      double maxHeight,
      ResponsiveSizes sizes,
      ) {
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
            separatorBuilder: (_, __) => Divider(
              height: 8,
              thickness: 0.5,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (_, index) => _buildCartItem(controller, index, sizes),
          ),
        );
      },
    );
  }

  static Widget _buildCartItem(CartController controller, int index, ResponsiveSizes sizes) {
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: sizes.components.cartItemFontSize,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.star, size: 11, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    if (cartItem.quantity > 1) ...[
                      Text(
                        '${item.pointsEarned} × ${cartItem.quantity} = ',
                        style: TextStyle(
                          fontSize: sizes.typography.caption - 1,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '${cartItem.totalPoints}',
                        style: TextStyle(
                          fontSize: sizes.typography.caption - 1,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else
                      Text(
                        '${cartItem.totalPoints}',
                        style: TextStyle(
                          fontSize: sizes.typography.caption - 1,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      ' pts',
                      style: TextStyle(
                        fontSize: sizes.typography.caption - 2,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildQuantityControls(controller, index, cartItem, sizes),
          const SizedBox(width: 8),
          _buildPriceColumn(cartItem, item, sizes),
        ],
      ),
    );
  }

  static Widget _buildQuantityControls(
      CartController controller,
      int index,
      cartItem,
      ResponsiveSizes sizes,
      ) {
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
          child: Text(
            '${cartItem.quantity}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: sizes.components.cartItemFontSize,
            ),
          ),
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

  static Widget _buildPriceColumn(cartItem, item, ResponsiveSizes sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'RM ${cartItem.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF10B981),
            fontSize: sizes.components.cartItemFontSize,
          ),
        ),
        if (cartItem.quantity > 1)
          Text(
            '@${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: sizes.typography.caption - 2,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }

  // ✅ Mobile Bottom Sheet - Fully Scrollable
  static void showCartBottomSheet(BuildContext context, CartController controller) {
    final sizes = ResponsiveSizes(context);
    final layout = sizes.layout;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: layout.bottomSheetHeightFactor ?? 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Fully Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(layout.pagePadding),
                  child: Column(
                    children: [
                      CustomerWidgets.buildBarberSelection(controller, isMobile: true),
                      SizedBox(height: layout.sectionSpacing),
                      buildCartList(controller, maxHeight: layout.cartMaxHeight),
                      SizedBox(height: layout.sectionSpacing),
                      PointsRedemptionWidget(controller: controller),
                      SizedBox(height: layout.sectionSpacing),
                      PaymentWidgets.buildPaymentSection(controller),
                      SizedBox(height: layout.sectionSpacing + 20), // Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}