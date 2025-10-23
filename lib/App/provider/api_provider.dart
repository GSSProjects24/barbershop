// lib/App/data/provider/api_provider.dart
import 'package:babershop_project/App/provider/sharedprefference.dart';
import 'package:dio/dio.dart';
import 'package:babershop_project/App/provider/canstant.dart';

class ApiProvider {
  final Dio _dio;

  ApiProvider._internal()
      : _dio = Dio(
    BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 10000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  ) {
    // Add interceptor to automatically add token to requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SharedPrefService.instance.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  static final ApiProvider _instance = ApiProvider._internal();
  static ApiProvider get instance => _instance;
  Dio get client => _dio;

  // ✅ LOGIN API
  // ✅ LOGIN API - UPDATED
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // ✅ If login successful, save token and user data
        if (data['success'] == true && data['data'] != null) {
          final loginData = data['data'];
          final user = loginData['user'];

          // ✅ Extract branch information
          final branch = user['branch'];
          final branchName = branch != null ? branch['name'] : null;
          final branchId = branch != null ? branch['id'] : null;

          // Save to SharedPreferences
          await SharedPrefService.instance.saveLoginData(
            token: loginData['token'],
            userId: user['id'],
            username: user['username'],
            fullName: user['full_name'],
            email: user['email'],
            isSuperAdmin: user['is_super_admin'],
            branchName: branchName, // ✅ NEW
            branchId: branchId, // ✅ NEW
          );

          print('✅ Branch saved: $branchName (ID: $branchId)');
        }

        final storedData = SharedPrefService.instance.getAllStoredData();
        print('Stored Data Map: $storedData');

        return data;
      } else if (response.data != null && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ✅ GET CATEGORIES
  Future<Map<String, dynamic>> getCategories() async {
    try {
      print('📡 Fetching categories...');

      final response = await _dio.get('/categories');

      print('📥 Categories Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Categories fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch categories',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException fetching categories: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error fetching categories: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ✅ GET ALL ITEMS
  Future<Map<String, dynamic>> getAllItems() async {
    try {
      print('📡 Fetching all items...');

      final response = await _dio.get('/items/all');

      print('📥 Items Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Items fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch items',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException fetching items: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error fetching items: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ✅ GET ALL CUSTOMERS
  Future<Map<String, dynamic>> getCustomers() async {
    try {
      print('📡 Fetching customers...');

      final response = await _dio.get('/customers');

      print('📥 Customers Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Customers fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch customers',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException fetching customers: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error fetching customers: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ✅ CREATE NEW CUSTOMER
  Future<Map<String, dynamic>> createCustomer({
    required String phone,
    required String name,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    try {
      print('📡 Creating new customer...');

      final response = await _dio.post(
        '/customers',
        data: {
          'phone': phone,
          'name': name,
          if (email != null) 'email': email,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
          if (gender != null) 'gender': gender,
          if (address != null) 'address': address,
        },
      );

      print('📥 Create Customer Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          print('✅ Customer created successfully');
          return response.data as Map<String, dynamic>;
        }
      }

      return {
        'success': false,
        'message': 'Failed to create customer',
      };
    } on DioException catch (e) {
      print('❌ DioException creating customer: ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to create customer',
        };
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error creating customer: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ✅ GET BARBERS
  Future<Map<String, dynamic>> getBarbers() async {
    try {
      print('📡 Fetching barbers...');

      final response = await _dio.get('/employees/barbers');

      print('📥 Barbers Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Barbers fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch barbers',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException fetching barbers: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error fetching barbers: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }
  Future<Map<String, dynamic>> createSale({
    required int customerId,
    required int barberId,
    required int branchId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discountAmount,
    required int pointsRedeemed,
    required double pointsRedeemedValue,
    required double totalAmount,
    required String paymentMethod,
    required double paidAmount,
    List<Map<String, dynamic>>? splitPayments,
  }) async {
    try {
      print('📡 Creating sale...');

      final Map<String, dynamic> requestData = {
        'customer_id': customerId,
        'barber_id': barberId,
        'branch_id': branchId,
        'items': items,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'points_redeemed': pointsRedeemed,
        'points_redeemed_value': pointsRedeemedValue,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'paid_amount': paidAmount,
      };

      // Add split payments if provided
      if (splitPayments != null && splitPayments.isNotEmpty) {
        requestData['split_payments'] = splitPayments;
      }

      print('📤 Sale Request Data: $requestData');

      final response = await _dio.post(
        '/pos/sale',
        data: requestData,
      );

      print('📥 Sale Response Status Code: ${response.statusCode}');
      print('📥 Sale Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          print('✅ Sale created successfully');
          return response.data as Map<String, dynamic>;
        }
      }

      return {
        'success': false,
        'message': 'Failed to create sale',
      };
    } on DioException catch (e) {
      print('❌ DioException creating sale: ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to create sale',
          'error': e.response?.data,
        };
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error creating sale: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }
  // ✅ LOGOUT API
  Future<bool> logout() async {
    await SharedPrefService.instance.clearAll();
    return true;
  }
}