import 'package:babershop_project/App/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final response = await ApiProvider.instance.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response['success'] == true) {
        // Save login state, ID and token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', response['data']['id'].toString());
        await prefs.setString('token', response['data']['token']);

        Get.snackbar('Success', 'Login successful!',
            backgroundColor: Colors.green, colorText: Colors.white);

        Get.offAllNamed('/barberSelection');
      } else {
        Get.snackbar('Failed', response['message'] ?? 'Invalid credentials',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle remember me
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }
}
