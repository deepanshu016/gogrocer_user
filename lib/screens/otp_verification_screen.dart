import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/change_password_screen.dart';
import 'package:user/screens/home_screen.dart';
import 'package:user/theme/style.dart';
import 'package:user/widgets/bottom_button.dart';

class OtpVerificationScreen extends BaseRoute {
  final String? phoneNumber;
  final String? verificationCode;
  final String? referralCode;
  final int? screenId;

  const OtpVerificationScreen({super.key, 
    super.analytics,
    super.observer,
    super.routeName = 'OtpVerificationScreen',
    this.screenId,
    this.phoneNumber,
    this.verificationCode,
    this.referralCode,
  });

  @override
  BaseRouteState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends BaseRouteState<OtpVerificationScreen> {
  int _seconds = 60;
  late Timer _countDown;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  String? status;
  final FocusNode _fOtp = FocusNode();
  final _cOtp = TextEditingController();

  _OtpVerificationScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 35),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80, bottom: 50),
                  child: Text(
                    AppLocalizations.of(context)!.tle_verify_otp,
                    style: normalHeadingStyle(context),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.tle_verify_otp_sent_desc,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    AppLocalizations.of(context)!.txt_enter_otp,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 10),
                    width: 315,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    alignment: Alignment.center,
                    child: PinFieldAutoFill(
                      key: const Key("1"),
                      focusNode: _fOtp,
                      decoration: BoxLooseDecoration(
                        strokeColorBuilder: FixedColorBuilder(Theme.of(context).colorScheme.primary),
                        hintText: '••••••',
                      ),
                      currentCode: _cOtp.text,
                      controller: _cOtp,
                      codeLength: 6,
                      keyboardType: TextInputType.number,
                      onCodeSubmitted: (code) {
                        setState(() {
                          _cOtp.text = code;
                        });
                      },
                      onCodeChanged: (code) async {
                        if (code!.length == 6) {
                          _cOtp.text = code;
                          setState(() {});
                          await _checkOTP(_cOtp.text);
                          if(!context.mounted) return;
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      },
                    )),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    gradient: LinearGradient(
                      stops: const [0, .90],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
                    ),
                  ),
                  margin: const EdgeInsets.only(top: 5),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: BottomButton(
                      loadingState: false,
                      disabledState: false,
                      onPressed: () async {
                        if (_cOtp.text.length == 6) {
                          await _checkOTP(_cOtp.text);
                        } else {
                          showSnackBar(snackBarMessage: AppLocalizations.of(context)!.txt_6_digit_msg, key: _scaffoldKey);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.btn_login)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    AppLocalizations.of(context)!.txt_didnt_receive_otp,
                  ),
                ),
                _seconds != 0
                    ? Text("Wait 00:$_seconds")
                    : InkWell(
                        onTap: () async {
                          await _resendOTP();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            AppLocalizations.of(context)!.btn_resend_otp,
                          ),
                        ),
                      )
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    // SmsAutoFill().unregisterListener();
    // _cOtp.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // _init(); otp auto fetch
    startTimer();
  }

  Future startTimer() async {
    setState(() {});
    const oneSec = Duration(seconds: 1);
    _countDown = Timer.periodic(
      oneSec,
      (timer) {
        if (_seconds == 0) {
          setState(() {
            _countDown.cancel();
            timer.cancel();
          });
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );

    setState(() {});
  }

//   _init() async {
//     try {
// // need to change design as well

//       OTPInteractor.getAppSignature().then((value) => debugPrint('signature - $value'));
//       _cOtp = OTPTextEditController(
//         codeLength: 6,
//         onCodeReceive: (code) {
//           debugPrint("code  1 $code");
//           setState(() {
//             _cOtp.text = code;
//           });
//         },
//       )..startListenUserConsent(
//           (code) {
//             debugPrint("code   $code");
//             final exp = RegExp(r'(\d{6})');
//             return exp.stringMatch(code ?? '') ?? '';
//           },
//           strategies: [],
//         );

//       await SmsAutoFill().listenForCode;
//     } catch (e) {
//       debugPrint("Exception - verifyOtpScreen.dart - _init():" + e.toString());
//     }
//   }

  Future _checkOTP(String otp) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (global.appInfo!.firebase != 'off') {
          FirebaseAuth auth = FirebaseAuth.instance;
          var credential = PhoneAuthProvider.credential(verificationId: widget.verificationCode!, smsCode: otp.trim());
          showOnlyLoaderDialog();
          await auth.signInWithCredential(credential).then((result) {
            status = 'success';
            hideLoader();
            if (widget.screenId != null && widget.screenId == 0) {
//screenId ==0 -> Forgot Password
              _firebaseOtpVerification(status);
            } else {
              _verifyViaFirebase(status);
            }
          }).catchError((e) {
            status = 'failed';
            hideLoader();

            if (widget.screenId != null && widget.screenId == 0) {
//screenId ==0 -> Forgot Password
              _firebaseOtpVerification(status);
            } else {
              _verifyViaFirebase(status);
            }
          }).onError((dynamic error, stackTrace) {
            hideLoader();
          });
        } else {
          if (widget.screenId != null && widget.screenId == 0) {
            showOnlyLoaderDialog();
            await apiHelper.verifyOTP(widget.phoneNumber, _cOtp.text).then((result) async {
              if (result != null) {
                if (result.status == "1") {
                  global.currentUser = result.recordList;
                  global.userProfileController.currentUser = global.currentUser;
                  global.sp!.setString('currentUser', json.encode(global.currentUser!.toJson()));

                  hideLoader();

                  Get.offAll(() => HomeScreen(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ));
                } else {
                  hideLoader();
                  showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
                }
              } else {
                hideLoader();
                if(!mounted) return;
                showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_something_went_wrong);
              }
            });
          } else {
            showOnlyLoaderDialog();
            await apiHelper.verifyPhone(widget.phoneNumber, _cOtp.text, widget.referralCode).then((result) async {
              if (result != null) {
                if (result.status == "1") {
                  global.currentUser = result.data;
                  global.sp!.setString('currentUser', json.encode(global.currentUser!.toJson()));
                  global.userProfileController.currentUser = global.currentUser;
                  hideLoader();

                  Get.offAll(() => HomeScreen(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ));
                } else {
                  hideLoader();
                  showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
                }
              } else {
                hideLoader();
              }
            });
          }
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - otp_verification_screen.dart - _checkOTP():$e");
    }
  }

  _firebaseOtpVerification(String? status) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.firebaseOTPVerification(widget.phoneNumber, status).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              hideLoader();
              Get.offAll(() => ChangePasswordScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    screenId: 0,
                    phoneNumber: widget.phoneNumber,
                  ));
            } else {
              hideLoader();
              showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          } else {
            hideLoader();
          }
        }).catchError((e) {});
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - otp_verification_screen.dart - _verifyOtp():$e");
    }
  }

  Future _getOTP(String? mobileNumber) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.verifyPhoneNumber(
        phoneNumber: '+${global.appInfo!.countryCode}$mobileNumber',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) async {
          var a = authCredential.providerId;
          debugPrint("a $a");
          setState(() {});
        },
        verificationFailed: (authException) {},
        codeSent: (String verificationId, [int? forceResendingToken]) async {
          _cOtp.clear();
          _seconds = 60;
          startTimer();
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint("Exception - otp_verification_screen.dart - _getOTP():$e");
      return null;
    }
  }

  _resendOTP() async {
    try {
      if (global.appInfo!.firebase != 'off') {
        // firebase resend OTP
        await _getOTP(widget.phoneNumber);
      } else {
// resend API
        showOnlyLoaderDialog();
        await apiHelper.resendOTP(widget.phoneNumber).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              hideLoader();
              _cOtp.clear();
              _seconds = 60;
              startTimer();
              setState(() {});
            } else {
              hideLoader();
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - otp_verification_screen.dart - _resendOTP():$e");
    }
  }

  _verifyViaFirebase(String? status) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.verifyViaFirebase(widget.phoneNumber, status, widget.referralCode).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.currentUser = result.data;
              global.userProfileController.currentUser = global.currentUser;
              global.sp!.setString('currentUser', json.encode(global.currentUser!.toJson()));

              hideLoader();

              Get.to(() => HomeScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                  ));
            } else {
              hideLoader();
              showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          } else {
            hideLoader();
          }
        }).catchError((e) {
          debugPrint(e);
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - otp_verification_screen.dart - _verifyOtp():$e");
    }
  }
}
