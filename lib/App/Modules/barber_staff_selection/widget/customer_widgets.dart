import 'dart:async';
import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetbarberModel.dart';
import 'package:babershop_project/App/config/app_colors.dart';
import 'package:babershop_project/App/provider/api_provider.dart';
import 'package:babershop_project/App/provider/sharedprefference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerWidgets {
  // ✅ Barber Selection Widget
  static Widget buildBarberSelection(CartController controller, {bool isMobile = false}) {
    final branchName = SharedPrefService.instance.getBranchName() ?? 'Unknown Branch';

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildBranchHeader(branchName, controller),
          const SizedBox(height: 10),
          const Text(
            'Customer Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildBarberDropdown(controller)),
              const SizedBox(width: 12),
              Expanded(child: _buildCustomerSelector(controller)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildBranchHeader(String branchName, CartController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGold, AppColors.lightGold],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              branchName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _handleLogout(controller),
            icon: const Icon(Icons.logout, color: Colors.black, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  static Widget _buildBarberDropdown(CartController controller) {
    return Obx(() {
      if (controller.isLoadingBarbers.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      return DropdownButtonFormField<Datum>(
        value: controller.selectedBarber.value,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          labelText: 'Select Barber',
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.person_outline, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
        isExpanded: true,
        hint: Text(
          controller.barbers.isEmpty ? 'No barbers' : 'Select barber',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        items: controller.barbers
            .map((barber) => DropdownMenuItem(
          value: barber,
          child: Text(
            barber.fullName ?? 'Unknown',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ))
            .toList(),
        onChanged: (Datum? value) => controller.selectBarber(value),
      );
    });
  }

  static Widget _buildCustomerSelector(CartController controller) {
    return Obx(() {
      if (controller.isLoadingCustomers.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      return InkWell(
        onTap: () => showCustomerSearchDialog(controller),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: controller.selectedCustomer.value != null
                    ? Text(
                  controller.selectedCustomer.value!.phone,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                )
                    : Text(
                  controller.customers.isEmpty ? 'No customers' : 'Select customer',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      );
    });
  }

  // ✅ Customer Search Dialog
  static void showCustomerSearchDialog(CartController controller) {
    final searchController = TextEditingController();
    final filteredCustomers = <Customer>[].obs;
    final showAddForm = false.obs;
    final dialogPhoneController = TextEditingController();
    final dialogNameController = TextEditingController();
    final isSearching = false.obs;
    final searchedCustomer = Rx<Customer?>(null);

    filteredCustomers.value = controller.customers;
    Timer? debounceTimer;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogHeader(debounceTimer),
              const SizedBox(height: 16),
              _buildSearchField(
                searchController,
                controller,
                filteredCustomers,
                searchedCustomer,
                showAddForm,
                isSearching,
                debounceTimer,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() => _buildDialogContent(
                  showAddForm,
                  isSearching,
                  filteredCustomers,
                  searchedCustomer,
                  controller,
                  searchController,
                  dialogPhoneController,
                  dialogNameController,
                  debounceTimer,
                )),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => debounceTimer?.cancel());
  }

  static Widget _buildDialogHeader(Timer? debounceTimer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Select Customer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            debounceTimer?.cancel();
            Get.back();
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  static Widget _buildSearchField(
      TextEditingController searchController,
      CartController controller,
      RxList<Customer> filteredCustomers,
      Rx<Customer?> searchedCustomer,
      RxBool showAddForm,
      RxBool isSearching,
      Timer? debounceTimer,
      ) {
    return TextField(
      controller: searchController,
      autofocus: true,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Search by phone number (e.g., 0165787640)...',
        prefixIcon: Obx(() => isSearching.value
            ? const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        )
            : const Icon(Icons.search, size: 20)),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, size: 20),
          onPressed: () {
            searchController.clear();
            filteredCustomers.value = controller.customers;
            searchedCustomer.value = null;
            showAddForm.value = false;
            debounceTimer?.cancel();
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: (value) => _onSearchChanged(
        value,
        controller,
        filteredCustomers,
        searchedCustomer,
        showAddForm,
        isSearching,
        debounceTimer,
      ),
    );
  }

  static void _onSearchChanged(
      String value,
      CartController controller,
      RxList<Customer> filteredCustomers,
      Rx<Customer?> searchedCustomer,
      RxBool showAddForm,
      RxBool isSearching,
      Timer? debounceTimer,
      ) {
    debounceTimer?.cancel();

    if (value.isEmpty) {
      filteredCustomers.value = controller.customers;
      searchedCustomer.value = null;
      showAddForm.value = false;
      isSearching.value = false;
      return;
    }

    if (value.length >= 3) {
      isSearching.value = true;
      debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        final result = await controller.searchCustomerByPhone(value);
        isSearching.value = false;

        if (result != null) {
          searchedCustomer.value = result;
          filteredCustomers.value = [result];
          showAddForm.value = false;
        } else {
          filteredCustomers.value = controller.customers
              .where((customer) =>
          customer.phone.toLowerCase().contains(value.toLowerCase()) ||
              customer.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
          searchedCustomer.value = null;
        }
      });
    } else {
      isSearching.value = false;
      filteredCustomers.value = controller.customers
          .where((customer) =>
      customer.phone.toLowerCase().contains(value.toLowerCase()) ||
          customer.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }
  }

  static Widget _buildDialogContent(
      RxBool showAddForm,
      RxBool isSearching,
      RxList<Customer> filteredCustomers,
      Rx<Customer?> searchedCustomer,
      CartController controller,
      TextEditingController searchController,
      TextEditingController dialogPhoneController,
      TextEditingController dialogNameController,
      Timer? debounceTimer,
      ) {
    if (showAddForm.value) {
      return _buildAddCustomerForm(
        dialogPhoneController,
        dialogNameController,
        controller,
        showAddForm,
        debounceTimer,
      );
    }

    if (isSearching.value) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    if (filteredCustomers.isEmpty) {
      return _buildEmptyState(searchController, dialogPhoneController, showAddForm);
    }

    return _buildCustomerList(filteredCustomers, searchedCustomer, controller, debounceTimer);
  }

  static Widget _buildAddCustomerForm(
      TextEditingController dialogPhoneController,
      TextEditingController dialogNameController,
      CartController controller,
      RxBool showAddForm,
      Timer? debounceTimer,
      ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Customer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: dialogPhoneController,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_android, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dialogNameController,
            decoration: InputDecoration(
              hintText: 'Enter customer name',
              labelText: 'Customer Name',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    dialogPhoneController.clear();
                    dialogNameController.clear();
                    showAddForm.value = false;
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleAddCustomer(
                    dialogPhoneController,
                    dialogNameController,
                    controller,
                    debounceTimer,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Customer',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _handleAddCustomer(
      TextEditingController dialogPhoneController,
      TextEditingController dialogNameController,
      CartController controller,
      Timer? debounceTimer,
      ) async {
    if (dialogPhoneController.text.isEmpty || dialogNameController.text.isEmpty) {
      Get.snackbar(
        'Required',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final phoneToSearch = dialogPhoneController.text;
    controller.addFieldController.text = dialogPhoneController.text;
    controller.nameController.text = dialogNameController.text;

    await controller.createCustomer();
    await Future.delayed(const Duration(milliseconds: 500));

    final newCustomer = await controller.searchCustomerByPhone(phoneToSearch);

    if (newCustomer != null) {
      controller.selectCustomer(newCustomer);
      Get.snackbar(
        'Success',
        'Customer added and selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      debounceTimer?.cancel();
      Get.back();
    }

    dialogPhoneController.clear();
    dialogNameController.clear();
  }

  static Widget _buildEmptyState(
      TextEditingController searchController,
      TextEditingController dialogPhoneController,
      RxBool showAddForm,
      ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            searchController.text.isNotEmpty ? 'Customer not found in system' : 'Start typing to search',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                dialogPhoneController.text = searchController.text;
              }
              showAddForm.value = true;
            },
            icon: const Icon(Icons.person_add, size: 20),
            label: const Text('Add New Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCustomerList(
      RxList<Customer> filteredCustomers,
      Rx<Customer?> searchedCustomer,
      CartController controller,
      Timer? debounceTimer,
      ) {
    return ListView.separated(
      itemCount: filteredCustomers.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        final isSelected = controller.selectedCustomer.value?.id == customer.id;
        final isFromAPI = searchedCustomer.value?.id == customer.id;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGold.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: isSelected ? AppColors.primaryGold : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              if (isFromAPI)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(Icons.cloud_done, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  customer.phone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryGold : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                    const SizedBox(width: 2),
                    Text(
                      '${customer.totalPoints}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Text(
            customer.name,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: AppColors.primaryGold, size: 24)
              : null,
          selected: isSelected,
          selectedTileColor: AppColors.primaryGold.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () {
            controller.selectCustomer(customer);
            debounceTimer?.cancel();
            Get.back();
          },
        );
      },
    );
  }

  static Future<void> _handleLogout(CartController controller) async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final success = await _logout();
      Get.back();

      if (success) {
        Get.offAllNamed('/login');
        Get.snackbar(
          'Success',
          'Logged out successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to logout. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  static Future<bool> _logout() async {
    await SharedPrefService.instance.clearAll();
    return true;
  }
}