import 'package:get/get.dart';

class AppSizes {
  AppSizes._();

  static double screenHeight = Get.height;
  static double screenWidth = Get.width;
  static double defaultWidth = 375;
  static double defaultHeight = 812;

  // 834 ,1194

  static getHeight(double size) => (screenHeight / defaultHeight) * size;
  static getWidth(double size) => (screenWidth / defaultWidth) * size;
  static getTextSize(double size, {double? factor = 0.5}) =>
      size + (getWidth(size) - size) * factor;

  // Input field
  static const double inputFieldRadius = 4;
  static const double spaceBtwInputFields = 16.0;

// Height
  static const double height_6 = 6;
  static const double height_12 = 12;
  static const double height_16 = 16;
  static const double height_24 = 24;
  static const double height_36 = 36;
  static const double height_48 = 48;
  static const double height_150 = 150;

  //Dimensions added by Yokesh

  static double height_30 = getHeight(30);
  static double height_40 = getHeight(40);
  static double height_60 = getHeight(60);
  static double height_70 = getHeight(70);
  static double height_75 = getHeight(75);
  static double height_80 = getHeight(80);
  static double height_220 = getHeight(220);
  static double height_320 = getHeight(320);
  static double height_420 = getHeight(420);

  static double width_12 = getWidth(12);
  static double width_16 = getWidth(16);
  static double width_30 = getWidth(30);
  static double width_32 = getWidth(32);

  static double width_40 = getWidth(40);
  static double width_48 = getWidth(48);
  static double width_60 = getWidth(60);
  static double width_80 = getWidth(80);
  static double width_72 = getWidth(72);

  static double width_90 = getWidth(90);
  static double width_120 = getWidth(120);

  static double width_100 = getWidth(100);
  static double width_160 = getWidth(160);
// ------------------------------------------------
  static double width_04 = getWidth(4);
  static double width_06 = getWidth(6);
  static double width_08 = getWidth(8);

  static const double width_24 = 24;
  static const double width_96 = 96;

  static const double size_04 = 4;
  static const double size_06 = 6;
  static const double size_08 = 8;
  static const double size_10 = 10;
  static const double size_12 = 12;
  static const double size_14 = 14;
  static const double size_16 = 16;
  static const double size_18 = 18;
  static const double size_20 = 20;
  static const double size_22 = 22;
  static const double size_24 = 24;
  static const double size_26 = 26;
  static const double size_32 = 32;
  static const double size_48 = 48;

  static const double size_56 = 56;
}
