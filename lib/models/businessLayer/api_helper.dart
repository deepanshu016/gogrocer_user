import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:user/models/about_us_model.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/app_info_model.dart';
import 'package:user/models/app_notice_model.dart';
import 'package:user/models/app_setting_model.dart';
import 'package:user/models/businessLayer/dio_result.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/cancel_reason_model.dart';
import 'package:user/models/cart_model.dart';
import 'package:user/models/category_filter.dart';
import 'package:user/models/category_list_model.dart';
import 'package:user/models/category_product_model.dart';
import 'package:user/models/city_model.dart';
import 'package:user/models/coupons_model.dart';
import 'package:user/models/google_map_model.dart';
import 'package:user/models/home_screen_data_model.dart';
import 'package:user/models/mapbox_model.dart';
import 'package:user/models/map_by_model.dart';
import 'package:user/models/membership_model.dart';
import 'package:user/models/membership_status_model.dart';
import 'package:user/models/message_model.dart';
import 'package:user/models/nearby_store_model.dart';
import 'package:user/models/notification_model.dart';
import 'package:user/models/order_model.dart' as models;
import 'package:user/models/payment_gateway_model.dart';
import 'package:user/models/product_detail_model.dart';
import 'package:user/models/product_filter_model.dart';
import 'package:user/models/rate_model.dart';
import 'package:user/models/recent_search_model.dart';
import 'package:user/models/society_model.dart';
import 'package:user/models/store_model.dart';
import 'package:user/models/subcategory_model.dart';
import 'package:user/models/terms_of_services_model.dart';
import 'package:user/models/time_slot_model.dart';
import 'package:user/models/user_model.dart';
import 'package:user/models/wallet_model.dart';
import 'package:user/utils/stream_formatter.dart';
import 'package:http/http.dart' as http;

class APIHelper {
  static final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  CollectionReference userChatCollectionRef = FirebaseFirestore.instance.collection("chats");
  CollectionReference storeCollectionRef = FirebaseFirestore.instance.collection("store");

  String? url;

  Future<dynamic> addAddress(Address address) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'type': address.type, 'receiver_name': address.receiverName, 'receiver_phone': address.receiverPhone, 'city_name': address.city, 'society_name': address.society, 'house_no': address.houseNo, 'landmark': address.landmark, 'state': address.state, 'pin': address.pincode, 'lat': address.lat, 'lng': address.lng});

      response = await dio.post('${global.baseUrl}add_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      debugPrint(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - addAddress(): $e");
    }
  }

  Future<dynamic> addProductRating(int? varientId, double rating, String description) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'varient_id': varientId,
        'store_id': global.nearStoreModel!.id,
        'rating': rating,
        'description': description,
      });
      response = await dio.post('${global.baseUrl}add_product_rating',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - addProductRating(): $e");
    }
  }

  Future<dynamic> addRemoveWishList(int? varientId) async {
    try {
      // Add product to wishlist and remove from wishlist same API no need to pass any flag logic is handled from backend
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'varient_id': varientId, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}add_rem_wishlist',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - addRemoveWishList(): $e");
    }
  }

  Future<dynamic> addToCart({int? qty, int? varientId, int? special}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'qty': qty,
        'store_id': global.nearStoreModel!.id,
        'varient_id': varientId,
        'special': special,
      });

      response = await dio.post('${global.baseUrl}add_to_cart',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = Cart.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - addToCart(): $e");
    }
  }

  Future<dynamic> addWishListToCart() async {
    try {
      // Add all the  product from wishlist to cart
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}wishlist_to_cart',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - addWishListToCart(): $e");
    }
  }

  Future<dynamic> appAboutUs() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}appaboutus',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = AboutUs.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - appAboutUs(): $e");
    }
  }

  Future<dynamic> applyCoupon({String? cartId, String? couponCode}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'cart_id': cartId, 'coupon_code': couponCode});

      response = await dio.post('${global.baseUrl}apply_coupon',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      debugPrint('12');
      debugPrint(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - applyCoupon(): $e");
    }
  }

  Future<dynamic> appTermsOfService() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}appterms',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = TermsOfService.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - appTermsOfService(): $e");
    }
  }

  Future<dynamic> barcodeScanResult(String code) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'ean_code': code, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}search',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = ProductDetail.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - barcodeScanResult(): $e");
    }
  }

  Future<dynamic> buyMembership(String buyStatus, String paymentGateway, String? transactionId, int? planId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'buy_status': buyStatus,
        'payment_gateway': paymentGateway,
        'transaction_id': transactionId,
        'plan_id': planId,
      });

      response = await dio.post('${global.baseUrl}buymember',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - buyMembership(): $e");
    }
  }

  Future<dynamic> calbackRequest(String? storeId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': storeId});
      response = await dio.post('${global.baseUrl}callback_req',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - calbackRequest(): $e");
    }
  }

  Future<bool> callOnFcmApiSendPushNotifications({List<String?>? userToken, String? title, String? body, String? route, String? imageUrl, String? chatId, String? firstName, String? lastName, String? storeId, String? userId, String? globalUserToken}) async {
    final data = {
      "registration_ids": userToken,
      "notification": {
        "title": '$title',
        "body": '$body',
        "sound": "default",
        "color": "#ff3296fa",
        "vibrate": "300",
        "priority": 'high',
      },
      "android": {
        "priority": 'high',
        "notification": {
          "sound": 'default',
          "color": '#ff3296fa',
          "clickAction": 'FLUTTER_NOTIFICATION_CLICK',
          "notificationType": '52',
        },
      },
      "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "storeId": '$storeId', "route": '$route', "imageUrl": '$imageUrl', "chatId": '$chatId', "firstName": '$firstName', "lastName": '$lastName', "userId": '$userId', "userToken": globalUserToken}
    };
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=${global.appInfo!.userServerKey}' // 'key=YOUR_SERVER_KEY'
    };
    final response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'), body: json.encode(data), encoding: Encoding.getByName('utf-8'), headers: headers);
    if (response.statusCode == 200) {
      // on success do sth
      debugPrint('Send');
      return true;
    } else {
      debugPrint('Error');
      // on failure do sth
      return false;
    }
  }

  Future<dynamic> changePassword(String? phoneNumber, String password) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phoneNumber, 'user_password': password});
      response = await dio.post('${global.baseUrl}change_password',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - changePassword(): $e");
    }
  }

  Future<dynamic> checkout({String? cartId, String? paymentStatus, String? paymentMethod, String? wallet, String? paymentId, String? paymentGateway}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'cart_id': cartId, 'payment_method': paymentMethod, 'payment_status': paymentStatus, 'wallet': wallet, 'payment_id': paymentId, 'payment_gateway': paymentGateway});

      response = await dio.post('${global.baseUrl}checkout',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if ((response.statusCode == 200 && response.data["status"] == '1') || (response.statusCode == 200 && response.data["status"] == '2')) {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - checkout(): $e");
    }
  }

  Future<EmailExist> checkStoreExist(int? storeId, int? userId) async {
    EmailExist isExist = EmailExist();
    try {
      dynamic storeData;
      ChatStore? chatStore = ChatStore();
      storeData = await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: storeId).where('userId', isEqualTo: userId).limit(1).snapshots().transform(StreamFormatter.transformer(ChatStore.fromJson)).first;
      chatStore = storeData.isNotEmpty ? storeData[0] : null;
      if (chatStore != null && chatStore.chatId != null) {
        isExist = EmailExist(id: chatStore.chatId, isEMailExist: true);
      } else {
        storeData = await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: userId.toString()).where('userId', isEqualTo: storeId.toString()).limit(1).snapshots().transform(StreamFormatter.transformer(ChatStore.fromJson)).first;
        chatStore = storeData.isNotEmpty ? storeData[0] : null;
        if (chatStore != null && chatStore.chatId != null) {
          isExist = EmailExist(id: chatStore.chatId, isEMailExist: true);
        } else {
          String chatId = '${userId}_$storeId';

          chatStore = ChatStore(chatId: chatId, createdAt: DateTime.now(), storeId: storeId, userId: userId, name: global.currentUser!.name, userProfileImageUrl: global.currentUser!.userImage, userFcmToken: await FirebaseMessaging.instance.getToken());

          //add store
          try {
            await storeCollectionRef.add(chatStore.toJson());
          } catch(e) {
            debugPrint('Create store exception$e');
          }
          isExist = EmailExist(id: chatId, isEMailExist: false);
        }
      }
    } catch (err) {
      debugPrint("Exception - checkStoreExist(): $err");
    }
    return isExist;
  }

  Future<dynamic> deleteAllNotification() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}delete_all_notification',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - deleteAllNotification(): $e");
    }
  }

  Future<dynamic> deleteOrder(String? cartId, String? cancelReason) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'cart_id': cartId,
        'reason': cancelReason,
      });

      response = await dio.post('${global.baseUrl}delete_order',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = response;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - deleteOrder(): $e");
    }
  }

  Future<dynamic> delFromCart({int? varientId}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'varient_id': varientId,
      });

      response = await dio.post('${global.baseUrl}del_frm_cart',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = Cart.fromJson(response.data);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - delFromCart(): $e");
    }
  }

  Future<dynamic> editAddress(Address address) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'address_id': address.addressId, 'user_id': global.currentUser!.id, 'type': address.type, 'receiver_name': address.receiverName, 'receiver_phone': address.receiverPhone, 'city_name': address.city, 'society_name': address.society, 'house_no': address.houseNo, 'landmark': address.landmark, 'state': address.state, 'pin': address.pincode, 'lat': address.lat, 'lng': address.lng});

      response = await dio.post('${global.baseUrl}edit_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - editAddress(): $e");
    }
  }

  Future<dynamic> firebaseOTPVerification(String? phone, String? status) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phone, 'status': status});
      response = await dio.post('${global.baseUrl}verifyOtpPassfirebase',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'].toString() == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - firebaseOTPVerification(): $e");
    }
  }

  Future<dynamic> forgotPassword(String userPhone) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': userPhone});
      response = await dio.post('${global.baseUrl}forget_password',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - forgotPassword(): $e");
    }
  }

  Future<dynamic> getActiveOrders(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}my_orders?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<models.Order>.from(response.data["data"].map((x) => models.Order.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getOrderHistory(): $e");
    }
  }

  Future<dynamic> getAddressList() async {
    debugPrint('${global.currentUser!.id}');
    debugPrint('${global.nearStoreModel!.id}');
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}show_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      debugPrint(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Address>.from(response.data["data"].map((x) => Address.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getAddressList(): $e");
    }
  }

  Future<dynamic> getAllNotification(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}notificationlist?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<NotificationModel>.from(response.data["data"].map((x) => NotificationModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getAllNotification(): $e");
    }
  }

  Future<dynamic> getAppInfo([int? userId]) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': userId});
      response = await dio.post('${global.baseUrl}app_info',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      debugPrint(response.data.toString());
      if (response.statusCode == 200) {
        recordList = await Isolate.run(() async {
          return AppInfo.fromJson(response.data);
        });
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getAppInfo(): $e");
    }
  }

  Future<dynamic> getAppNotice() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}app_notice',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = AppNotice.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getAppNotice(): $e");
    }
  }

  Future<dynamic> getAppSetting() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}appsetting',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = AppSetting.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - appSetting(): $e");
    }
  }

  Future<dynamic> getBannerProductDetail(int? varientId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'varient_id': varientId,
        'store_id': global.nearStoreModel!.id,
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}banner_var',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = ProductDetail.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getBannerProductDetail(): $e");
    }
  }

  Future<dynamic> getCancelReason() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}cancelling_reasons',
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<CancelReason>.from(response.data["data"].map((x) => CancelReason.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getCancelReason(): $e");
    }
  }

  Future<dynamic> getCategoryList(CategoryFilter categoryFilter, int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'byname': categoryFilter.byname,
        'latest': categoryFilter.latest,
      });

      response = await dio.post('${global.baseUrl}catee?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<CategoryList>.from(response.data["data"].map((x) => CategoryList.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getCategoryList(): $e");
    }
  }

  Future<dynamic> getCategoryProducts(int? catId, int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'cat_id': catId,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}cat_product?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getCategoryProducts(): $e");
    }
  }

  Stream<List<MessagesModel>>? getChatMessages(String? idUser, String globalId) {
    try {
      return FirebaseFirestore.instance.collection('chats/$idUser/userschat').doc(globalId).collection('messages').orderBy("createdAt", descending: true).snapshots().transform(StreamFormatter.transformer(MessagesModel.fromJson));
    } catch (err) {
      debugPrint("Exception - api_helper.dart - getChatMessages()$err");
      return null;
    }
  }

  Future<dynamic> getCity() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}city',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<City>.from(response.data["data"].map((x) => City.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getCity(): $e");
    }
  }

  Future<dynamic> getCompletedOrders(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}completed_orders?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<models.Order>.from(response.data["data"].map((x) => models.Order.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getCompletedOrders(): $e");
    }
  }

  Future<dynamic> getCoupons({String? cartId}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'cart_id': cartId});
      response = await dio.post('${global.baseUrl}couponlist',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Coupon>.from(response.data["data"].map((x) => Coupon.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getStoreCoupons(): $e");
    }
  }

  Future<dynamic> getDealProducts(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}dealproduct?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getDealProducts(): $e");
    }
  }

  dynamic getDioResult<T>(final response, T recordList) {
    try {
      dynamic result;
      result = DioResult.fromJson(response, recordList);
      return result;
    } catch (e) {
      debugPrint("Exception - getDioResult():$e");
    }
  }

  Future<dynamic> getGoogleMapApiKey() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}google_map',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = GoogleMapModel.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getGoogleMapApiKey(): $e");
    }
  }

  Future<dynamic> getHomeScreenData() async {
    try {
      debugPrint('Near by store id: ${global.nearStoreModel?.id}');
      debugPrint('Current user id: ${global.currentUser?.id}');
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel?.id,
        'user_id': global.currentUser?.id,
      });
      response = await dio.post('${global.baseUrl}oneapi',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = await Isolate.run(() async {
          return HomeScreenData.fromJson(response.data);
        });
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getHomeScreenData(): $e");
    }
  }

  Future<dynamic> getMapBoxApiKey() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}mapbox',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = MapBoxModel.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getMapBoxApiKey(): $e");
    }
  }

  Future<dynamic> getMapByFlag() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}mapby',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = Mapby.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getMapByFlag(): $e");
    }
  }

  Future<dynamic> getMembershipList() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}membership_plan',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      debugPrint(response.data);
      if (response.statusCode == 200) {
        recordList = List<MembershipModel>.from(response.data["data"].map((x) => MembershipModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getMembershipList(): $e");
    }
  }

  Future<dynamic> getNearbyStore() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'lat': global.lat, 'lng': global.lng});
      response = await dio.post('${global.baseUrl}getneareststore',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      debugPrint(response.data.toString());
      if (response.statusCode == 200 && '${response.data['status']}' == '1') {
        recordList = NearStoreModel.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getNearbyStore(): $e");
    }
  }

  Future<dynamic> getPaymentGateways() async {
    try {
      Response response;
      var dio = Dio();
      response = await dio.get('${global.baseUrl}payment_gateways',
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      debugPrint(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status']!=null) {
        recordList = PaymentGateway.fromJson(response.data);
      } else {
        response.data['status'] = '0';
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getPaymentGateways(): $e");
    }
  }

  Future<dynamic> getProductDetail(int? productId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'product_id': productId, 'store_id': global.nearStoreModel!.id});

      response = await dio.post('${global.baseUrl}product_det',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = ProductDetail.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getProductDetail(): $e");
    }
  }

  Future<dynamic> getproductSearchResult(String? keyWord, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id, 'keyword': keyWord, 'user_id': global.currentUser!.id, 'byname': productFilter.byname, 'min_price': productFilter.minPrice, 'max_price': productFilter.maxPrice, 'stock': productFilter.stock, 'min_discount': productFilter.minDiscount, 'max_discount': productFilter.maxDiscount, 'min_rating': productFilter.minRating, 'max_rating': productFilter.maxRating});

      response = await dio.post('${global.baseUrl}searchbystore',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getproductSearchResult(): $e");
    }
  }

  Future<dynamic> getSociety(int? cityId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'city_id': cityId});
      response = await dio.post('${global.baseUrl}society',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Society>.from(response.data["data"].map((x) => Society.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getSociety(): $e");
    }
  }

  Future<dynamic> getSocietyForAddress() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}societyforaddress',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Society>.from(response.data["data"].map((x) => Society.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getSocietyForAddress(): $e");
    }
  }

  Future<dynamic> getStoreCoupons() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}storecoupons',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Coupon>.from(response.data["data"].map((x) => Coupon.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getStoreCoupons(): $e");
    }
  }

  Future<dynamic> getSubCategory(int page, int? catId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id, 'cat_id': catId});

      response = await dio.post('${global.baseUrl}subcatee?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<SubCategory>.from(response.data["data"].map((x) => SubCategory.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getSubCategory(): $e");
    }
  }

  Future<dynamic> getTagProducts(String? tagName, int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'tag_name': tagName,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}tag_product?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - tagProducts(): $e");
    }
  }

  Future<dynamic> getTimeSlot(DateTime? selectedDate) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id, 'selected_date': selectedDate});

      response = await dio.post('${global.baseUrl}timeslot',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          )).timeout(const Duration(seconds: 60));
      dynamic recordList;
      debugPrint(response.data);
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<TimeSlot>.from(response.data["data"].map((x) => TimeSlot.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getTimeSlot(): $e");
    }
  }

  Future<dynamic> getTopSellingProducts(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}top_selling?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getTopSellingProducts(): $e");
    }
  }

  getWalletRechargeHistory(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        "user_id": global.currentUser!.id,
      });
      response = await dio.post('${global.baseUrl}wallet_recharge_history?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Wallet>.from(response.data["data"].map((x) => Wallet.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getWalletRechargeHistory(): $e");
    }
  }

  getWalletSpentHistory(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        "user_id": global.currentUser!.id,
      });
      response = await dio.post('${global.baseUrl}paid_by_wallet?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Wallet>.from(response.data["data"].map((x) => Wallet.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getWalletSpentHistory(): $e");
    }
  }

  getWishListProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}show_wishlist?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getWishListProduct(): $e");
    }
  }

  Future<dynamic> login(String userPhone) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': userPhone});
      response = await dio.post('${global.baseUrl}login',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - login(): $e");
    }
  }

  Future<dynamic> loginWithEmail(String email, String password) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'email': email, 'password': password, 'device_id': global.appDeviceId});
      response = await dio.post('${global.baseUrl}login_with_email',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data['token'];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - loginWithEmail(): $e");
    }
  }

  Future<dynamic> makeOrder({DateTime? selectedDate, String? selectedTime}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'delivery_date': selectedDate, 'time_slot': selectedTime});

      response = await dio.post('${global.baseUrl}make_order',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - makeOrder(): $e");
    }
  }

  Future<dynamic> makeProductRequest(int? addressId, File? imageFile) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'store_id': global.nearStoreModel!.id,
        'address_id': addressId,
        'orderlist': imageFile != null ? await MultipartFile.fromFile(imageFile.path.toString()) : null,
      });

      response = await dio.post('${global.baseUrl}orderlist',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = response;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - makeProductRequest(): $e");
    }
  }

  Future<dynamic> membershipStatus() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}membership_status',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = MembershipStatus.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - membershipStatus(): $e");
    }
  }

  Future<dynamic> myProfile() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}myprofile',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - myProfile(): $e");
    }
  }

  recentSellingProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}recentselling?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - recentSellingProduct(): $e");
    }
  }

  Future<dynamic> rechargeWallet(String rechargeStatus, double amount, String? paymentId, String paymentGateway) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'recharge_status': rechargeStatus,
        'amount': amount.toStringAsFixed(2),
        'payment_id': paymentId,
        'payment_gateway': paymentGateway,
      });

      response = await dio.post('${global.baseUrl}recharge_wallet',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if ((response.statusCode == 200 && response.data["status"] == '1')) {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - rechargeWallet(): $e");
    }
  }

  Future<dynamic> redeemReward() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});

      response = await dio.post('${global.baseUrl}redeem_rewards',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - redeemReward(): $e");
    }
  }

  Future<dynamic> removeAddress(int? addressId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'address_id': addressId,
      });

      response = await dio.post('${global.baseUrl}remove_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - removeAddress(): $e");
    }
  }

  Future<dynamic> reOrder(String? cartId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'cart_id': cartId});

      response = await dio.post('${global.baseUrl}reorder',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = Cart.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - reOrder(): $e");
    }
  }

  Future<dynamic> resendOTP(String? userPhone) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': userPhone});
      response = await dio.post('${global.baseUrl}resendotp',
          queryParameters: {
            'lang': 'en',
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - resendOTP(): $e");
    }
  }

  Future<dynamic> selectAddressForCheckout(int? addressId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'address_id': addressId});

      response = await dio.post('${global.baseUrl}select_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = response.data;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - selectAddressForCheckout(): $e");
    }
  }

  Future<dynamic> sendUserFeedback(String feedback) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'feedback': feedback});
      response = await dio.post('${global.baseUrl}user_feedback',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - calbackRequest(): $e");
    }
  }

  Future<dynamic> showCart() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}show_cart',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          )).timeout(const Duration(seconds: 60));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = Cart.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - showCart(): $e");
    }
  }

  Future<dynamic> showRecentSearch() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}recent_search',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<RecentSearch>.from(response.data["data"].map((x) => RecentSearch.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - showRecentSearch(): $e");
    }
  }

  Future<dynamic> showTrendingSearchProducts() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
      });

      response = await dio.post('${global.baseUrl}trendsearchproducts',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - showRecentSearch(): $e");
    }
  }

  Future<dynamic> signUp(CurrentUser user) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'name': user.name,
        'user_email': user.email,
        'user_phone': user.userPhone,
        'password': user.password,
        'user_city': user.userCity,
        'user_area': user.userArea,
        'device_id': global.appDeviceId,
        'user_image': user.userImageFile != null ? await MultipartFile.fromFile(user.userImageFile!.path.toString()) : null,
        'fb_id': user.fbId,
        'referral_code': user.referralCode,
        'apple_id': user.appleId,
      });

      response = await dio.post('${global.baseUrl}register_details',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      debugPrint(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - signUp(): $e");
    }
  }

  Future<dynamic> socialLogin({String? userEmail, String? facebookId, String? type, String? appleId}) async {
    debugPrint(userEmail);
    debugPrint(facebookId);
    // debugPrint(type);
    // debugPrint(appleId);
    try {
      Response response;
      var dio = Dio();

      var formData = FormData.fromMap({"user_email": userEmail, "fb_id": facebookId, "type": type, "apple_id": appleId, 'device_id': global.appDeviceId});
      response = await dio.post('${global.baseUrl}social_login',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      // CurrentUser recordList;
      debugPrint(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data['token'];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - socialLogin(): $e");
    }
  }

  spotLightProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}spotlight?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return  getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - spotLightProduct(): $e");
    }
  }

  Future<dynamic> trackOrder(String? cartId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'cart_id': cartId});

      response = await dio.post('${global.baseUrl}trackorder',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - trackOrder(): $e");
    }
  }

  Future<dynamic> updateAppSetting(AppSetting appSetting) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'sms': appSetting.sms! ? 1 : 0,
        'email': appSetting.email! ? 1 : 0,
        'app': appSetting.app! ? 1 : 0,
      });

      response = await dio.post('${global.baseUrl}updateappsetting',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['data'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - updateAppSetting(): $e");
    }
  }

  Future updateFirebaseUser(CurrentUser? user) async {
    try {
      List<QueryDocumentSnapshot> storeData = (await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: global.nearStoreModel!.id).where('userId', isEqualTo: global.currentUser!.id).get()).docs.toList();
      if (storeData.isNotEmpty) {
        FirebaseFirestore.instance.collection("store").doc(storeData[0].id).update({"name": user!.name, "userProfileImageUrl": user.userImage, "updatedAt": DateTime.now().toUtc()});
      }
    } catch (e) {
      debugPrint("Exception - updateFirebaseUser()$e");
    }
  }

  Future updateFirebaseUserFcmToken(int? userId, String? updatedFcmToken) async {
    try {
      int? storeId = global.nearStoreModel?.id;
      List<QueryDocumentSnapshot> storeData = (await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: storeId).where('userId', isEqualTo: userId).get()).docs.toList();
      if (storeData.isNotEmpty) {
        FirebaseFirestore.instance.collection("store").doc(storeData[0].id).update({"userFcmToken": updatedFcmToken, "updatedAt": DateTime.now().toUtc()});
      }
    } catch (e) {
      debugPrint("Exception - updateFirebaseUser()$e");
    }
  }

  Future updateImageMesageURL(String? chatId, String userId, String? messageId, String url) async {
    try {
      var myDoc = FirebaseFirestore.instance
          // .collection('chats/$chatId/messages')
          .collection('chats')
          .doc(chatId)
          .collection('userschat')
          .doc(userId)
          .collection('messages')
          .doc(messageId);

      //  FirebaseFirestore.instance.collection('chats/$chatId/messages');
      myDoc.update({'url': url});
    } catch (err) {
      debugPrint('Exception - updateImageMesageURL(): ${err.toString()}');
    }
  }

  Future<dynamic> updateProfile(CurrentUser user) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_name': user.name,
        'user_email': global.currentUser!.email,
        'user_phone': global.currentUser!.userPhone,
        'user_city': user.userCity,
        'user_area': user.userArea,
        'device_id': global.appDeviceId,
        'user_image': user.userImageFile != null ? await MultipartFile.fromFile(user.userImageFile!.path.toString()) : null,
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}profile_edit',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      debugPrint(response.data);
      if (response.statusCode == 200) {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - updateProfile(): $e");
    }
  }

  Future<String?> uploadImageToStorage(XFile image, String? chatId, String userid, MessagesModel anonymous) async {
    try {
      var messageR = await uploadMessage(chatId, userid, anonymous, false, '');
      var fileName = DateTime.now().microsecondsSinceEpoch.toString();
      var refImg = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = refImg.putFile(File(image.path));
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      await updateImageMesageURL(chatId, global.currentUser!.id.toString(), messageR['user1'], imageUrl);
      await updateImageMesageURL(chatId, userid, messageR['user2'], imageUrl);

      return url;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future uploadMessage(String? idUser, String userId, MessagesModel anonymous, bool isAlreadychat, String imageUrl) async {
    try {
      final String globalId = global.currentUser!.id.toString();
      // if (!isAlreadychat && userChat.chatId != null) {}
      final refMessages = userChatCollectionRef.doc(idUser).collection('userschat').doc(globalId).collection('messages');
      final refMessages1 = userChatCollectionRef.doc(idUser).collection('userschat').doc(userId).collection('messages');
      final newMessage1 = anonymous;
      final newMessage2 = anonymous;

      try {
        var messageResult = await refMessages.add(newMessage1.toJson());
        newMessage2.isRead = false;
        var message1Result = await refMessages1.add(newMessage2.toJson());

        return {
          'user1': messageResult.id,
          'user2': message1Result.id,
        };
      } catch(e) {
        debugPrint('send mess exception$e');
      }
    } catch (err) {
      debugPrint('uploadMessage err $err');
    }
  }

  Future<dynamic> verifyOTP(String? phone, String otp) async {
    try {
      // OTP verification after forgot password
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phone, 'otp': otp});
      response = await dio.post('${global.baseUrl}verifyOtpPass',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - verifyOTP(): $e");
    }
  }

  Future<dynamic> verifyPhone(String? phone, String otp, String? referralCode) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phone, 'otp': otp, 'referral_code': referralCode, 'device_id': global.appDeviceId});
      response = await dio.post('${global.baseUrl}verify_phone',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - verifyPhone(): $e");
    }
  }

  Future<dynamic> verifyViaFirebase(String? phone, String? status, String? referralCode) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phone, 'status': status, 'referral_code': referralCode, 'device_id': global.appDeviceId});
      response = await dio.post('${global.baseUrl}verify_via_firebase',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"].toString() == "1") {
        recordList = CurrentUser.fromJson(response.data["data"]);

        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - verifyViaFirebase(): $e");
    }
  }

  whatsnewProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}whatsnew?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - whatsnewProduct(): $e");
    }
  }
  Future<dynamic> getProductRating(int page, int? varientId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'varient_id': varientId,
      });
      response = await dio.post('${global.baseUrl}get_product_rating?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Rate>.from(response.data["data"].map((x) => Rate.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      debugPrint("Exception - getProductRating(): $e");
    }
  }

}

class EmailExist {
  String? id;
  bool? isEMailExist;
  EmailExist({this.id, this.isEMailExist});
}
