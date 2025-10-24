import 'package:babershop_project/App/config/app_config.dart';
import 'package:babershop_project/App/helper/route_hepler.dart';
import 'package:babershop_project/App/provider/sharedprefference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize SharedPreferences BEFORE running the app
  // ✅ Initialize SharedPrefService
  await SharedPrefService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: Get.key,
      //title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.lightTheme,
      // locale: localizeController.locale,
      // translations: Messages(languages: languages),
      // fallbackLocale: Locale(
      //   AppConfig.languages[0].languageCode!,
      //   AppConfig.languages[0].countryCode,
      // ),
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
      getPages: RouteHelper.routes,
      initialRoute: '/splash',
      home: UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: Duration(milliseconds: 10),
          debugLogging: true,
        ),

      ),
    );
  }
}

