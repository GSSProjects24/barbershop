import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/config/responsive_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PointsRedemptionWidget extends StatelessWidget {
  final CartController controller;

  const PointsRedemptionWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizes = ResponsiveSizes(context);

    return Obx(() {
      final customer = controller.selectedCustomer.value;
      final availablePoints = controller.availablePoints;
      final subtotal = controller.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      if (customer == null || controller.cartItems.isEmpty) {
        return const SizedBox.shrink();
      }

      if (availablePoints == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(sizes.components.containerPadding),
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
            _buildHeader(availablePoints, sizes),
            SizedBox(height: sizes.layout.sectionSpacing),
            _buildInputRow(controller, subtotal, availablePoints, sizes),
            if (controller.pointsToRedeem.value > 0) ...[
              const SizedBox(height: 12),
              _buildRedemptionValue(controller, sizes),
            ],
            const SizedBox(height: 8),
            _buildInfoText(controller, sizes),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(int availablePoints, ResponsiveSizes sizes) {
    return Row(
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
            size: sizes.components.iconSizeMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Redeem Points',
                style: TextStyle(
                  fontSize: sizes.typography.headerSmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Available: $availablePoints points',
                style: TextStyle(
                  fontSize: sizes.typography.bodySmall,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(
      CartController controller,
      double subtotal,
      int availablePoints,
      ResponsiveSizes sizes,
      ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.pointsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Points to Redeem',
              labelStyle: TextStyle(fontSize: sizes.typography.bodySmall),
              hintText: 'Enter points',
              hintStyle: TextStyle(fontSize: sizes.typography.bodySmall),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: Icon(Icons.loyalty, size: sizes.components.iconSizeMedium),
              suffixIcon: controller.pointsToRedeem.value > 0
                  ? IconButton(
                icon: Icon(Icons.clear, size: sizes.components.iconSizeSmall),
                onPressed: () => controller.clearPointsRedemption(),
              )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: sizes.components.containerPadding,
                vertical: 12,
              ),
            ),
            style: TextStyle(fontSize: sizes.typography.bodyMedium),
            onChanged: (value) {
              final points = int.tryParse(value) ?? 0;
              controller.setPointsToRedeem(points);
            },
          ),
        ),
        const SizedBox(width: 12),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(
                horizontal: sizes.components.containerPadding,
                vertical: 12,
              ),
            ),
            child: Text(
              'Use Max',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: sizes.typography.bodyMedium,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRedemptionValue(CartController controller, ResponsiveSizes sizes) {
    return Container(
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
              Icon(Icons.check_circle, color: Colors.green.shade700, size: sizes.components.iconSizeMedium),
              const SizedBox(width: 8),
              Text(
                '${controller.pointsToRedeem.value} points',
                style: TextStyle(
                  fontSize: sizes.typography.bodyMedium,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '-RM ${controller.pointsRedeemedValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: sizes.typography.bodyLarge,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(CartController controller, ResponsiveSizes sizes) {
    return Text(
      '💡 1 point = RM ${controller.pointsRedemptionRate.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: sizes.typography.caption,
        color: Colors.grey.shade600,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
