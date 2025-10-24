import 'package:babershop_project/App/provider/api_provider.dart';
import 'package:babershop_project/App/provider/sharedprefference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  // ✅ Changed from emailController to usernameController
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final formKey = GlobalKey<FormState>();

  // In your LoginController after successful login:

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final response = await ApiProvider.instance.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (response['success'] == true) {
        // ✅ ADD: Verify data was saved
        await Future.delayed(const Duration(milliseconds: 500)); // Wait for save

        final savedToken = SharedPrefService.instance.getToken();
        final savedUserId = SharedPrefService.instance.getUserId();

        print('🔍 Verifying saved data after login:');
        print('📱 Token saved: ${savedToken != null}');
        print('👤 User ID saved: $savedUserId');
        print('📱 Token length: ${savedToken?.length ?? 0}');

        if (savedToken == null || savedToken.isEmpty) {
          print('❌ WARNING: Token was not saved properly!');
        }

        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        Get.offAllNamed('/barberSelection');
      } else {
        Get.snackbar(
          'Failed',
          response['message'] ?? 'Invalid credentials',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
      Get.snackbar(
        'Error',
        'Failed to login: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
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