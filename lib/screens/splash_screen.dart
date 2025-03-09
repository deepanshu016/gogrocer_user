import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/models.dart';
import 'package:user/screens/screens.dart';

class SplashScreen extends BaseRoute {
  const SplashScreen({super.key, super.analytics, super.observer, super.routeName = 'SplashScreen'});

  @override
  BaseRouteState createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseRouteState {
  bool isLoading = true;

  GlobalKey<ScaffoldState>? _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          // padding: EdgeInsets.all(32),
          child: Image.asset(
            'assets/images/icon.png',
            fit: BoxFit.contain,
            scale: 3,
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _init();
  }

  _getAppInfo() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        final result = await apiHelper.getAppInfo();
        if (result != null) {
          if (result.status == "1") {
            global.appInfo = result.data;
          } else {
            hideLoader();
            showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
          }
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - splash_screen.dart - _getAppInfo():$e");
    }
  }

  _getAppNotice() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        final result = await apiHelper.getAppNotice();
        if (result != null) {
          if (result.status == "1") {
            global.appNotice = result.data;
          }
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - splash_screen.dart - _getAppNotice():$e");
    }
  }

  _getGoogleMapApiKey() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        final result = await apiHelper.getGoogleMapApiKey();
        if (result != null) {
          if (result.status == "1") {
            global.googleMap = result.data;
          } else {
            hideLoader();
            global.googleMap = null;
          }
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - splash_screen.dart - _getGoogleMapApiKey():$e");
    }
  }

  _getMapBoxApiKey() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        final result = await apiHelper.getMapBoxApiKey();
        if (result != null) {
          if (result.status == "1") {
            global.mapBox = result.data;

            setState(() {});
          }
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - splash_screen.dart - _getMapBoxApiKey():$e");
    }
  }

  _getMapByFlag() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        final result = await apiHelper.getMapByFlag();
        if (result != null) {
          if (result.status == "1") {
            global.mapby = result.data;
          } else {
            hideLoader();
            global.mapby = null;
          }
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - splash_screen.dart - _getMapByFlag():$e");
    }
  }

  void _init() async {
    await br.getSharedPreferences();
    final List<dynamic> _ = await Future.wait([
      _getAppInfo(),
      _getMapByFlag(),
      _getGoogleMapApiKey(),
      _getMapBoxApiKey(),
      _getAppNotice(),
    ]);

    global.appDeviceId = await FirebaseMessaging.instance.getToken();

    if (global.sp?.getString('currentUser') == null) {
      PermissionStatus permissionStatus = await Permission.phone.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.phone.request();
      }
    }

    bool isConnected = await br.checkConnectivity();

    if (isConnected) {
      if (global.sp?.getString('currentUser') != null) {
        global.currentUser = CurrentUser.fromJson(json.decode(global.sp!.getString("currentUser")!));
        if (global.sp?.getString('lastloc') != null) {
          List<String> tlist = global.sp!.getString('lastloc')!.split("|");
          global.lat = double.parse(tlist[0]);
          global.lng = double.parse(tlist[1]);
          final List<dynamic> _ = await Future.wait([
            getAddressFromLatLng(),
            getNearByStore(),
          ]);
          if(!mounted) return;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeScreen(
                analytics: widget.analytics,
                observer: widget.observer,
              )));
        } else {
          if(!mounted) return;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeScreen(
                analytics: widget.analytics,
                observer: widget.observer,
              )));
        }
      } else {
        Get.to(() => IntroScreen(
          analytics: widget.analytics,
          observer: widget.observer,
        ));
      }
    } else {
      showNetworkErrorSnackBar(_scaffoldKey);
    }
  }
}
