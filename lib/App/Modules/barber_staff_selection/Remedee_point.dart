// lib/App/widgets/points_redemption_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';

/// Points Redemption Widget
/// This widget allows customers to redeem their loyalty points during checkout
/// Features:
/// - Shows available customer points
/// - Input field for entering points to redeem
/// - "Use Max" button to automatically use maximum allowed points
/// - Real-time calculation and validation
/// - Visual feedback with color-coded containers
class PointsRedemptionWidget extends StatelessWidget {
  final CartController controller;

  const PointsRedemptionWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customer = controller.selectedCustomer.value;
      final availablePoints = controller.availablePoints;
      final subtotal = controller.cartItems.fold(
        0.0,
            (sum, item) => sum + item.totalPrice,
      );

      // Don't show if no customer selected or cart is empty
      if (customer == null || controller.cartItems.isEmpty) {
        return const SizedBox.shrink();
      }

      // Don't show if customer has no points
      if (availablePoints == 0) {
        return const SizedBox.shrink();
      }

      return Container(

        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.stars,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Redeem Points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Available: $availablePoints points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Points Input Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.pointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Points to Redeem',
                      hintText: 'Enter points',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.loyalty),
                      suffixIcon: controller.pointsToRedeem.value > 0
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clearPointsRedemption();
                        },
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      final points = int.tryParse(value) ?? 0;
                      controller.setPointsToRedeem(points);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Use All Points Button
                if (availablePoints > 0)
                  ElevatedButton(
                    onPressed: () {
                      final maxPoints = (subtotal / controller.pointsRedemptionRate).floor();
                      final pointsToUse = availablePoints > maxPoints ? maxPoints : availablePoints;
                      controller.pointsController.text = pointsToUse.toString();
                      controller.setPointsToRedeem(pointsToUse);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Use Max',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // Show redemption value if points entered
            if (controller.pointsToRedeem.value > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.pointsToRedeem.value} points',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-RM ${controller.pointsRedeemedValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Info text
            const SizedBox(height: 8),
            Text(
              '💡 1 point = RM ${controller.pointsRedemptionRate.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    });
  }
}