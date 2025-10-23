import 'package:babershop_project/App/Modules/barber_staff_selection/barber_staff_selection.dart';
import 'package:babershop_project/App/Modules/login_page/login_screen.dart';
import 'package:babershop_project/App/Modules/splash_Screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  // 🔹 Define route names as constants
  static const String splash = '/splash';
  static const String login = '/login';
  static const String barberSelection = '/barberSelection';
  static replace({String? name, dynamic arg}) {
    Get.offNamed(name ?? barberSelection, arguments: arg);
  }
  // 🔹 Register all pages here
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: LoginBinding(), // ✅ keep only if LoginBinding exists
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: barberSelection,
      page: () => const BarberSelectionPage(),
      // ❌ don't use 'binding: BarberSelectionPage()' unless it’s a Binding class
      transition: Transition.rightToLeft,
    ),
  ];
}
