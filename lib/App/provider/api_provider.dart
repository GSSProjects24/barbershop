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
  // ✅ LOGIN API - CORRECTED FOR ACTUAL RESPONSE STRUCTURE
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/branch/login',
        data: {
          'branch_username': username,
          'branch_password': password,
        },
      );

      print('📥 Login Response Status: ${response.statusCode}');
      print('📥 Login Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // ✅ Check if login was successful
        if (data['success'] == true) {
          // ✅ Extract data from FLAT response structure (not nested)
          final token = data['token'] as String?;
          final branchData = data['branch'] as Map<String, dynamic>?;

          if (token != null && branchData != null) {
            // ✅ Extract branch information
            final branchId = branchData['id'] as int?;
            final branchName = branchData['name'] as String?;
            final branchCode = branchData['branch_code'] as String?;
            final contactPerson = branchData['contact_person'] as String?;
            final phone = branchData['phone'] as String?;
            final email = branchData['email'] as String?;

            // Extract organization info
            final organization = branchData['organization'] as Map<String, dynamic>?;
            final orgName = organization?['name'] as String?;

            print('🔄 Attempting to save login data...');

            // ✅ Save to SharedPreferences
            final saveResult = await SharedPrefService.instance.saveLoginData(
              token: token,
              userId: branchId ?? 0,
              username: username,
              fullName: branchName ?? 'Unknown Branch',
              email: email,
              isSuperAdmin: false,
              branchName: branchName,
              branchId: branchId,
            );

            if (saveResult) {
              print('✅ Login data saved successfully');
            } else {
              print('❌ Failed to save login data');
            }

            print('✅ Token: ${token.substring(0, 30)}...');
            print('✅ Branch: $branchName (ID: $branchId)');
            print('✅ Branch Code: $branchCode');
            print('✅ Organization: $orgName');
            print('✅ Contact: $contactPerson');

            // Verify storage immediately after saving
            final storedData = SharedPrefService.instance.getAllStoredData();
            print('📋 Stored Data Map: $storedData');
          } else {
            print('❌ Token or branch data is missing from response');
          }

          return data;
        } else {
          print('❌ Login failed: ${data['message']}');
          return data;
        }
      } else if (response.data != null && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
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
  // ✅ GET ALL ITEMS - UPDATED to pass branch_id
  Future<Map<String, dynamic>> getAllItems() async {
    try {
      print('📡 Fetching all items...');

      // ✅ Get branch_id from SharedPreferences
      final int? branchId = SharedPrefService.instance.getBranchId();

      if (branchId == null) {
        print('⚠️ Warning: Branch ID not found');
        return {
          'success': false,
          'message': 'Branch ID not found. Please login again.',
        };
      }

      print('🏢 Using Branch ID: $branchId');

      // ✅ Pass branch_id as query parameter
      final response = await _dio.get(
        '/items/all',
        queryParameters: {
          'branch_id': branchId,
        },
      );

      print('📥 Items Response Status Code: ${response.statusCode}');
      print('🔗 Request URL: ${response.requestOptions.uri}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Items fetched successfully for branch $branchId');
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
// ✅ SEARCH CUSTOMER BY PHONE
  Future<Map<String, dynamic>> searchCustomer(String phone) async {
    try {
      print('📡 Searching customer by phone: $phone');

      final response = await _dio.get(
        '/customers/search',
        queryParameters: {'phone': phone},
      );

      print('📥 Search Response Status Code: ${response.statusCode}');
      print('📥 Search Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Search completed');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'found': false,
          'message': 'Search failed',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException searching customer: ${e.message}');
      return {
        'success': false,
        'found': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error searching customer: $e');
      return {
        'success': false,
        'found': false,
        'message': 'Unexpected error: $e',
      };
    }
  }
  // ✅ GET BARBERS
  // ✅ GET BARBERS - UPDATED to pass branch_id
  Future<Map<String, dynamic>> getBarbers() async {
    try {
      print('📡 Fetching barbers...');

      final int? branchId = SharedPrefService.instance.getBranchId();

      if (branchId == null) {
        print('⚠️ Warning: Branch ID not found');
        return {
          'success': false,
          'message': 'Branch ID not found. Please login again.',
        };
      }

      final response = await _dio.get(
        '/employees/barbers',
        queryParameters: {
          'branch_id': branchId,
        },
      );

      print('📥 Barbers Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Barbers fetched successfully for branch $branchId');
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
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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
        print('💳 Split Payments Added: ${splitPayments.length} methods');
      }

      print('📤 Sale Request Data:');
      print('   Customer ID: $customerId');
      print('   Barber ID: $barberId');
      print('   Branch ID: $branchId');
      print('   Items Count: ${items.length}');
      print('   Payment Method: $paymentMethod');
      print('   Total Amount: RM $totalAmount');
      if (splitPayments != null && splitPayments.isNotEmpty) {
        print('   Split Payments:');
        for (var payment in splitPayments) {
          print('     - ${payment['payment_method']}: RM ${payment['amount']}');
        }
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dio.post(
        '/pos/sale',
        data: requestData,
      );

      print('📥 Sale Response Status Code: ${response.statusCode}');
      print('📥 Sale Response Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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
      print('❌ Request: ${e.requestOptions.data}');

      if (e.response != null) {
        print('❌ Status Code: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');

        // Handle validation errors
        if (e.response?.statusCode == 422) {
          final errors = e.response?.data['errors'];
          print('❌ Validation Errors: $errors');

          return {
            'success': false,
            'message': e.response?.data['message'] ?? 'Validation failed',
            'errors': errors,
            'status_code': 422,
          };
        }

        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to create sale',
          'error': e.response?.data,
          'status_code': e.response?.statusCode,
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
  // ═══════════════════════════════════════════════════════════
  // REPORTS API METHODS
  // ═══════════════════════════════════════════════════════════

  // ✅ GET SALES REPORT
  Future<Map<String, dynamic>> getSalesReport({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? paymentMethod,
  }) async {
    try {
      print('📡 Fetching sales report...');

      final int? branchId = SharedPrefService.instance.getBranchId();

      if (branchId == null) {
        print('⚠️ Warning: Branch ID not found');
        return {
          'success': false,
          'message': 'Branch ID not found. Please login again.',
        };
      }

      final Map<String, dynamic> queryParams = {
        'branch_id': branchId,
      };

      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParams['payment_method'] = paymentMethod;
      }

      final response = await _dio.get(
        '/reports/sales',
        queryParameters: queryParams,
      );

      print('📥 Sales Report Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Sales report fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch sales report',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException fetching sales report: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error fetching sales report: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ✅ GET BARBERS PERFORMANCE REPORT
  Future<Map<String, dynamic>> getBarbersReport({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      print('📡 Fetching barbers performance report...');

      final int? branchId = SharedPrefService.instance.getBranchId();

      if (branchId == null) {
        print('⚠️ Warning: Branch ID not found');
        return {
          'success': false,
          'message': 'Branch ID not found. Please login again.',
        };
      }

      final Map<String, dynamic> queryParams = {
        'branch_id': branchId,
      };

      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
      }

      final response = await _dio.get(
        '/reports/barbers/performance',
        queryParameters: queryParams,
      );

      print('📥 Barbers Report Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Barbers report fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch barbers report',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException fetching barbers report: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error fetching barbers report: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // ✅ GET PAYMENTS REPORT
  Future<Map<String, dynamic>> getPaymentsReport({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? paymentMethod,
    String? paymentStatus,
  }) async {
    try {
      print('📡 Fetching payments report...');

      final int? branchId = SharedPrefService.instance.getBranchId();

      if (branchId == null) {
        print('⚠️ Warning: Branch ID not found');
        return {
          'success': false,
          'message': 'Branch ID not found. Please login again.',
        };
      }

      final Map<String, dynamic> queryParams = {
        'branch_id': branchId,
      };

      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParams['payment_method'] = paymentMethod;
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['payment_status'] = paymentStatus;
      }

      final response = await _dio.get(
        '/reports/payments',
        queryParameters: queryParams,
      );

      print('📥 Payments Report Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Payments report fetched successfully');
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch payments report',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException fetching payments report: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Unexpected error fetching payments report: $e');
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
