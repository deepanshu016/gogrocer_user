import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/global.dart' as global;

class BusinessRule {
  APIHelper? dbHelper;

  BusinessRule(APIHelper? dbHelper) {
    dbHelper = dbHelper;
  }

  Future<bool> checkConnectivity() async {
    try {
      bool isConnected;
      var connectivity = await (Connectivity().checkConnectivity());
      if (connectivity == ConnectivityResult.mobile) {
        isConnected = true;
      } else if (connectivity == ConnectivityResult.wifi) {
        isConnected = true;
      } else {
        isConnected = false;
      }

      if (isConnected) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            isConnected = true;
          }
        } on SocketException catch (_) {
          isConnected = false;
        }
      }

      return isConnected;
    } catch (e) {
      debugPrint('Exception - business_rule.dart - checkConnectivity(): $e');
    }
    return false;
  }

  int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  String getCleanedNumber(String text) {
    RegExp regExp = RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  List<int> getExpiryDate(String value) {
    var split = value.split(RegExp(r'(\/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  getSharedPreferences() async {
    try {
      global.sp = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint("Exception - business_rule.dart - _saveUser():$e");
    }
  }

  bool hasDateExpired(int month, int year) {
    return isNotExpired(year, month);
  }

  bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) || convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's
    // year
    return fourDigitsYear < now.year;
  }

  inviteFriendShareMessage({int? callId}) {
    try {
      if (callId == 0) {
        Share.share('Hi! Use my refer code ${global.currentUser!.referralCode} to signup in ${global.appInfo!.appName} app. You will get some wallet points on successfull sign up. \nAndroid Play Store link - ${global.appInfo!.androidAppLink} \nIOS App store link - ${global.appInfo!.iosAppLink}');
      } else {
        Share.share(global.appShareMessage.replaceAll("[CODE]", "${global.currentUser!.referralCode}"));
      }
    } catch (e) {
      debugPrint("Exception -  business_rule.dart - inviteFriendShareMessage():$e");
    }
  }

  bool isNotExpired(int year, int month) {
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  Future<XFile?> openCamera() async {
    try {
      PermissionStatus permissionStatus = await Permission.camera.status;
      if (permissionStatus.isLimited || permissionStatus.isDenied) {
        permissionStatus = await Permission.camera.request();
      }
      XFile? selectedImage = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 1200, maxWidth: 1200);
      if(selectedImage != null) {
        File imageFile = File(selectedImage.path);
        CroppedFile? finalImage = await _cropImage(imageFile.path);
        if(finalImage != null) {
          XFile? compressedImage = await _imageCompress(finalImage, imageFile.path);

          debugPrint("_byteData path ${compressedImage?.path}");
          return compressedImage;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Exception - business_rule.dart - openCamera():$e");
    }
    return null;
  }

  Future<XFile?> selectImageFromGallery() async {
    try {
      PermissionStatus permissionStatus = await Permission.photos.status;
      if (permissionStatus.isLimited || permissionStatus.isDenied) {
        permissionStatus = await Permission.photos.request();
      }
      File imageFile;
      XFile? selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(selectedImage != null) {
        imageFile = File(selectedImage.path);
        CroppedFile? byteData = await _cropImage(imageFile.path);
        if(byteData != null) {
          XFile? compressedImage = await _imageCompress(byteData, imageFile.path);
          return compressedImage;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Exception - business_rule.dart - selectImageFromGallery()$e");
    }
    return null;
  }

  String? timeString(DateTime time) {
    String? finalString;
    try {
      finalString = '${DateTime.now().difference(time).inMinutes}m ago';
      if (DateTime.now().difference(time).inMinutes == 0) {
        finalString = 'now';
      }
      if (DateTime.now().difference(time).inMinutes >= 60) {
        finalString = '${DateTime.now().difference(time).inHours}h ago';
      }
      if (DateTime.now().difference(time).inHours > 23) {
        finalString = '${DateTime.now().difference(time).inDays}day ago';
      }

      return finalString;
    } catch (e) {
      debugPrint("Exception - business_rule.dart - timeString():$e");
      return finalString;
    }
  }

  Future<CroppedFile?> _cropImage(String sourcePath) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            initAspectRatio: CropAspectRatioPreset.original,
            backgroundColor: Colors.white,
            toolbarColor: Colors.black,
            dimmedLayerColor: Colors.white,
            toolbarWidgetColor: Colors.white,
            cropGridColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF46A9FC),
            cropFrameColor: const Color(0xFF46A9FC),
            lockAspectRatio: true,
          ),
        ]
      );

      return croppedFile;
    } catch (e) {
      debugPrint("Exception - business_rule.dart - _cropImage():$e");
    }
    return null;
  }

  Future<XFile?> _imageCompress(CroppedFile file, String targetPath) async {
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minHeight: 1200,
        minWidth: 1200,
        quality: 50,
      );
   

      return result;
    } catch (e) {
      debugPrint("Exception - business_rule.dart - _cropImage():$e");
      return null;
    }
  }
}
