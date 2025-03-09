import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/dialog/open_image_dialog.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/business_rule.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/image_model.dart';
import 'package:user/models/membership_status_model.dart';
import 'package:user/models/user_model.dart';
import 'package:user/screens/chat_screen.dart';
import 'package:user/screens/home_screen.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/otp_verification_screen.dart';
import 'package:user/screens/product_description_screen.dart';
import 'package:user/screens/signup_screen.dart';
import 'package:user/widgets/toastfile.dart';

class Base extends StatefulWidget {
  final FirebaseAnalytics? analytics;
  final FirebaseAnalyticsObserver? observer;

  final String? routeName;

  const Base({super.key, this.analytics, this.observer, this.routeName});

  @override
  BaseState<Base> createState() => BaseState();

  void showNetworkErrorSnackBar(GlobalKey<ScaffoldState> scaffoldKey) {}
}

class BaseState<T extends Base> extends State<T> with TickerProviderStateMixin, WidgetsBindingObserver {
  bool bannerAdLoaded = false;
  late APIHelper apiHelper;

  late BusinessRule br;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  BaseState() {
    apiHelper = APIHelper();
    br = BusinessRule(apiHelper);
  }

  Future<bool> addRemoveWishList(int? varientId) async {
    bool isAddedSuccessFully = false;
    try {
      showOnlyLoaderDialog();
      await apiHelper.addRemoveWishList(varientId).then((result) async {
        if (result != null) {
          if (result.status == "1" || result.status == "2") {
            isAddedSuccessFully = true;
            hideLoader();
          } else {
            isAddedSuccessFully = false;
            hideLoader();
            if(!mounted) return;
            AppLocalizations? localizations = AppLocalizations.of(context);
            if (localizations != null) {
              showToast(localizations
                  .txt_please_try_again_after_sometime);
            }
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content: Text(
            //     '${AppLocalizations.of(context).txt_please_try_again_after_sometime}',
            //     textAlign: TextAlign.center,
            //   ),
            //   duration: Duration(seconds: 2),
            // ));
          }
        }
      });
      return isAddedSuccessFully;
    } catch (e) {
      hideLoader();
      debugPrint("Exception - base.dart - addRemoveWishList():$e");
      return isAddedSuccessFully;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  Future<MembershipStatus?> checkMemberShipStatus(GlobalKey<ScaffoldState>? scaffoldKey) async {
    MembershipStatus? membershipStatus = MembershipStatus();
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.membershipStatus().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              hideLoader();

              membershipStatus = result.data;
            } else {
              hideLoader();

              showSnackBar(key: scaffoldKey, snackBarMessage: '${result.message}');
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(scaffoldKey);
      }
      return membershipStatus;
    } catch (e) {
      debugPrint("Exception - base.dart - checkMemberShipStatus():$e");
      return null;
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  dialogToOpenImage(String? name, List<ImageModel> imageList, int index) {
    try {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return OpenImageDialog(
              a: widget.analytics,
              o: widget.observer,
              imageList: imageList,
              index: index,
              name: name,
            );
          });
    } catch (e) {
      debugPrint("Exception - base.dart - dialogToOpenImage() $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    debugPrint('appLifeCycleState inactive');

    if (global.sp!=null && global.sp!.getString("currentUser") != null) {
      if (!global.isChatNotTapped) {
        global.currentUser = CurrentUser.fromJson(json.decode(global.sp!.getString("currentUser")!));
        if (global.localNotificationModel.route == 'chatlist_screen') {
          if (state == AppLifecycleState.resumed) {
            setState(() {
              global.isChatNotTapped = true;
            });
            Get.to(() => ChatScreen(analytics: widget.analytics, observer: widget.observer));
          }
        }
      }
    } else if (global.localNotificationModel.chatId != null && !global.isChatNotTapped) {
      if (state == AppLifecycleState.resumed) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LoginScreen(
                  analytics: widget.analytics,
                  observer: widget.observer,
                )));
      }
    }
  }

  Future<bool> dontCloseDialog() async {
    return false;
  }

  Future exitAppDialog() async {
    try {
      showAdaptiveDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            title: Text(
              AppLocalizations.of(context)!.lbl_exit_app,
              style: const TextStyle(
                fontFamily: 'AvenirLTStd',
              ),
            ),
            content: Text(AppLocalizations.of(context)!.txt_exit_app_msg,
                style: const TextStyle(
                  fontFamily: 'AvenirLTStd',
                )),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.lbl_cancel,
                    style: const TextStyle(color: Colors.red)
                ),
                onPressed: () {
                  return Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.btn_exit),
                onPressed: () async {
                 exit(0);
                },
              ),
            ],
          )
      );
    } catch (e) {
      debugPrint('Exception - base.dart - exitAppDialog(): $e');
    }
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(global.lat!, global.lng!);

      Placemark place = placemarks[0];

      setState(() {
        global.currentLocation = "${place.name}, ${place.locality} ";
      });
    } catch (e) {
      hideLoader();
      debugPrint("Exception - base.dart - getAddressFromLatLng():$e");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        global.lat = position.latitude;
        global.lng = position.longitude;
      });

      List<dynamic> _ = await Future.wait([
        getAddressFromLatLng(),
        getNearByStore(),
      ]);
    } catch (e) {
      hideLoader();
      debugPrint("Exception -  base.dart - getCurrentLocation():$e");
    }
    return ;
  }

  Future<void> getCurrentPosition() async {
    try {
      if (Platform.isIOS) {
        LocationPermission s = await Geolocator.checkPermission();
        if (s == LocationPermission.denied || s == LocationPermission.deniedForever) {
          s = await Geolocator.requestPermission();
        }
        if (s != LocationPermission.denied || s != LocationPermission.deniedForever) {
          await getCurrentLocation();
        } else {
          if(!mounted) return;
          global.locationMessage = AppLocalizations.of(context)!.txt_please_enablet_location_permission_to_use_app;
        }
      } else {
        PermissionStatus permissionStatus = await Permission.location.status;
        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          permissionStatus = await Permission.location.request();
        }
        if (permissionStatus.isGranted) {
          await getCurrentLocation();
        } else {
          if(!mounted) return;
          global.locationMessage = AppLocalizations.of(context)!.txt_please_enablet_location_permission_to_use_app;
        }
      }
    } catch (e) {
      hideLoader();
      debugPrint("Exception -  base.dart - getCurrentPosition():$e");
    }

    return;
  }

  Future<void> getNearByStore() async {
    try {
      await apiHelper.getNearbyStore().then((result) async {
        if (result != null) {
          if (result.status == "1") {
            global.nearStoreModel = result.data;
            if (global.appInfo!.lastLoc == 1) {
              global.sp!.setString("lastloc", '${global.lat}|${global.lng}');
            }
            if (global.currentUser!.id != null) {
              await apiHelper.updateFirebaseUserFcmToken(global.currentUser!.id, global.appDeviceId);
            }
            if (global.currentUser!.id != null) {
              await global.userProfileController.getUserAddressList();
            }
          } else if (result.status == "0") {
            global.nearStoreModel = null;
            global.locationMessage = result.message;
          }
        }
      });

      if (global.currentUser!.id != null) {
        await global.userProfileController.getMyProfile();
      }
    } catch (e) {
      hideLoader();
      debugPrint("Exception -  base.dart - _getNearByStore():$e");
    }

    return;
  }

  void hideLoader() {
    Navigator.pop(context);
  }

  openBarcodeScanner(GlobalKey<ScaffoldState> scaffoldKey) async {
    try {
      String barcodeScanRes;
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      if (barcodeScanRes != '-1') {
        await _getBarcodeResult(scaffoldKey, barcodeScanRes);
      }
    } catch (e) {
      hideLoader();
      debugPrint("Exception - business_rule.dart - openBarcodeScanner():$e");
    }
  }

  sendOTP(String phoneNumber, {int? screenId}) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+${global.appInfo!.countryCode}$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          hideLoader();
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_try_again_after_sometime);
        },
        codeSent: (String verificationId, int? resendToken) async {
          hideLoader();
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                      analytics: widget.analytics,
                      observer: widget.observer,
                      verificationCode: verificationId,
                      phoneNumber: phoneNumber,
                      screenId: screenId,
                    )),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      hideLoader();
      debugPrint("Exception - base.dart - _sendOTP():$e");
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  showNetworkErrorSnackBar(GlobalKey<ScaffoldState>? scaffoldKey) {
    try {
      // bool isConnected;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(days: 1),
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.signal_wifi_off,
              color: Colors.white,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                ),
                child: Text(
                  'No internet available',
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(textColor: Colors.white, label: 'RETRY', onPressed: () async {}),
        backgroundColor: Colors.grey,
      ));
    } catch (e) {
      debugPrint("Exception -  base.dart - showNetworkErrorSnackBar():$e");
    }
  }

  showOnlyLoaderDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void showSnackBar({required String snackBarMessage, GlobalKey<ScaffoldState>? key}) {
    showToast(snackBarMessage);
  }

  // signInWithFacebook(GlobalKey<ScaffoldState> scaffoldKey) async {
  //   try {
  //     bool isConnected = await br.checkConnectivity();
  //     if (isConnected) {
  //       showOnlyLoaderDialog();
  //       final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ["email", "public_profile"]);
  //       if(loginResult != null && loginResult.accessToken != null){
  //
  //       final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken.token);
  //       var authCredentials = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  //       if (authCredentials != null && authCredentials.user != null) {
  //
  //       }
  //       hideLoader();
  //       }else{
  //          hideLoader();
  //         showSnackBar(key: _scaffoldKey, snackBarMessage: "${AppLocalizations.of(context).txt_something_went_wrong} ${AppLocalizations.of(context).txt_please_try_again_after_sometime}");
  //       }
  //     } else {
  //       hideLoader();
  //       showNetworkErrorSnackBar(scaffoldKey);
  //     }
  //   } catch (e) {
  //     hideLoader();
  //     debugPrint("Exception - base.dart - signInWithFacebook():" + e.toString());
  //   }
  // }

  signInWithGoogle(GlobalKey<ScaffoldState>? scaffoldKey) async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await _googleSignIn.signIn().then((result) {
        if (result != null) {
          result.authentication.then((googleKey) async {
            if (_googleSignIn.currentUser != null) {
              showOnlyLoaderDialog();
              await apiHelper.socialLogin(userEmail: _googleSignIn.currentUser!.email, type: 'google').then((result) async {
                if (result != null) {
                  if (result.status == "1") {
                    global.currentUser = result.data;
                    global.sp!.setString('currentUser', json.encode(global.currentUser!.toJson()));

                    await global.userProfileController.getMyProfile();
                    hideLoader();
                    Get.to(() => HomeScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ));
                  } else {
                    CurrentUser currentUser = CurrentUser();
                    currentUser.email = _googleSignIn.currentUser!.email;
                    currentUser.name = _googleSignIn.currentUser!.displayName;

                    hideLoader();
                    // registration required
                    Get.to(
                      () => SignUpScreen(user: currentUser, analytics: widget.analytics, observer: widget.observer),
                    );
                  }
                }
              });
            }
          });
        }
      });
    } catch (e) {
      hideLoader();
      debugPrint("Exception - base.dart - _signInWithGoogle():$e");
    }
  }

  _getBarcodeResult(GlobalKey<ScaffoldState> scaffoldKey, String code) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.barcodeScanResult(code).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              hideLoader();
              if(!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDescriptionScreen(productDetail: result.data, analytics: widget.analytics, observer: widget.observer),
                ),
              );
            } else {
              hideLoader();

              showSnackBar(key: scaffoldKey, snackBarMessage: '${result.message}');
            }
          } else {
            hideLoader();
          }
        });
      } else {
        showNetworkErrorSnackBar(scaffoldKey);
      }
    } catch (e) {
      hideLoader();
      debugPrint("Exception - base.dart - _getBarcodeResult():$e");
    }
  }
}
