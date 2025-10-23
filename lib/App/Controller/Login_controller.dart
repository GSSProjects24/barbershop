import 'package:babershop_project/App/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // ✅ API Provider already handles saving all data via SharedPrefService
      final response = await ApiProvider.instance.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (response['success'] == true) {
        // ✅ No need to save data here - ApiProvider already did it!

        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // ✅ Navigate to barber selection
        Get.offAllNamed('/barberSelection');
      } else {
        // ✅ Show error message
        Get.snackbar(
          'Login Failed',
          response['message'] ?? 'Invalid credentials',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // ✅ Handle unexpected errors
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('❌ Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}