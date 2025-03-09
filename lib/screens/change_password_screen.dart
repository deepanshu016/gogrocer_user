import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/home_screen.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/theme/style.dart';
import 'package:user/widgets/bottom_button.dart';

class ChangePasswordScreen extends BaseRoute {
  final int? screenId;
  final String? phoneNumber;
  const ChangePasswordScreen({super.key, super.analytics, super.observer, super.routeName = 'ChangePasswordScreen', this.screenId, this.phoneNumber});
  @override
  BaseRouteState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends BaseRouteState<ChangePasswordScreen> {
  final TextEditingController _cNewPassword = TextEditingController();
  final TextEditingController _cConfirmPassword = TextEditingController();
  final FocusNode _fNewPassword = FocusNode();
  final FocusNode _fConfirmPassword = FocusNode();
  bool _showNewPassword = true;
  bool _showConfirmPassword = true;
  bool isloading = true;
  GlobalKey<ScaffoldState>? _scaffoldKey;

  _ChangePasswordScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.keyboard_arrow_left,
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Text(
                  AppLocalizations.of(context)!.lbl_reset_password,
                  style: normalHeadingStyle(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: TextFormField(
                  focusNode: _fNewPassword,
                  controller: _cNewPassword,
                  obscureText: _showNewPassword,
                  style: textFieldInputStyle(context, FontWeight.normal),
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  readOnly: false,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    prefixStyle: textFieldInputStyle(context, FontWeight.normal),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.7,
                        color: Colors.black,
                      ),
                    ),
                    hintText: AppLocalizations.of(context)!.lbl_password,
                    suffixIcon: IconButton(
                      icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off, color: IconTheme.of(context).color),
                      onPressed: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                    ),
                    hintStyle: textFieldHintStyle(context),
                  ),
                  onFieldSubmitted: (val) {
                    setState(() {
                      FocusScope.of(context).requestFocus(_fConfirmPassword);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                    focusNode: _fConfirmPassword,
                    controller: _cConfirmPassword,
                    obscureText: _showConfirmPassword,
                    style: textFieldInputStyle(context, FontWeight.normal),
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    readOnly: false,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      prefixStyle: textFieldInputStyle(context, FontWeight.normal),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.7,
                          color: Colors.black,
                        ),
                      ),
                      hintText: AppLocalizations.of(context)!.txt_reEnter_password,
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off, color: IconTheme.of(context).color),
                        onPressed: () {
                          _showConfirmPassword = !_showConfirmPassword;
                          setState(() {});
                        },
                      ),
                      hintStyle: textFieldHintStyle(context),
                    ),
                    onFieldSubmitted: (val) {
                      setState(() {
                        FocusScope.of(context).dispose();
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: BottomButton(
                  loadingState: false,
                  disabledState: false,
                  onPressed: () {
                    _changePassword();
                  },
                  child: Text(AppLocalizations.of(context)!.btn_save_update),
                ),
              )
            ],
          )),
        ));
  }

  _changePassword() async {
    try {
      if (_cNewPassword.text.isNotEmpty && _cNewPassword.text.trim().length >= 8 && _cConfirmPassword.text.isNotEmpty && _cNewPassword.text.trim() == _cConfirmPassword.text.trim()) {
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          showOnlyLoaderDialog();

          await apiHelper.changePassword(widget.screenId == 0 ? widget.phoneNumber : global.userProfileController.currentUser!.userPhone, _cNewPassword.text.trim()).then((result) {
            if (result != null) {
              if (result.status == "1") {
                hideLoader();
                if(!mounted) return;
                widget.screenId == 0
                    ? Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => LoginScreen(
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                )),
                      )
                    : Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                )),
                      );
                setState(() {});
              } else {
                hideLoader();
                showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
              }
            }
          });
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      } else if (_cNewPassword.text.isEmpty || _cNewPassword.text.trim().length < 8) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_password_should_be_of_minimum_8_character);
      } else if (_cConfirmPassword.text.isEmpty || _cConfirmPassword.text.trim() != _cNewPassword.text.trim()) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_password_do_not_match);
      }
    } catch (e) {
      debugPrint("Exception - change_password_screen.dart - _changePassword():$e");
    }
  }
}
