import 'package:babershop_project/App/Modules/barber_staff_selection/report_controller.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetBarberReportModel.dart';
import 'package:babershop_project/App/config/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportsPageSimple extends StatelessWidget {
  const ReportsPageSimple({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllReports(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Section
            _buildFiltersSection(controller, context),
            const SizedBox(height: 20),

            // Sales Report
            _buildSectionTitle('Sales Summary', Icons.analytics),
            const SizedBox(height: 12),
            _buildSalesReport(controller),
            const SizedBox(height: 24),

            // Barbers Performance
            _buildSectionTitle('Barber Performance', Icons.people),
            const SizedBox(height: 12),
            _buildBarbersReport(controller),
            const SizedBox(height: 24),

            // Payment Breakdown
            _buildSectionTitle('Payment Breakdown', Icons.payment),
            const SizedBox(height: 12),
            _buildPaymentsReport(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.primaryGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(ReportsController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Date Ranges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _quickDateChip('Today', 'today', controller),
              _quickDateChip('This Week', 'this_week', controller),
              _quickDateChip('This Month', 'this_month', controller),
              _quickDateChip('Last Month', 'last_month', controller),
            ],
          ),
          const SizedBox(height: 12),

          // Custom Date Range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.selectDateFrom(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => Text(
                            controller.formatDate(controller.selectedDateFrom.value),
                            style: const TextStyle(fontSize: 13),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => controller.selectDateTo(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => Text(
                            controller.formatDate(controller.selectedDateTo.value),
                            style: const TextStyle(fontSize: 13),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickDateChip(String label, String value, ReportsController controller) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        if (selected) controller.setQuickDateRange(value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primaryGold.withOpacity(0.2),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // ✅ CORRECTED _buildSalesReport - Calculates summary from sales list
  Widget _buildSalesReport(ReportsController controller) {
    return Obx(() {
      if (controller.isLoadingSales.value) {
        return _buildLoadingCard();
      }

      final salesReport = controller.salesData.value;

      if (salesReport == null || salesReport.success != true) {
        return _buildEmptyCard('No sales data available');
      }

      if (salesReport.data == null || salesReport.data!.isEmpty) {
        return _buildEmptyCard('No sales found for this period');
      }

      final summary = salesReport.getSummary();

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sales',
                  'RM ${_formatNumber(summary.totalSales)}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Orders',
                  '${summary.totalOrders}',
                  Icons.shopping_bag,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Avg Order',
                  'RM ${_formatNumber(summary.averageOrderValue)}',
                  Icons.show_chart,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Items Sold',
                  '${summary.totalItemsSold}',
                  Icons.inventory,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ✅ Build Barbers Report with typed model
  Widget _buildBarbersReport(ReportsController controller) {
    return Obx(() {
      if (controller.isLoadingBarbers.value) {
        return _buildLoadingCard();
      }

      final barberReport = controller.barbersData.value;

      if (barberReport == null ||
          barberReport.success != true ||
          barberReport.data == null ||
          barberReport.data!.isEmpty) {
        return _buildEmptyCard('No barber performance data found');
      }

      final barbersToShow = barberReport.data!.take(5).toList();

      return Column(
        children: [
          if (barberReport.period != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: AppColors.primaryGold),
                  const SizedBox(width: 8),
                  Text(
                    'Period: ${_formatDate(barberReport.period!.from)} - ${_formatDate(barberReport.period!.to)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
            ),

          ...barbersToShow.asMap().entries.map((entry) {
            final index = entry.key;
            final barber = entry.value;
            return _buildBarberCardTyped(barber, index + 1);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildBarberCardTyped(Datum barber, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: rank == 1
                        ? [Colors.amber.shade400, Colors.amber.shade600]
                        : [Colors.grey.shade200, Colors.grey.shade300],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barber.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (barber.branchName != null)
                      Text(
                        barber.branchName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                'RM ${_formatNumber(barber.totalRevenue ?? '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBarberStat(
                  'Sales',
                  '${barber.totalSales ?? 0}',
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildBarberStat(
                  'Services',
                  '${barber.totalServices ?? 0}',
                  Icons.content_cut,
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildBarberStat(
                  'Avg Value',
                  'RM ${_formatNumber(barber.avgServiceValue ?? '0')}',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildBarberStat(
                  'Commission',
                  'RM ${_formatNumber(barber.totalCommission ?? '0')}',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildBarberStat(
                  'Rate',
                  '${_formatNumber(barber.avgCommissionRate ?? '0')}%',
                  Icons.percent,
                  Colors.teal,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarberStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F36),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ CORRECTED _buildPaymentsReport - Uses typed model and calculates breakdown
  Widget _buildPaymentsReport(ReportsController controller) {
    return Obx(() {
      if (controller.isLoadingPayments.value) {
        return _buildLoadingCard();
      }

      final paymentReport = controller.paymentsData.value;

      if (paymentReport == null || paymentReport.success != true) {
        return _buildEmptyCard('No payment data available');
      }

      if (paymentReport.data == null || paymentReport.data!.isEmpty) {
        return _buildEmptyCard('No payments found for this period');
      }

      final breakdown = paymentReport.getPaymentMethodBreakdown();

      if (breakdown.isEmpty) {
        return _buildEmptyCard('No payment breakdown available');
      }

      return Column(
        children: breakdown.map((method) {
          return _buildPaymentMethodCard(
            method.paymentMethod,
            method.totalAmount,
            method.count,
          );
        }).toList(),
      );
    });
  }

  Widget _buildPaymentMethodCard(String paymentMethod, double amount, int count) {
    final methodUpper = paymentMethod.toUpperCase();

    IconData icon;
    Color color;

    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        icon = Icons.money;
        color = Colors.green;
        break;
      case 'qr':
        icon = Icons.qr_code_scanner;
        color = Colors.blue;
        break;
      case 'card':
        icon = Icons.credit_card;
        color = Colors.purple;
        break;
      case 'online':
        icon = Icons.payment;
        color = Colors.orange;
        break;
      case 'split':
        icon = Icons.splitscreen;
        color = Colors.teal;
        break;
      default:
        icon = Icons.payments;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  methodUpper,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$count transactions',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            'RM ${_formatNumber(amount)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0.00';
    final number = value is String ? double.tryParse(value) ?? 0 : value.toDouble();
    return number.toStringAsFixed(2);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}