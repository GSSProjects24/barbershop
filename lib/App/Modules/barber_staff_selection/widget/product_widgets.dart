import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetCateoriesModel.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetItemModel.dart';
import 'package:babershop_project/App/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidgets {
  // ✅ Products Section
  static Widget buildProductsSection(
      CartController controller, {
        required int crossAxisCount,
        bool isMobile = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductSearchBar(controller),
        const SizedBox(height: 12),
        _buildCategoryFilters(controller),
        const SizedBox(height: 12),
        if (!isMobile)
          Expanded(child: _buildProductsGrid(controller, crossAxisCount))
        else
          _buildProductsGrid(controller, crossAxisCount),
      ],
    );
  }

  // ✅ Search Bar
  static Widget _buildProductSearchBar(CartController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search products by name or SKU...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade600),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, size: 20, color: Colors.grey.shade600),
            onPressed: () => controller.clearSearch(),
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
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    ));
  }

  // ✅ Category Filters
  static Widget _buildCategoryFilters(CartController controller) {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return _buildCategoryFiltersShimmer();
      }

      if (controller.categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('No categories available', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryChip(controller, 0, 'ALL'),
            ...controller.categories.map((category) =>
                _buildCategoryChip(controller, category.id ?? 0, category.name ?? 'Unknown')),
          ],
        ),
      );
    });
  }

  static Widget _buildCategoryChip(CartController controller, int categoryId, String categoryName) {
    return Obx(() {
      final isSelected = controller.selectedCategoryId.value == categoryId;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(
            categoryName.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : AppColors.darkGold,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => categoryId == 0
              ? controller.clearCategoryFilter()
              : controller.selectCategory(categoryId, categoryName),
          selectedColor: AppColors.primaryGold,
          backgroundColor: Colors.white,
          elevation: isSelected ? 2 : 0,
          pressElevation: 2,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primaryGold : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      );
    });
  }

  static Widget _buildCategoryFiltersShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          5,
              (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Products Grid
  static Widget _buildProductsGrid(CartController controller, int crossAxisCount) {
    return Obx(() {
      if (controller.isLoadingItems.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty) {
        return _buildEmptyState(controller);
      }

      return SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.80,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.products.length,
          itemBuilder: (_, index) => _buildProductCard(controller.products[index], controller),
        ),
      );
    });
  }

  static Widget _buildEmptyState(CartController controller) {
    String emptyMessage = 'No items available';
    IconData emptyIcon = Icons.inventory_2_outlined;

    if (controller.searchQuery.value.isNotEmpty) {
      emptyMessage = 'No products found for "${controller.searchQuery.value}"';
      emptyIcon = Icons.search_off;
    } else if (controller.selectedCategoryId.value != 0) {
      emptyMessage = 'No products in ${controller.selectedCategoryName.value}';
      emptyIcon = Icons.category_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(emptyMessage, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          if (controller.searchQuery.value.isNotEmpty || controller.selectedCategoryId.value != 0) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearSearch();
                controller.clearCategoryFilter();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ Product Card
  static Widget _buildProductCard(ItemModel product, CartController controller) {
    return InkWell(
      onTap: () => controller.addToCart(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentAmber.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductImage(product),
            Expanded(child: _buildProductDetails(product, controller)),
          ],
        ),
      ),
    );
  }

  static Widget _buildProductImage(ItemModel product) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            product.imageUrl,
            height: 80,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 80,
              color: Colors.grey.shade200,
              child: Image.asset("images/logo.jpg", height: 200, width: double.infinity),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.type == 'service' ? Colors.blue.withOpacity(0.9) : Colors.purple.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.type.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${product.pointsEarned ?? 0}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildProductDetails(ItemModel product, CartController controller) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final searchQuery = controller.searchQuery.value.toLowerCase();
            final productName = product.title;

            if (searchQuery.isEmpty || !productName.toLowerCase().contains(searchQuery)) {
              return Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1F36)),
              );
            }

            final startIndex = productName.toLowerCase().indexOf(searchQuery);
            final endIndex = startIndex + searchQuery.length;

            return RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1F36)),
                children: [
                  if (startIndex > 0) TextSpan(text: productName.substring(0, startIndex)),
                  TextSpan(
                    text: productName.substring(startIndex, endIndex),
                    style: const TextStyle(backgroundColor: Color(0xFFFFEB3B), fontWeight: FontWeight.w700),
                  ),
                  if (endIndex < productName.length) TextSpan(text: productName.substring(endIndex)),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text('SKU: ${product.sku}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RM ${product.price}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF10B981)),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.orangeAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}