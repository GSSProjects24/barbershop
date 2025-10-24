import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentWidgets {
  // ✅ Payment Section
  static Widget buildPaymentSection(CartController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
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
          _buildTotalRow(controller),
          const SizedBox(height: 6),
          _buildPointsRow(controller),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          const Text(
            'Payment Method',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildPaymentMethodChips(controller),
          const SizedBox(height: 12),
          _buildPaymentButton(controller),
        ],
      ),
    ));
  }

  static Widget _buildTotalRow(CartController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Grand Total',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          'RM ${controller.grandTotal}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ],
    );
  }

  static Widget _buildPointsRow(CartController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Points', style: TextStyle(color: Colors.white, fontSize: 12)),
        Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              '${controller.totalPoints}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildPaymentMethodChips(CartController controller) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _paymentChip('Cash', Icons.money, controller.isCash, () => controller.selectPaymentMethod('cash')),
        _paymentChip('Online', Icons.credit_card, controller.isOnline, () => controller.selectPaymentMethod('online')),
      ],
    );
  }

  static Widget _paymentChip(String label, IconData icon, RxBool value, VoidCallback onTap) {
    return Obx(() => FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: value.value ? AppColors.success : Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: value.value ? AppColors.darkGold : AppColors.success,
              fontWeight: value.value ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      selected: value.value,
      onSelected: (val) {
        if (val) {
          onTap();
        } else {
          value.value = false;
        }
      },
      selectedColor: AppColors.success.withOpacity(0.25),
      backgroundColor: AppColors.success.withOpacity(0.1),
      checkmarkColor: AppColors.success,
      side: BorderSide(
        color: value.value ? AppColors.success.withOpacity(0.5) : AppColors.success.withOpacity(0.2),
        width: 1.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ));
  }

  static Widget _buildPaymentButton(CartController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.primaryGold,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: controller.cartItems.isEmpty ? null : () => controller.makePayment(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 18, color: AppColors.cardBackground),
            SizedBox(width: 6),
            Text(
              'Proceed to Payment',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.cardBackground),
            ),
          ],
        ),
      ),
    );
  }
}