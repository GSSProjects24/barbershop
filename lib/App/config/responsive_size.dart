import 'package:flutter/material.dart';

class ResponsiveSizes {
  final BuildContext context;

  ResponsiveSizes(this.context);

  // Screen breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // Get screen width
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // Current device type
  DeviceType get deviceType {
    if (screenWidth > tabletBreakpoint) return DeviceType.desktop;
    if (screenWidth > mobileBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isMobile => deviceType == DeviceType.mobile;

  // Layout sizes
  LayoutSizes get layout {
    switch (deviceType) {
      case DeviceType.desktop:
        return const LayoutSizes(
          pagePadding: 24.0,
          sectionSpacing: 24.0,
          cartWidth: 450.0,
          cartMaxHeight: 400.0,
          cartContainerHeight: null,
          productFlex: 7,
          cartFlex: 3,
        );
      case DeviceType.tablet:
        return const LayoutSizes(
          pagePadding: 20.0, // ✅ Increased from 16
          sectionSpacing: 20.0, // ✅ Increased from 16
          cartWidth: 420.0, // ✅ Increased from 400
          cartMaxHeight: 600.0,
          cartContainerHeight: 750.0,
          productFlex: 6,
          cartFlex: 4,
        );
      case DeviceType.mobile:
        return const LayoutSizes(
          pagePadding: 16.0,
          sectionSpacing: 16.0,
          bottomSheetHeightFactor: 0.8,
          cartMaxHeight: 500.0,
          fabBottomPadding: 80.0,
        );
    }
  }

  // Product grid sizes
  ProductGridSizes get productGrid {
    switch (deviceType) {
      case DeviceType.desktop:
        return const ProductGridSizes(
          crossAxisCount: 4,
          childAspectRatio: 0.80,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          cardImageHeight: 120.0,
          cardBorderRadius: 16.0,
          cardPadding: 12.0,
          productNameFontSize: 14.0,
          productNameMaxLines: 2,
          skuFontSize: 11.0,
          priceFontSize: 16.0,
          badgeFontSize: 10.0,
          badgePadding: 8.0,
        );
      case DeviceType.tablet:
        return const ProductGridSizes(
          crossAxisCount: 3, // Keep 3 columns for iPad
          childAspectRatio: 0.85, // ✅ Increased from 0.80 for taller cards
          crossAxisSpacing: 20.0, // ✅ Increased from 16
          mainAxisSpacing: 20.0, // ✅ Increased from 16
          cardImageHeight: 140.0, // ✅ Increased from 100 for bigger images
          cardBorderRadius: 16.0,
          cardPadding: 14.0, // ✅ Increased from 12
          productNameFontSize: 15.0, // ✅ Increased from 13
          productNameMaxLines: 2,
          skuFontSize: 11.0,
          priceFontSize: 18.0, // ✅ Increased from 15
          badgeFontSize: 10.0, // ✅ Increased from 9
          badgePadding: 8.0, // ✅ Increased from 7
        );
      case DeviceType.mobile:
        return const ProductGridSizes(
          crossAxisCount: 2,
          childAspectRatio: 0.80,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 16.0,
          cardImageHeight: 80.0,
          cardBorderRadius: 12.0,
          cardPadding: 10.0,
          productNameFontSize: 12.0,
          productNameMaxLines: 2,
          skuFontSize: 10.0,
          priceFontSize: 14.0,
          badgeFontSize: 9.0,
          badgePadding: 6.0,
        );
    }
  }

  // Component sizes
  ComponentSizes get components {
    switch (deviceType) {
      case DeviceType.desktop:
        return const ComponentSizes(
          searchBarHeight: 52.0,
          searchBarFontSize: 14.0,
          dropdownHeight: 56.0,
          dropdownFontSize: 14.0,
          buttonHeight: 50.0,
          buttonFontSize: 14.0,
          categoryChipHeight: 40.0,
          categoryChipFontSize: 13.0,
          categoryChipPadding: 16.0,
          cartItemHeight: 60.0,
          cartItemFontSize: 13.0,
          quantityButtonSize: 28.0,
          iconSizeSmall: 18.0,
          iconSizeMedium: 20.0,
          iconSizeLarge: 24.0,
          containerPadding: 16.0,
          containerBorderRadius: 16.0,
        );
      case DeviceType.tablet:
        return const ComponentSizes(
          searchBarHeight: 54.0, // ✅ Increased from 50
          searchBarFontSize: 15.0, // ✅ Increased from 14
          dropdownHeight: 58.0, // ✅ Increased from 56
          dropdownFontSize: 15.0, // ✅ Increased from 14
          buttonHeight: 52.0, // ✅ Increased from 48
          buttonFontSize: 15.0, // ✅ Increased from 14
          categoryChipHeight: 44.0, // ✅ Increased from 40
          categoryChipFontSize: 14.0, // ✅ Increased from 13
          categoryChipPadding: 18.0, // ✅ Increased from 14
          cartItemHeight: 65.0, // ✅ Increased from 60
          cartItemFontSize: 14.0, // ✅ Increased from 13
          quantityButtonSize: 32.0, // ✅ Increased from 28
          iconSizeSmall: 18.0, // ✅ Increased from 16
          iconSizeMedium: 22.0, // ✅ Increased from 18
          iconSizeLarge: 24.0, // ✅ Increased from 20
          containerPadding: 18.0, // ✅ Increased from 16
          containerBorderRadius: 16.0,
        );
      case DeviceType.mobile:
        return const ComponentSizes(
          searchBarHeight: 48.0,
          searchBarFontSize: 14.0,
          dropdownHeight: 56.0,
          dropdownFontSize: 14.0,
          buttonHeight: 48.0,
          buttonFontSize: 14.0,
          categoryChipHeight: 36.0,
          categoryChipFontSize: 12.0,
          categoryChipPadding: 12.0,
          cartItemHeight: 60.0,
          cartItemFontSize: 13.0,
          quantityButtonSize: 28.0,
          iconSizeSmall: 16.0,
          iconSizeMedium: 18.0,
          iconSizeLarge: 20.0,
          containerPadding: 16.0,
          containerBorderRadius: 12.0,
        );
    }
  }

  // Typography sizes
  TypographySizes get typography {
    switch (deviceType) {
      case DeviceType.desktop:
        return const TypographySizes(
          headerLarge: 20.0,
          headerMedium: 18.0,
          headerSmall: 16.0,
          bodyLarge: 16.0,
          bodyMedium: 14.0,
          bodySmall: 12.0,
          caption: 11.0,
          button: 14.0,
        );
      case DeviceType.tablet:
        return const TypographySizes(
          headerLarge: 20.0, // ✅ Increased from 18
          headerMedium: 18.0, // ✅ Increased from 16
          headerSmall: 16.0, // ✅ Increased from 14
          bodyLarge: 16.0, // ✅ Increased from 15
          bodyMedium: 14.0, // ✅ Increased from 13
          bodySmall: 12.0, // ✅ Increased from 11
          caption: 11.0, // ✅ Increased from 10
          button: 15.0, // ✅ Increased from 14
        );
      case DeviceType.mobile:
        return const TypographySizes(
          headerLarge: 18.0,
          headerMedium: 16.0,
          headerSmall: 14.0,
          bodyLarge: 14.0,
          bodyMedium: 13.0,
          bodySmall: 11.0,
          caption: 10.0,
          button: 14.0,
        );
    }
  }

  // Dialog/Modal sizes
  DialogSizes get dialog {
    switch (deviceType) {
      case DeviceType.desktop:
        return const DialogSizes(
          width: 500.0,
          height: 600.0,
          padding: 20.0,
          borderRadius: 16.0,
        );
      case DeviceType.tablet:
        return const DialogSizes(
          width: 480.0, // ✅ Increased from 450
          height: 580.0, // ✅ Increased from 550
          padding: 22.0, // ✅ Increased from 20
          borderRadius: 16.0,
        );
      case DeviceType.mobile:
        return DialogSizes(
          width: screenWidth * 0.9,
          height: screenHeight * 0.75,
          padding: 16.0,
          borderRadius: 16.0,
        );
    }
  }
}

enum DeviceType { desktop, tablet, mobile }

// ==================== Data Classes ====================

class LayoutSizes {
  final double pagePadding;
  final double sectionSpacing;
  final double? cartWidth;
  final double cartMaxHeight;
  final double? cartContainerHeight;
  final double? bottomSheetHeightFactor;
  final double? fabBottomPadding;
  final int? productFlex;
  final int? cartFlex;

  const LayoutSizes({
    required this.pagePadding,
    required this.sectionSpacing,
    this.cartWidth,
    required this.cartMaxHeight,
    this.cartContainerHeight,
    this.bottomSheetHeightFactor,
    this.fabBottomPadding,
    this.productFlex,
    this.cartFlex,
  });
}

class ProductGridSizes {
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double cardImageHeight;
  final double cardBorderRadius;
  final double cardPadding;
  final double productNameFontSize;
  final int productNameMaxLines;
  final double skuFontSize;
  final double priceFontSize;
  final double badgeFontSize;
  final double badgePadding;

  const ProductGridSizes({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.cardImageHeight,
    required this.cardBorderRadius,
    required this.cardPadding,
    required this.productNameFontSize,
    required this.productNameMaxLines,
    required this.skuFontSize,
    required this.priceFontSize,
    required this.badgeFontSize,
    required this.badgePadding,
  });
}

class ComponentSizes {
  final double searchBarHeight;
  final double searchBarFontSize;
  final double dropdownHeight;
  final double dropdownFontSize;
  final double buttonHeight;
  final double buttonFontSize;
  final double categoryChipHeight;
  final double categoryChipFontSize;
  final double categoryChipPadding;
  final double cartItemHeight;
  final double cartItemFontSize;
  final double quantityButtonSize;
  final double iconSizeSmall;
  final double iconSizeMedium;
  final double iconSizeLarge;
  final double containerPadding;
  final double containerBorderRadius;

  const ComponentSizes({
    required this.searchBarHeight,
    required this.searchBarFontSize,
    required this.dropdownHeight,
    required this.dropdownFontSize,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.categoryChipHeight,
    required this.categoryChipFontSize,
    required this.categoryChipPadding,
    required this.cartItemHeight,
    required this.cartItemFontSize,
    required this.quantityButtonSize,
    required this.iconSizeSmall,
    required this.iconSizeMedium,
    required this.iconSizeLarge,
    required this.containerPadding,
    required this.containerBorderRadius,
  });
}

class TypographySizes {
  final double headerLarge;
  final double headerMedium;
  final double headerSmall;
  final double bodyLarge;
  final double bodyMedium;
  final double bodySmall;
  final double caption;
  final double button;

  const TypographySizes({
    required this.headerLarge,
    required this.headerMedium,
    required this.headerSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.caption,
    required this.button,
  });
}

class DialogSizes {
  final double width;
  final double height;
  final double padding;
  final double borderRadius;

  const DialogSizes({
    required this.width,
    required this.height,
    required this.padding,
    required this.borderRadius,
  });
}