import 'package:babershop_project/App/Modules/barber_staff_selection/categories_controller.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetCateoriesModel.dart';
import 'package:babershop_project/App/Modules/getcategoriModel/GetItemModel.dart';
import 'package:babershop_project/App/config/app_colors.dart';
import 'package:babershop_project/App/config/responsive_size.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidgets {
  // ✅ Products Section
  static Widget buildProductsSection(
      CartController controller, {
        bool isMobile = false,
      }) {
    return Builder(
      builder: (context) {
        final sizes = ResponsiveSizes(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductSearchBar(controller, sizes),
            const SizedBox(height: 12),
            _buildCategoryFilters(controller, sizes),
            const SizedBox(height: 12),
            if (!isMobile)
              Expanded(child: _buildProductsGrid(controller, sizes))
            else
              _buildProductsGrid(controller, sizes),
          ],
        );
      },
    );
  }

  // ✅ Search Bar
  static Widget _buildProductSearchBar(CartController controller, ResponsiveSizes sizes) {
    final componentSizes = sizes.components;

    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search products by name or SKU...',
          hintStyle: TextStyle(
            fontSize: componentSizes.searchBarFontSize,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: componentSizes.iconSizeMedium,
            color: Colors.grey.shade600,
          ),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              size: componentSizes.iconSizeMedium,
              color: Colors.grey.shade600,
            ),
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: componentSizes.containerPadding,
            vertical: 12,
          ),
          isDense: true,
        ),
        style: TextStyle(fontSize: componentSizes.searchBarFontSize),
      ),
    ));
  }

  // ✅ Category Filters
  static Widget _buildCategoryFilters(CartController controller, ResponsiveSizes sizes) {
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
            _buildCategoryChip(controller, sizes, 0, 'ALL'),
            ...controller.categories.map((category) =>
                _buildCategoryChip(controller, sizes, category.id ?? 0, category.name ?? 'Unknown')),
          ],
        ),
      );
    });
  }

  static Widget _buildCategoryChip(
      CartController controller,
      ResponsiveSizes sizes,
      int categoryId,
      String categoryName,
      ) {
    final componentSizes = sizes.components;

    return Obx(() {
      final isSelected = controller.selectedCategoryId.value == categoryId;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(
            categoryName.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: componentSizes.categoryChipFontSize,
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
          padding: EdgeInsets.symmetric(
            horizontal: componentSizes.categoryChipPadding,
            vertical: 10,
          ),
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
  static Widget _buildProductsGrid(CartController controller, ResponsiveSizes sizes) {
    return Obx(() {
      if (controller.isLoadingItems.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty) {
        return _buildEmptyState(controller, sizes);
      }

      final gridSizes = sizes.productGrid;

      return SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSizes.crossAxisCount,
            childAspectRatio: gridSizes.childAspectRatio,
            crossAxisSpacing: gridSizes.crossAxisSpacing,
            mainAxisSpacing: gridSizes.mainAxisSpacing,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) => _buildProductCard(
            controller.products[index],
            controller,
            sizes,
          ),
        ),
      );
    });
  }

  static Widget _buildEmptyState(CartController controller, ResponsiveSizes sizes) {
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
          Text(
            emptyMessage,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: sizes.typography.bodyLarge,
            ),
            textAlign: TextAlign.center,
          ),
          if (controller.searchQuery.value.isNotEmpty ||
              controller.selectedCategoryId.value != 0) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearSearch();
                controller.clearCategoryFilter();
              },
              icon: Icon(Icons.refresh, size: sizes.components.iconSizeSmall),
              label: Text(
                'Clear Filters',
                style: TextStyle(fontSize: sizes.typography.bodyMedium),
              ),
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
  static Widget _buildProductCard(
      ItemModel product,
      CartController controller,
      ResponsiveSizes sizes,
      ) {
    final gridSizes = sizes.productGrid;

    return InkWell(
      onTap: () => controller.addToCart(product),
      borderRadius: BorderRadius.circular(gridSizes.cardBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(gridSizes.cardBorderRadius),
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
            _buildProductImage(product, gridSizes),
            Expanded(child: _buildProductDetails(product, controller, sizes)),
          ],
        ),
      ),
    );
  }

  static Widget _buildProductImage(ItemModel product, ProductGridSizes gridSizes) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(gridSizes.cardBorderRadius)),
          child: Image.network(
            product.imageUrl,
            height: gridSizes.cardImageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: gridSizes.cardImageHeight,
              color: Colors.grey.shade200,
              child: Image.asset("images/logo.jpg", height: 200, width: double.infinity),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: gridSizes.badgePadding,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: product.type == 'service'
                  ? Colors.blue.withOpacity(0.9)
                  : Colors.purple.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.type.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: gridSizes.badgeFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: gridSizes.badgePadding,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: gridSizes.badgeFontSize + 4),
                const SizedBox(width: 4),
                Text(
                  '${product.pointsEarned ?? 0}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: gridSizes.badgeFontSize + 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildProductDetails(
      ItemModel product,
      CartController controller,
      ResponsiveSizes sizes,
      ) {
    final gridSizes = sizes.productGrid;

    return Padding(
      padding: EdgeInsets.all(gridSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final searchQuery = controller.searchQuery.value.toLowerCase();
            final productName = product.title;

            if (searchQuery.isEmpty || !productName.toLowerCase().contains(searchQuery)) {
              return Text(
                productName,
                maxLines: gridSizes.productNameMaxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: gridSizes.productNameFontSize,
                  color: const Color(0xFF1A1F36),
                  height: 1.3,
                ),
              );
            }

            final startIndex = productName.toLowerCase().indexOf(searchQuery);
            final endIndex = startIndex + searchQuery.length;

            return RichText(
              maxLines: gridSizes.productNameMaxLines,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: gridSizes.productNameFontSize,
                  color: const Color(0xFF1A1F36),
                  height: 1.3,
                ),
                children: [
                  if (startIndex > 0) TextSpan(text: productName.substring(0, startIndex)),
                  TextSpan(
                    text: productName.substring(startIndex, endIndex),
                    style: const TextStyle(
                      backgroundColor: Color(0xFFFFEB3B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (endIndex < productName.length) TextSpan(text: productName.substring(endIndex)),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            'SKU: ${product.sku}',
            style: TextStyle(
              fontSize: gridSizes.skuFontSize,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RM ${product.price}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: gridSizes.priceFontSize,
                  color: const Color(0xFF10B981),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_shopping_cart,
                  size: sizes.components.iconSizeSmall,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}