// import 'dart:async';
//
// import 'package:babershop_project/App/Modules/barber_staff_selection/Remedee_point.dart';
// import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
// import 'package:babershop_project/App/Modules/getcategoriModel/GetCateoriesModel.dart';
// import 'package:babershop_project/App/Modules/getcategoriModel/GetItemModel.dart';
// import 'package:babershop_project/App/Modules/getcategoriModel/GetbarberModel.dart';
// import 'package:babershop_project/App/config/app_colors.dart';
// import 'package:babershop_project/App/provider/api_provider.dart';
// import 'package:babershop_project/App/provider/sharedprefference.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class BarberSelectionPage extends StatelessWidget {
//   const BarberSelectionPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(CartController());
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           // Determine layout based on screen width
//           if (constraints.maxWidth > 1200) {
//             // Desktop/Large Tablet - Side by side layout
//             return _buildDesktopLayout(controller, constraints);
//           } else if (constraints.maxWidth > 600) {
//             // Tablet - Side by side with adjusted ratios
//             return _buildTabletLayout(controller, constraints);
//           } else {
//             // Mobile - Stacked layout with bottom sheet cart
//             return _buildMobileLayout(controller, constraints);
//           }
//         },
//       ),
//       // Floating cart button for mobile
//       floatingActionButton: LayoutBuilder(
//         builder: (context, constraints) {
//           if (MediaQuery.of(context).size.width <= 600) {
//             return Obx(() => controller.cartItems.isNotEmpty
//                 ? FloatingActionButton.extended(
//               onPressed: () => _showCartBottomSheet(context, controller),
//               backgroundColor: Colors.orangeAccent,
//               icon: Badge(
//                 label: Text('${controller.cartItems.length}'),
//                 child: const Icon(Icons.shopping_cart),
//               ),
//               label: Text(
//                 'RM ${controller.grandTotal}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )
//                 : const SizedBox.shrink());
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//
//
// // ✅ DESKTOP LAYOUT - Keep default height (400)
//   // Desktop Layout
//   Widget _buildDesktopLayout(CartController controller, BoxConstraints constraints) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 7,
//             child: _buildProductsSection(controller, crossAxisCount: 4),
//           ),
//           const SizedBox(width: 24),
//           SizedBox(
//             width: 450,
//             child: _buildCartSection(controller, maxHeight: 500), // ✅ Increased
//           ),
//         ],
//       ),
//     );
//   }
//
// // Tablet Layout
//   Widget _buildTabletLayout(CartController controller, BoxConstraints constraints) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 6,
//             child: _buildProductsSection(controller, crossAxisCount: 3),
//           ),
//           const SizedBox(width: 16),
//           SizedBox(
//             width: 340,
//             child: _buildCartSection(controller, maxHeight: 600), // ✅ Increased for tablet
//           ),
//         ],
//       ),
//     );
//   }
//
// // ✅ TABLET LAYOUT - Increase height to 600
//
//   // Mobile Layout (<600px)
//   Widget _buildMobileLayout(CartController controller, BoxConstraints constraints) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildBarberSelection(controller, isMobile: true),
//             const SizedBox(height: 16),
//             _buildProductsSection(controller, crossAxisCount: 2, isMobile: true),
//             const SizedBox(height: 80), // Space for FAB
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Products Section
//   Widget _buildProductsSection(CartController controller, {required int crossAxisCount, bool isMobile = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Category Filters
//         _buildProductSearchBar(controller),
//         const SizedBox(height: 12),
//
//         // Category Filters
//         _buildCategoryFilters(),
//         const SizedBox(height: 12),
//         // Products Grid
//         if (!isMobile)
//           Expanded(child: _buildProductsGrid(controller, crossAxisCount))
//         else
//           _buildProductsGrid(controller, crossAxisCount),
//       ],
//     );
//   }
//   Widget _buildCategoryFilters() {
//     final controller = Get.find<CartController>();
//
//     return Obx(() {
//       // Show loading shimmer
//       if (controller.isLoadingCategories.value) {
//         return _buildCategoryFiltersShimmer();
//       }
//
//       // Show empty state
//       if (controller.categories.isEmpty) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: const Center(
//             child: Text(
//               'No categories available',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//         );
//       }
//
//       // Show categories
//       return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             // "ALL" filter chip
//             Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: FilterChip(
//                 label: Text(
//                   'ALL',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                     color: controller.selectedCategoryId.value == 0
//                         ? Colors.white
//                         : AppColors.darkGold,
//                   ),
//                 ),
//                 selected: controller.selectedCategoryId.value == 0,
//                 onSelected: (_) => controller.clearCategoryFilter(),
//                 selectedColor: AppColors.primaryGold,
//                 backgroundColor: Colors.white,
//                 elevation: controller.selectedCategoryId.value == 0 ? 2 : 0,
//                 pressElevation: 2,
//                 checkmarkColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(
//                     color: controller.selectedCategoryId.value == 0
//                         ?AppColors.primaryGold
//                         : Colors.grey.shade300,
//                     width: 1.5,
//                   ),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//             ),
//
//             // Category filter chips from API
//             ...controller.categories.map((category) {
//               final isSelected = controller.selectedCategoryId.value == category.id;
//
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: FilterChip(
//                   label: Text(
//                     (category.name ?? 'Unknown').toUpperCase(),
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 13,
//                       color: isSelected ? Colors.white : AppColors.darkGold,
//                     ),
//                   ),
//                   selected: isSelected,
//                   onSelected: (_) => controller.selectCategory(
//                       category.id ?? 0,
//                       category.name ?? 'Unknown'
//                   ),
//                   selectedColor: AppColors.primaryGold,
//                   backgroundColor: Colors.white,
//                   elevation: isSelected ? 2 : 0,
//                   pressElevation: 2,
//                   checkmarkColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: BorderSide(
//                       color: isSelected
//                           ? AppColors.primaryGold
//                           : Colors.grey.shade300,
//                       width: 1.5,
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       );
//     });
//   }
// // ✅ NEW: Product Search Bar Widget
//   Widget _buildProductSearchBar(CartController controller) {
//     return Obx(() => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: TextField(
//         controller: controller.searchController,
//         decoration: InputDecoration(
//           hintText: 'Search products by name or SKU...',
//           hintStyle: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade500,
//           ),
//           prefixIcon: Icon(
//             Icons.search,
//             size: 20,
//             color: Colors.grey.shade600,
//           ),
//           suffixIcon: controller.searchQuery.value.isNotEmpty
//               ? IconButton(
//             icon: Icon(
//               Icons.clear,
//               size: 20,
//               color: Colors.grey.shade600,
//             ),
//             onPressed: () => controller.clearSearch(),
//           )
//               : null,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//           isDense: true,
//         ),
//         style: const TextStyle(fontSize: 14),
//       ),
//     ));
//   }
// // Shimmer loading effect for categories
//   Widget _buildCategoryFiltersShimmer() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: List.generate(
//           5,
//               (index) => Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: Container(
//               width: 100,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductsGrid(CartController controller, int crossAxisCount) {
//     return Obx(() {
//       // Show loading
//       if (controller.isLoadingItems.value) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       }
//
//       // Show empty state
//       if (controller.products.isEmpty) {
//         // ✅ IMPROVED: Different messages based on filters
//         String emptyMessage = 'No items available';
//         IconData emptyIcon = Icons.inventory_2_outlined;
//
//         if (controller.searchQuery.value.isNotEmpty) {
//           emptyMessage = 'No products found for "${controller.searchQuery.value}"';
//           emptyIcon = Icons.search_off;
//         } else if (controller.selectedCategoryId.value != 0) {
//           emptyMessage = 'No products in ${controller.selectedCategoryName.value}';
//           emptyIcon = Icons.category_outlined;
//         }
//
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
//               const SizedBox(height: 16),
//               Text(
//                 emptyMessage,
//                 style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               if (controller.searchQuery.value.isNotEmpty ||
//                   controller.selectedCategoryId.value != 0) ...[
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     controller.clearSearch();
//                     controller.clearCategoryFilter();
//                   },
//                   icon: const Icon(Icons.refresh, size: 18),
//                   label: const Text('Clear Filters'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryGold,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       }
//
//       // Show products grid
//       return SingleChildScrollView(
//         child: GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             childAspectRatio: 0.80,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//           ),
//           itemCount: controller.products.length,
//           itemBuilder: (_, index) {
//             final product = controller.products[index];
//             return _buildProductCard(product, controller);
//           },
//         ),
//       );
//     });
//   }
//
//   Widget _buildProductCard(ItemModel product, CartController controller) {
//     return InkWell(
//       onTap: () => controller.addToCart(product),
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.accentAmber.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Product Image
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: Image.network(
//                     product.imageUrl,
//                     height: 80,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       height: 80,
//                       color: Colors.grey.shade200,
//                       child: Image.asset("images/logo.jpg", height: 200, width: double.infinity),
//                     ),
//                   ),
//                 ),
//                 // Type Badge
//                 Positioned(
//                   top: 8,
//                   left: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: product.type == 'service'
//                           ? Colors.blue.withOpacity(0.9)
//                           : Colors.purple.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       product.type.toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Points Badge
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.6),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 14),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${product.pointsEarned ?? 0}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             // Product Details
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ✅ NEW: Highlight search text
//                     Obx(() {
//                       final searchQuery = controller.searchQuery.value.toLowerCase();
//                       final productName = product.title;
//
//                       if (searchQuery.isEmpty || !productName.toLowerCase().contains(searchQuery)) {
//                         return Text(
//                           productName,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: Color(0xFF1A1F36),
//                             height: 1.3,
//                           ),
//                         );
//                       }
//
//                       // Highlight search text
//                       final startIndex = productName.toLowerCase().indexOf(searchQuery);
//                       final endIndex = startIndex + searchQuery.length;
//
//                       return RichText(
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         text: TextSpan(
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: Color(0xFF1A1F36),
//                             height: 1.3,
//                           ),
//                           children: [
//                             if (startIndex > 0)
//                               TextSpan(text: productName.substring(0, startIndex)),
//                             TextSpan(
//                               text: productName.substring(startIndex, endIndex),
//                               style: const TextStyle(
//                                 backgroundColor: Color(0xFFFFEB3B),
//                                 color: Color(0xFF1A1F36),
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             if (endIndex < productName.length)
//                               TextSpan(text: productName.substring(endIndex)),
//                           ],
//                         ),
//                       );
//                     }),
//                     const SizedBox(height: 4),
//                     Text(
//                       'SKU: ${product.sku}',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const Spacer(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'RM ${product.price}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                             color: Color(0xFF10B981),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.orangeAccent.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.add_shopping_cart,
//                             size: 18,
//                             color: Colors.orangeAccent,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Cart Section
//   Widget _buildCartSection(CartController controller, {double maxHeight = 400}) {
//     return Column(
//       children: [
//         // Barber Selection - Fixed at top
//         _buildBarberSelection(controller),
//         const SizedBox(height: 16),
//
//         // ✅ SCROLLABLE AREA - Cart Items + Points Redemption
//         Expanded(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               children: [
//                 _buildCartList(controller, maxHeight: double.infinity), // ✅ Remove height constraint
//                 const SizedBox(height: 10),
//                 PointsRedemptionWidget(controller: controller),
//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//
//         // ✅ FIXED PAYMENT SECTION AT BOTTOM
//         _buildPaymentSection(controller),
//       ],
//     );
//   }
//   Future<void> _handleLogout(CartController controller) async {
//     // Show confirmation dialog
//     final shouldLogout = await Get.dialog<bool>(
//       AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Get.back(result: true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryGold,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldLogout == true) {
//       // Show loading
//       Get.dialog(
//         const Center(
//           child: CircularProgressIndicator(),
//         ),
//         barrierDismissible: false,
//       );
//
//       // Call logout API
//       final success = await logout();
//
//       // Close loading dialog
//       Get.back();
//
//       if (success) {
//         // Navigate to login screen and clear navigation stack
//         Get.offAllNamed('/login'); // or your login route
//
//         // Optional: Show success message
//         Get.snackbar(
//           'Success',
//           'Logged out successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         // Show error message
//         Get.snackbar(
//           'Error',
//           'Failed to logout. Please try again.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     }
//   }
//
// // Your existing logout API
//   Future<bool> logout() async {
//     await SharedPrefService.instance.clearAll();
//     return true;
//   }
//   Widget _buildBarberSelection(CartController controller, {bool isMobile = false}) {
//     final branchName = SharedPrefService.instance.getBranchName() ?? 'Unknown Branch';
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ✅ Branch Name Header with Logout Button
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [AppColors.primaryGold, AppColors.lightGold],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.store,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     branchName,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 // ✅ NEW: Logout Button
//                 IconButton(
//                   onPressed: () => _handleLogout(controller),
//                   icon: const Icon(
//                     Icons.logout,
//                     color: Colors.black,
//                     size: 18,
//                   ),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   tooltip: 'Logout',
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Customer Details',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1A1F36),
//             ),
//           ),
//           const SizedBox(height: 10),
//           // Barber and Customer Phone Number in one row
//           Row(
//             children: [
//               // Barber Dropdown
//               Expanded(
//                 child: Obx(() {
//                   if (controller.isLoadingBarbers.value) {
//                     return Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: const Center(
//                         child: SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       ),
//                     );
//                   }
//
//                   return DropdownButtonFormField<Datum>(
//                     value: controller.selectedBarber.value,
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     decoration: InputDecoration(
//                       labelText: 'Select Barber',
//                       labelStyle: const TextStyle(fontSize: 13),
//                       prefixIcon: const Icon(Icons.person_outline, size: 20),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                             color: Colors.grey, width: 2),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey.shade50,
//                       contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       isDense: true,
//                     ),
//                     isExpanded: true,
//                     hint: Text(
//                       controller.barbers.isEmpty
//                           ? 'No barbers'
//                           : 'Select barber',
//                       style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                     ),
//                     items: controller.barbers
//                         .map((barber) => DropdownMenuItem(
//                       value: barber,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             barber.fullName ?? 'Unknown',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ))
//                         .toList(),
//                     onChanged: (Datum? value) {
//                       controller.selectBarber(value);
//                     },
//                   );
//                 }),
//               ),
//               const SizedBox(width: 12),
//               // Customer Phone Number with Search - MODIFIED TO SHOW ONLY PHONE
//               Expanded(
//                 child: Obx(() {
//                   if (controller.isLoadingCustomers.value) {
//                     return Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: const Center(
//                         child: SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       ),
//                     );
//                   }
//
//                   return InkWell(
//                     onTap: () => _showCustomerSearchDialog(controller),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: controller.selectedCustomer.value != null
//                                 ? Text(
//                               controller.selectedCustomer.value!.phone,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             )
//                                 : Text(
//                               controller.customers.isEmpty
//                                   ? 'No customers'
//                                   : 'Select customer',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ),
//                           Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
// // Customer Search Dialog with Add Customer Form when no results
//   void _showCustomerSearchDialog(CartController controller) {
//     final searchController = TextEditingController();
//     final filteredCustomers = <Customer>[].obs;
//     final showAddForm = false.obs;
//     final dialogPhoneController = TextEditingController();
//     final dialogNameController = TextEditingController();
//     final isSearching = false.obs;
//     final searchedCustomer = Rx<Customer?>(null);
//
//     // Initialize with all customers
//     filteredCustomers.value = controller.customers;
//
//     // ✅ Debounce timer for API search
//     Timer? debounceTimer;
//
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Container(
//           width: 500,
//           height: 600,
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Select Customer',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1A1F36),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       debounceTimer?.cancel();
//                       Get.back();
//                     },
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Search Field
//               TextField(
//                 controller: searchController,
//                 autofocus: true,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   hintText: 'Search by phone number (e.g., 0165787640)...',
//                   prefixIcon: Obx(() => isSearching.value
//                       ? const Padding(
//                     padding: EdgeInsets.all(12),
//                     child: SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   )
//                       : const Icon(Icons.search, size: 20)),
//                   suffixIcon: searchController.text.isNotEmpty
//                       ? IconButton(
//                     icon: const Icon(Icons.clear, size: 20),
//                     onPressed: () {
//                       searchController.clear();
//                       filteredCustomers.value = controller.customers;
//                       searchedCustomer.value = null;
//                       showAddForm.value = false;
//                       debounceTimer?.cancel();
//                     },
//                   )
//                       : null,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                 ),
//                 onChanged: (value) {
//                   // Cancel previous timer
//                   debounceTimer?.cancel();
//
//                   if (value.isEmpty) {
//                     filteredCustomers.value = controller.customers;
//                     searchedCustomer.value = null;
//                     showAddForm.value = false;
//                     isSearching.value = false;
//                     return;
//                   }
//
//                   // ✅ API Search with debouncing (500ms delay)
//                   if (value.length >= 3) {
//                     isSearching.value = true;
//                     debounceTimer = Timer(const Duration(milliseconds: 500), () async {
//                       final result = await controller.searchCustomerByPhone(value);
//                       isSearching.value = false;
//
//                       if (result != null) {
//                         // Customer found via API
//                         searchedCustomer.value = result;
//                         filteredCustomers.value = [result];
//                         showAddForm.value = false;
//                       } else {
//                         // Not found via API, search locally
//                         filteredCustomers.value = controller.customers
//                             .where((customer) =>
//                         customer.phone
//                             .toLowerCase()
//                             .contains(value.toLowerCase()) ||
//                             customer.name
//                                 .toLowerCase()
//                                 .contains(value.toLowerCase()))
//                             .toList();
//                         searchedCustomer.value = null;
//                       }
//                     });
//                   } else {
//                     // Local search for < 3 characters
//                     isSearching.value = false;
//                     filteredCustomers.value = controller.customers
//                         .where((customer) =>
//                     customer.phone
//                         .toLowerCase()
//                         .contains(value.toLowerCase()) ||
//                         customer.name.toLowerCase().contains(value.toLowerCase()))
//                         .toList();
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//
//
//               // Customer List or Add Form
//               Expanded(
//                 child: Obx(() {
//                   // Show Add Form if toggled
//                   if (showAddForm.value) {
//                     return SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Add New Customer',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF1A1F36),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           // Phone Number Input
//                           TextField(
//                             controller: dialogPhoneController,
//                             decoration: InputDecoration(
//                               hintText: 'Enter phone number',
//                               labelText: 'Phone Number',
//                               prefixIcon: const Icon(Icons.phone_android, size: 20),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey.shade300),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                     color: AppColors.primaryGold, width: 2),
//                               ),
//                               filled: true,
//                               fillColor: Colors.grey.shade50,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 14),
//                             ),
//                             keyboardType: TextInputType.phone,
//                           ),
//                           const SizedBox(height: 12),
//                           // Customer Name Input
//                           TextField(
//                             controller: dialogNameController,
//                             decoration: InputDecoration(
//                               hintText: 'Enter customer name',
//                               labelText: 'Customer Name',
//                               prefixIcon: const Icon(Icons.person_outline, size: 20),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey.shade300),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                     color: AppColors.primaryGold, width: 2),
//                               ),
//                               filled: true,
//                               fillColor: Colors.grey.shade50,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 14),
//                             ),
//                             textCapitalization: TextCapitalization.words,
//                           ),
//                           const SizedBox(height: 16),
//                           // Action Buttons
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton(
//                                   onPressed: () {
//                                     dialogPhoneController.clear();
//                                     dialogNameController.clear();
//                                     showAddForm.value = false;
//                                   },
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(vertical: 14),
//                                     side: BorderSide(color: Colors.grey.shade300),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Cancel',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     if (dialogPhoneController.text.isEmpty ||
//                                         dialogNameController.text.isEmpty) {
//                                       Get.snackbar(
//                                         'Required',
//                                         'Please fill in all fields',
//                                         snackPosition: SnackPosition.BOTTOM,
//                                         backgroundColor: Colors.red,
//                                         colorText: Colors.white,
//                                         duration: const Duration(seconds: 2),
//                                       );
//                                       return;
//                                     }
//
//                                     final phoneToSearch = dialogPhoneController.text;
//                                     controller.addFieldController.text =
//                                         dialogPhoneController.text;
//                                     controller.nameController.text =
//                                         dialogNameController.text;
//
//                                     await controller.createCustomer();
//                                     await Future.delayed(
//                                         const Duration(milliseconds: 500));
//
//                                     // Search for newly created customer via API
//                                     final newCustomer =
//                                     await controller.searchCustomerByPhone(phoneToSearch);
//
//                                     if (newCustomer != null) {
//                                       controller.selectCustomer(newCustomer);
//                                       Get.snackbar(
//                                         'Success',
//                                         'Customer added and selected',
//                                         snackPosition: SnackPosition.BOTTOM,
//                                         backgroundColor: Colors.green,
//                                         colorText: Colors.white,
//                                         duration: const Duration(seconds: 2),
//                                       );
//                                       await Future.delayed(
//                                           const Duration(milliseconds: 500));
//                                       debounceTimer?.cancel();
//                                       Get.back();
//                                     }
//
//                                     dialogPhoneController.clear();
//                                     dialogNameController.clear();
//                                     showAddForm.value = false;
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.success,
//                                     padding: const EdgeInsets.symmetric(vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: const Text(
//                                     'Add Customer',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   // Show loading indicator
//                   if (isSearching.value) {
//                     return const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircularProgressIndicator(),
//                           SizedBox(height: 16),
//                           Text('Searching...'),
//                         ],
//                       ),
//                     );
//                   }
//
//                   // Show empty state with Add button
//                   if (filteredCustomers.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.search_off,
//                               size: 64, color: Colors.grey.shade300),
//                           const SizedBox(height: 16),
//                           Text(
//                             'No customers found',
//                             style: TextStyle(
//                               color: Colors.grey.shade500,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             searchController.text.isNotEmpty
//                                 ? 'Customer not found in system'
//                                 : 'Start typing to search',
//                             style: TextStyle(
//                               color: Colors.grey.shade400,
//                               fontSize: 13,
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               if (searchController.text.isNotEmpty) {
//                                 dialogPhoneController.text = searchController.text;
//                               }
//                               showAddForm.value = true;
//                             },
//                             icon: const Icon(Icons.person_add, size: 20),
//                             label: const Text('Add New Customer'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primaryGold,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 24,
//                                 vertical: 14,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 0,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   // Show customer list
//                   return ListView.separated(
//                     itemCount: filteredCustomers.length,
//                     separatorBuilder: (_, __) => Divider(
//                       height: 1,
//                       color: Colors.grey.shade200,
//                     ),
//                     itemBuilder: (context, index) {
//                       final customer = filteredCustomers[index];
//                       final isSelected =
//                           controller.selectedCustomer.value?.id == customer.id;
//                       final isFromAPI = searchedCustomer.value?.id == customer.id;
//
//                       return ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         leading: Stack(
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? AppColors.primaryGold.withOpacity(0.1)
//                                     : Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Icon(
//                                 Icons.person,
//                                 color: isSelected
//                                     ? AppColors.primaryGold
//                                     : Colors.grey.shade600,
//                                 size: 20,
//                               ),
//                             ),
//                             if (isFromAPI)
//                               Positioned(
//                                 right: 0,
//                                 bottom: 0,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green,
//                                     shape: BoxShape.circle,
//                                     border: Border.all(color: Colors.white, width: 1),
//                                   ),
//                                   child: const Icon(
//                                     Icons.cloud_done,
//                                     size: 10,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         title: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 customer.phone,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: isSelected
//                                       ? AppColors.primaryGold
//                                       : Colors.black87,
//                                 ),
//                               ),
//                             ),
//                             // Show points badge
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.amber.shade100,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.star,
//                                       size: 12, color: Colors.amber.shade700),
//                                   const SizedBox(width: 2),
//                                   Text(
//                                     '${customer.totalPoints}',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.amber.shade900,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         subtitle: Text(
//                           customer.name,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         trailing: isSelected
//                             ? const Icon(
//                           Icons.check_circle,
//                           color: AppColors.primaryGold,
//                           size: 24,
//                         )
//                             : null,
//                         selected: isSelected,
//                         selectedTileColor: AppColors.primaryGold.withOpacity(0.05),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         onTap: () {
//                           controller.selectCustomer(customer);
//                           debounceTimer?.cancel();
//                           Get.back();
//                         },
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ).then((_) {
//       // Clean up timer when dialog closes
//       debounceTimer?.cancel();
//     });
//   }
//   Widget _buildPaymentSummaryWithPoints(CartController controller) {
//     return Obx(() {
//       final subtotal = double.parse(controller.subtotalAmount);
//       final pointsValue = controller.pointsRedeemedValue;
//       final total = double.parse(controller.grandTotal);
//
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Column(
//           children: [
//             _buildSummaryRow('Subtotal', 'RM ${subtotal.toStringAsFixed(2)}'),
//
//             // Show points redemption if applied
//             if (controller.pointsToRedeem.value > 0) ...[
//               const SizedBox(height: 8),
//               _buildSummaryRow(
//                 'Points Redeemed',
//                 '-RM ${pointsValue.toStringAsFixed(2)}',
//                 valueColor: Colors.green,
//               ),
//             ],
//
//             const Divider(height: 20),
//
//             _buildSummaryRow(
//               'Total',
//               'RM ${total.toStringAsFixed(2)}',
//               isBold: true,
//               labelSize: 16,
//               valueSize: 18,
//             ),
//           ],
//         ),
//       );
//     });
//   }
//
//   Widget _buildSummaryRow(
//       String label,
//       String value, {
//         bool isBold = false,
//         double labelSize = 14,
//         double valueSize = 14,
//         Color? valueColor,
//       }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: labelSize,
//             fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: valueSize,
//             fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
//             color: valueColor ?? (isBold ? Colors.black : Colors.grey.shade800),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ===== MINIMAL COMPACT CART LIST =====
// // Replace your _buildCartList method with this simple version
//
//   Widget _buildCartList(CartController controller, {double maxHeight = 400}) {
//     return Obx(() => Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             'Cart Item',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1A1F36),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Customer Points Badge
//               Obx(() {
//                 if (controller.selectedCustomer.value != null) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.amber.shade700, Colors.amber.shade600],
//                       ),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.stars, color: Colors.white, size: 12),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${controller.selectedCustomer.value!.totalPoints}',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         const SizedBox(width: 2),
//                         Text(
//                           'pts',
//                           style: TextStyle(
//                             fontSize: 9,
//                             color: Colors.white.withOpacity(0.9),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               }),
//
//               // Cart Items Count
//               if (controller.cartItems.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.orangeAccent.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     '${controller.totalItemCount} items',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 11,
//                       color: Colors.orangeAccent,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           // Cart Items
//           controller.cartItems.isEmpty
//               ? Container(
//             height: 200,
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.shopping_cart_outlined,
//                     size: 48, color: Colors.grey.shade300),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Cart is empty',
//                   style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//                 ),
//               ],
//             ),
//           )
//               : LayoutBuilder(
//             builder: (context, constraints) {
//               // ✅ Calculate max height based on screen
//               final screenHeight = MediaQuery.of(context).size.height;
//               final calculatedMaxHeight = maxHeight == double.infinity
//                   ? screenHeight * 0.5 // Use 50% of screen height if infinite
//                   : maxHeight;
//
//               return ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxHeight: calculatedMaxHeight, // ✅ Dynamic height
//                   minHeight: 100,
//                 ),
//                 child: ListView.separated(
//                   shrinkWrap: true,
//                   physics: const AlwaysScrollableScrollPhysics(), // ✅ Enable scrolling
//                   itemCount: controller.cartItems.length,
//                   separatorBuilder: (_, __) => Divider(
//                     height: 8,
//                     thickness: 0.5,
//                     color: Colors.grey.shade200,
//                   ),
//                   itemBuilder: (_, index) {
//                     final cartItem = controller.cartItems[index];
//                     final item = cartItem.item;
//
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Product Details
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item.title,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 3),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.star,
//                                         size: 11, color: Colors.amber.shade600),
//                                     const SizedBox(width: 3),
//                                     if (cartItem.quantity > 1) ...[
//                                       Text(
//                                         '${item.pointsEarned} × ${cartItem.quantity} = ',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.grey[500],
//                                         ),
//                                       ),
//                                       Text(
//                                         '${cartItem.totalPoints}',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.grey[600],
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                       ),
//                                     ] else
//                                       Text(
//                                         '${cartItem.totalPoints}',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.grey[600],
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     Text(
//                                       ' pts',
//                                       style: TextStyle(
//                                         fontSize: 9,
//                                         color: Colors.grey[500],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//
//                           // Quantity Controls
//                           Row(
//                             children: [
//                               InkWell(
//                                 onTap: () => controller.decrementQuantity(index),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.shade50,
//                                     borderRadius: BorderRadius.circular(4),
//                                     border: Border.all(
//                                         color: Colors.red.shade200, width: 1),
//                                   ),
//                                   child: Icon(
//                                     cartItem.quantity == 1
//                                         ? Icons.delete_outline
//                                         : Icons.remove,
//                                     size: 14,
//                                     color: Colors.red.shade700,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                                 child: Text(
//                                   '${cartItem.quantity}',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                               InkWell(
//                                 onTap: () => controller.incrementQuantity(index),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade50,
//                                     borderRadius: BorderRadius.circular(4),
//                                     border: Border.all(
//                                         color: Colors.green.shade200, width: 1),
//                                   ),
//                                   child: Icon(
//                                     Icons.add,
//                                     size: 14,
//                                     color: Colors.green.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 8),
//
//                           // Price
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'RM ${cartItem.totalPrice.toStringAsFixed(2)}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w700,
//                                   color: Color(0xFF10B981),
//                                   fontSize: 13,
//                                 ),
//                               ),
//                               if (cartItem.quantity > 1)
//                                 Text(
//                                   '@${item.price.toStringAsFixed(2)}',
//                                   style: TextStyle(
//                                     fontSize: 9,
//                                     color: Colors.grey[500],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     ));
//   }
//
//   Widget _buildPaymentSection(CartController controller) {
//     return Obx(() => Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.primaryGold, AppColors.primaryGold],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF667EEA).withOpacity(0.25),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min, // ✅ Important
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Grand Total',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 'RM ${controller.grandTotal}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 20,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Total Points',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                 ),
//               ),
//               Row(
//                 children: [
//                   const Icon(Icons.stars, color: Colors.amber, size: 14),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${controller.totalPoints}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Divider(color: Colors.white24, height: 1),
//           const SizedBox(height: 12),
//           const Text(
//             'Payment Method',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 6,
//             runSpacing: 6,
//             children: [
//               _paymentChip(
//                 'Cash',
//                 Icons.money,
//                 controller.isCash,
//                     () => controller.selectPaymentMethod('cash'), // ✅ Add callback
//               ),
//               _paymentChip(
//                 'Online',
//                 Icons.credit_card,
//                 controller.isOnline,
//                     () => controller.selectPaymentMethod('online'), // ✅ Add callback
//               ),
//               // _paymentChip(
//               //   'QR',
//               //   Icons.qr_code,
//               //   controller.isQr,
//               //       () => controller.selectPaymentMethod('qr'), // ✅ Add callback
//               // ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.success,
//                 foregroundColor:  AppColors.primaryGold,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: controller.cartItems.isEmpty
//                   ? null
//                   : () => controller.makePayment(),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.payment, size: 18, color: AppColors.cardBackground),
//                   SizedBox(width: 6),
//                   Text(
//                     'Proceed to Payment',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 14,
//                       color: AppColors.cardBackground
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ));
//   }
//
//
//   Widget _paymentChip(String label, IconData icon, RxBool value, VoidCallback onTap) {
//     return Obx(() => FilterChip(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//               icon,
//               size: 14,
//               color: value.value ? AppColors.success : Colors.white70
//           ),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: value.value ? AppColors.darkGold : AppColors.success,
//               fontWeight: value.value ? FontWeight.w600 : FontWeight.w500,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//       selected: value.value,
//       onSelected: (val) {
//         if (val) {
//           onTap(); // ✅ Call the toggle method
//         } else {
//           value.value = false; // ✅ Allow deselection
//         }
//       },
//       selectedColor: AppColors.success.withOpacity(0.25),
//       backgroundColor: AppColors.success.withOpacity(0.1),
//       checkmarkColor: AppColors.success,
//       side: BorderSide(
//         color: value.value
//             ? AppColors.success.withOpacity(0.5)
//             : AppColors.success.withOpacity(0.2),
//         width: 1.5,
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//     ));
//   }
//
//   void _showCartBottomSheet(BuildContext context, CartController controller) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.8,
//         decoration: const BoxDecoration(
//           color: Color(0xFFF5F7FA),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     _buildBarberSelection(controller, isMobile: true),
//                     const SizedBox(height: 16),
//                     _buildCartList(controller),
//                     const SizedBox(height: 16),
//                     // ✅ Add Points Redemption Widget in Mobile Bottom Sheet
//                     PointsRedemptionWidget(controller: controller),
//
//                     const SizedBox(height: 16),
//                     _buildPaymentSummaryWithPoints(controller),
//                     const SizedBox(height: 16),
//                     _buildPaymentSection(controller),
//                     const SizedBox(height: 16), // Extra bottom padding
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/cart_widgets.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/customer_widgets.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/payment_widgets.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/points_redemption_widget.dart';
import 'package:babershop_project/App/Modules/barber_staff_selection/widget/product_widgets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BarberSelectionPage extends StatelessWidget {
  const BarberSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            return _buildDesktopLayout(controller, constraints);
          } else if (constraints.maxWidth > 600) {
            return _buildTabletLayout(controller, constraints);
          } else {
            return _buildMobileLayout(controller, constraints);
          }
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (MediaQuery.of(context).size.width <= 600) {
            return Obx(() => controller.cartItems.isNotEmpty
                ? FloatingActionButton.extended(
              onPressed: () => CartWidgets.showCartBottomSheet(context, controller),
              backgroundColor: Colors.orangeAccent,
              icon: Badge(
                label: Text('${controller.cartItems.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: Text(
                'RM ${controller.grandTotal}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
                : const SizedBox.shrink());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

// ✅ DESKTOP LAYOUT
  Widget _buildDesktopLayout(CartController controller, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: ProductWidgets.buildProductsSection(controller, crossAxisCount: 4),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 450,
            child: _buildCartSection(
              controller,
              maxHeight: 400,
              containerHeight: null, // ✅ Desktop: flexible height
            ),
          ),
        ],
      ),
    );
  }

// ✅ TABLET LAYOUT
  Widget _buildTabletLayout(CartController controller, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: ProductWidgets.buildProductsSection(controller, crossAxisCount: 3),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 340,
            child: _buildCartSection(
              controller,
              maxHeight: 600,
              containerHeight: 750, // ✅ TABLET: Fixed 750px height
            ),
          ),
        ],
      ),
    );
  }

// ✅ MOBILE LAYOUT
  Widget _buildMobileLayout(CartController controller, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomerWidgets.buildBarberSelection(controller, isMobile: true),
            const SizedBox(height: 16),
            ProductWidgets.buildProductsSection(controller, crossAxisCount: 2, isMobile: true),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

// ✅ CART SECTION - Updated to accept containerHeight
  Widget _buildCartSection(
      CartController controller, {
        double maxHeight = 400,
        double? containerHeight, // ✅ NEW parameter
      }) {
    return Column(
      children: [
        CustomerWidgets.buildBarberSelection(controller),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                CartWidgets.buildCartList(
                  controller,
                  maxHeight: maxHeight,
                  containerHeight: containerHeight, // ✅ Pass to cart
                ),
                const SizedBox(height: 10),
                PointsRedemptionWidget(controller: controller),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        PaymentWidgets.buildPaymentSection(controller),
      ],
    );
  }

  // ✅ CART SECTION WITH FIXED PAYMENT

}