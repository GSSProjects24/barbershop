import 'package:babershop_project/App/Controller/Login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Detect device type
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              // ✅ Max width for tablet - centered content
              constraints: BoxConstraints(
                maxWidth: isLargeTablet ? 800 : (isTablet ? 600 : double.infinity),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 48 : 24,
                vertical: isTablet ? 32 : 16,
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ Top image with adaptive height
                    Container(
                      height: isTablet
                          ? screenHeight * 0.25
                          : screenHeight * 0.30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'images/seticon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox();
                                  },
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              'images/login1.png',
                              height: isTablet
                                  ? screenHeight * 0.35
                                  : screenHeight * 0.56,
                              width: isTablet
                                  ? screenHeight * 0.35
                                  : screenHeight * 0.56,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.content_cut,
                                  size: 100,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 48 : 32),

                    // Welcome Text
                    Text(
                      'Welcome back 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 36 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3F3D56),
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      'Please enter your login information below\nto access your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: isTablet ? 40 : 32),

                    // Login label
                    Text(
                      'Login to Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3F3D56),
                      ),
                    ),

                    SizedBox(height: isTablet ? 32 : 24),

                    // ✅ Username Field
                    TextFormField(
                      controller: controller.usernameController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      decoration: InputDecoration(
                        hintText: 'Username or Email',
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: const Color(0xFFFFA726),
                          size: isTablet ? 24 : 20,
                        ),
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
                          borderSide: const BorderSide(
                            color: Color(0xFFFFA726),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 20 : 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username or email';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: isTablet ? 20 : 16),

                    // ✅ Password Field
                    Obx(() => TextFormField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: const Color(0xFFFFA726),
                          size: isTablet ? 24 : 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: isTablet ? 24 : 20,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
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
                          borderSide: const BorderSide(
                            color: Color(0xFFFFA726),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 20 : 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),

                    SizedBox(height: isTablet ? 16 : 12),

                    // Remember Me
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Obx(() => Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: controller.toggleRememberMe,
                          activeColor: const Color(0xFFFFA726),
                        )),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: const Color(0xFF3F3D56),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 32 : 24),

                    // ✅ Login Button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: isTablet ? 60 : 54,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF363062),
                          disabledBackgroundColor:
                          const Color(0xFF363062).withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                          height: isTablet ? 28 : 24,
                          width: isTablet ? 28 : 24,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          'Login',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),

                    SizedBox(height: isTablet ? 32 : 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}