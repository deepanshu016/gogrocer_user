import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/otp_verification_screen.dart';

GlobalKey<ScaffoldState>? _scaffoldKey;

class ForgotPasswordScreen extends BaseRoute {
  const ForgotPasswordScreen({super.key, super.analytics, super.observer, super.routeName = 'ForgotPasswordScreen'});

  @override
  BaseRouteState createState() => _ForgotPasswordScreenState();
}

class ResetForm extends StatefulWidget {
  const ResetForm({super.key});

  @override
  State<ResetForm> createState() => _ResetFormState();
}

class _ForgotPasswordScreenState extends BaseRouteState {
  final TextEditingController _cPhone = TextEditingController();
  final FocusNode _fPhone = FocusNode();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.lbl_forgot_password,
                    style: textTheme.titleLarge,
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                Text(
                  AppLocalizations.of(context)!.txt_please_enter_mobile_number,
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _cPhone,
                  focusNode: _fPhone,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(global.appInfo!.phoneNumberLength)],
                  decoration: InputDecoration(hintText: AppLocalizations.of(context)!.lbl_phone_number, hintStyle: const TextStyle(color: Color(0xFF979797)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide())),
                ),
                const SizedBox(
                  height: 70,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(450.0),
                      minimumSize: const Size.fromHeight(55),
                      foregroundColor: const Color(0xffFF0000),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _sendOTP();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.btn_send,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  "assets/images/forgotPassword.jpg",
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  _sendOTP() async {
    try {
      if (_cPhone.text.isNotEmpty && _cPhone.text.trim().length == global.appInfo!.phoneNumberLength) {
        showOnlyLoaderDialog();
        await apiHelper.forgotPassword(_cPhone.text).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              if (global.appInfo!.firebase != 'off') {
                // if firebase is enabled then only we need to send OTP through firebase.
                await sendOTP(_cPhone.text.trim(), screenId: 0);
              } else {
                hideLoader();
                if(!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OtpVerificationScreen(screenId: 0, phoneNumber: _cPhone.text.trim(), analytics: widget.analytics, observer: widget.observer),
                  ),
                );
              }
            } else {
              hideLoader();

              showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
            }
          }
        });
      } else {
        showSnackBar(key: _scaffoldKey, snackBarMessage: '${AppLocalizations.of(context)!.txt_please_enter_valid_mobile_number} ');
      }
    } catch (e) {
      debugPrint("Exception - forgot_password_screen.dart - _sendOTP():$e");
    }
  }
}

class _ResetFormState extends State<ResetForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        decoration: InputDecoration(hintText: AppLocalizations.of(context)!.lbl_phone_number, hintStyle: const TextStyle(color: Color(0xFF979797)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide())),
      ),
    );
  }
}
