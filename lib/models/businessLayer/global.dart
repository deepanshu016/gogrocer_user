import 'dart:convert';
import 'dart:ui';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/controllers/user_profile_controller.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/app_info_model.dart';
import 'package:user/models/app_notice_model.dart';
import 'package:user/models/google_map_model.dart';
import 'package:user/models/local_notification_model.dart';
import 'package:user/models/mapbox_model.dart';
import 'package:user/models/map_by_model.dart';
import 'package:user/models/nearby_store_model.dart';
import 'package:user/models/payment_gateway_model.dart';
import 'package:user/models/user_model.dart';

List<Address> addressList = [];
// APIHelper apiHelper;
String? appDeviceId;
AppInfo? appInfo = AppInfo();
AppNotice? appNotice = AppNotice();
String appName = 'Go Grocer';
String appShareMessage =
    "I'm inviting you to use $appName, a simple and easy app to find all required products near by your location. Here's my code [CODE] - just enter it while registration.";
String appVersion = '1.0';
String baseUrl = 'https://gogrocer.tecmanic.com/api/';
int cartCount = 0;
List<Color> colorList = [
  const Color(0xFF4DD0E1),
  const Color(0xFFAB47BC),
];
String? currentLocation;
CurrentUser? currentUser = CurrentUser();
String defaultImage = 'assets/images/icon.png';
GoogleMapModel? googleMap;
String imageUploadMessageKey = 'w0daAWDk81';
bool isChatNotTapped = false;
String? languageCode = 'en';
double? lat;
double? lng;
bool isRTL = false;
List<String> rtlLanguageCodeLList = [
  'ar',
  'arc',
  'ckb',
  'dv',
  'fa',
  'ha',
  'he',
  'khw',
  'ks',
  'ps',
  'ur',
  'uz_AF',
  'yi'
];
LocalNotification localNotificationModel = LocalNotification();
String? locationMessage = '';
MapBoxModel? mapBox;
NearStoreModel? nearStoreModel = NearStoreModel();
PaymentGateway? paymentGateway = PaymentGateway();
String? selectedImage;
SharedPreferences? sp;
bool isNavigate = false;
String stripeBaseApi = 'https://api.stripe.com/v1';
var orderApiRazorpay = Uri.parse('https://api.razorpay.com/v1/orders');
final UserProfileController userProfileController =
    Get.put(UserProfileController());
Mapby? mapby;

Future<Map<String, String>> getApiHeaders(bool authorizationRequired) async {
  Map<String, String> apiHeader = <String, String>{};
  if (authorizationRequired) {
    sp = await SharedPreferences.getInstance();
    if (sp!.getString("currentUser") != null) {
      CurrentUser currentUser =
          CurrentUser.fromJson(json.decode(sp!.getString("currentUser")!));
      apiHeader.addAll({"Authorization": "Bearer ${currentUser.token!}"});
    }
  }
  apiHeader.addAll({"Content-Type": "application/json"});
  apiHeader.addAll({"Accept": "application/json"});
  return apiHeader;
}
