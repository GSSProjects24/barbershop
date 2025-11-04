import 'package:babershop_project/App/Modules/getcategoriModel/GetBarberReportModel.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetSalesReportModel.dart';

import 'package:babershop_project/App/provider/api_provider.dart';
import 'package:babershop_project/App/provider/sharedprefference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../getcategoriModel/GetPaymentReportModel.dart';

class ReportsController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider.instance;

  // Loading states
  final isLoadingSales = false.obs;
  final isLoadingBarbers = false.obs;
  final isLoadingPayments = false.obs;

  // Report data - ✅ All using typed models now!
  final salesData = Rx<GetSalesReportModel?>(null);
  final barbersData = Rx<GetBarberReportModel?>(null);
  final paymentsData = Rx<GetPaymentReportModel?>(null);

  // Filters
  final selectedDateFrom = Rx<DateTime?>(null);
  final selectedDateTo = Rx<DateTime?>(null);
  final selectedPaymentMethod = Rx<String?>(null);
  final selectedPaymentStatus = Rx<String?>(null);

  // Tab index
  final selectedTabIndex = 0.obs;

  final paymentMethods = ['cash', 'qr', 'card', 'online', 'split'];
  final paymentStatuses = ['paid', 'pending', 'cancelled'];

  @override
  void onInit() {
    super.onInit();
    // Set default date range (current month)
    final now = DateTime.now();
    selectedDateFrom.value = DateTime(now.year, now.month, 1);
    selectedDateTo.value = DateTime(now.year, now.month + 1, 0);

    // Load initial data
    fetchAllReports();
  }

  // Fetch all reports
  Future<void> fetchAllReports() async {
    await Future.wait([
      fetchSalesReport(),
      fetchBarbersReport(),
      fetchPaymentsReport(),
    ]);
  }

  // ✅ Fetch Sales Report
  Future<void> fetchSalesReport() async {
    try {
      isLoadingSales.value = true;

      final Map<String, dynamic> response = await _apiProvider.getSalesReport(
        dateFrom: selectedDateFrom.value,
        dateTo: selectedDateTo.value,
        paymentMethod: selectedPaymentMethod.value,
      );

      print('📥 Raw Sales Response: $response');

      if (response['success'] == true) {
        salesData.value = GetSalesReportModel.fromJson(response);

        final summary = salesData.value!.getSummary();
        print('✅ Sales report loaded:');
        print('   Total Sales: RM ${summary.totalSales}');
        print('   Total Orders: ${summary.totalOrders}');
        print('   Avg Order: RM ${summary.averageOrderValue}');
        print('   Items Sold: ${summary.totalItemsSold}');
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to fetch sales report',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching sales report: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to fetch sales report: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingSales.value = false;
    }
  }

  // ✅ Fetch Barbers Performance Report
  Future<void> fetchBarbersReport() async {
    try {
      isLoadingBarbers.value = true;

      final Map<String, dynamic> response = await _apiProvider.getBarbersReport(
        dateFrom: selectedDateFrom.value,
        dateTo: selectedDateTo.value,
      );

      if (response['success'] == true) {
        barbersData.value = GetBarberReportModel.fromJson(response);

        print('✅ Barbers report loaded: ${barbersData.value?.data?.length ?? 0} barbers');

        if (barbersData.value?.data != null) {
          for (var barber in barbersData.value!.data!) {
            print('   - ${barber.name}: RM ${barber.totalRevenue} (${barber.totalServices} services)');
          }
        }
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to fetch barbers report',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error fetching barbers report: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch barbers report: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingBarbers.value = false;
    }
  }

  // ✅ UPDATED: Fetch Payments Report with typed model
  Future<void> fetchPaymentsReport() async {
    try {
      isLoadingPayments.value = true;

      final Map<String, dynamic> response = await _apiProvider.getPaymentsReport(
        dateFrom: selectedDateFrom.value,
        dateTo: selectedDateTo.value,
        paymentMethod: selectedPaymentMethod.value,
        paymentStatus: selectedPaymentStatus.value,
      );

      print('📥 Raw Payments Response: $response');

      if (response['success'] == true) {
        paymentsData.value = GetPaymentReportModel.fromJson(response);

        final breakdown = paymentsData.value!.getPaymentMethodBreakdown();
        print('✅ Payments report loaded:');
        print('   Total Payments: ${paymentsData.value?.data?.length ?? 0}');
        print('   Payment Methods: ${breakdown.length}');
        for (var method in breakdown) {
          print('   - ${method.paymentMethod}: RM ${method.totalAmount} (${method.count} transactions)');
        }
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to fetch payments report',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching payments report: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to fetch payments report: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPayments.value = false;
    }
  }

  // Date picker methods
  Future<void> selectDateFrom(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateFrom.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDateFrom.value = picked;
      fetchAllReports();
    }
  }

  Future<void> selectDateTo(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTo.value ?? DateTime.now(),
      firstDate: selectedDateFrom.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDateTo.value = picked;
      fetchAllReports();
    }
  }

  // Set payment method filter
  void setPaymentMethod(String? method) {
    selectedPaymentMethod.value = method;
    fetchSalesReport();
    fetchPaymentsReport();
  }

  // Set payment status filter
  void setPaymentStatus(String? status) {
    selectedPaymentStatus.value = status;
    fetchPaymentsReport();
  }

  // Clear all filters
  void clearFilters() {
    final now = DateTime.now();
    selectedDateFrom.value = DateTime(now.year, now.month, 1);
    selectedDateTo.value = DateTime(now.year, now.month + 1, 0);
    selectedPaymentMethod.value = null;
    selectedPaymentStatus.value = null;
    fetchAllReports();
  }

  // Set quick date ranges
  void setQuickDateRange(String range) {
    final now = DateTime.now();

    switch (range) {
      case 'today':
        selectedDateFrom.value = DateTime(now.year, now.month, now.day);
        selectedDateTo.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        selectedDateFrom.value = DateTime(yesterday.year, yesterday.month, yesterday.day);
        selectedDateTo.value = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case 'this_week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        selectedDateFrom.value = DateTime(weekStart.year, weekStart.month, weekStart.day);
        selectedDateTo.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this_month':
        selectedDateFrom.value = DateTime(now.year, now.month, 1);
        selectedDateTo.value = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        selectedDateFrom.value = lastMonth;
        selectedDateTo.value = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case 'this_year':
        selectedDateFrom.value = DateTime(now.year, 1, 1);
        selectedDateTo.value = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }

    fetchAllReports();
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format date for API
  String formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Get date range text
  String get dateRangeText {
    if (selectedDateFrom.value == null || selectedDateTo.value == null) {
      return 'Select Date Range';
    }
    return '${formatDate(selectedDateFrom.value)} - ${formatDate(selectedDateTo.value)}';
  }
}