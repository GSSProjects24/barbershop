class ApiConfig {
  static late String apiBaseUrl;

  static void initialize() {
    apiBaseUrl = "https://yourapi.com/api/";


  }
  static const String ipay88PaymentStatusId = 'armd_ipay88_payment_status';
  static const Duration receiveTimeout = Duration(milliseconds: 10000);
  static const Duration connectionTimeout = Duration(milliseconds: 10000);
}
class AppConfig {
  AppConfig._();
  static const String appID = 'com.app.sreeselvavinayagartemple';
  static const bool canLog = true;
  static const String ENV_MODE = PROD;
  static const String DEV = "dev";
  static const String PROD = "prod";
  static const String appName = "SSV";
  static const String currency = "RM";
  static const String mobileCode = "+60";
  static const String appTitle = "ARMD";
  static const String templeNmaeTamil = 'ஸ்ரீ செல்வ விநாயகர் ஆலயம்';
  static const String templeNmaeEng = 'SREE SELVA VINAYAGAR TEMPLE';
  static const String templeRegistration = '1498/74(PPM - 001 - 10 24091974)';

  static const String CUSTOMER_ID = 'customer_id';
  static const String CUSTOMER_DATA = 'customer_data';
  static const String FIRST_TIME_LAUNCH = 'firstTimeLaunch';
  static const String booking_through = 'APP';
  static const String payment_type = 'full';
  static const String payment_mode = 'ipay_online';

  static const String ANDROID_VERSION_CODE = "1.0.25";
  static const andoidBuild = 27;

  static const String IOS_VERSION_CODE = "1.0.15";
  static const iOSBuild = 1;

  static const String PLAYSTORE_URL =
      'https://play.google.com/store/apps/details?id=com.app.sreeselvavinayagartemple';
  static const String APPSTORE_URL =
      "https://apps.apple.com/us/app/sree-selva-vinayagar-temple/id6497653403";

  // Languages

}