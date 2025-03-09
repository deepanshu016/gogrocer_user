import 'dart:core';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/city_model.dart';
import 'package:user/models/society_model.dart';
import 'package:user/models/user_model.dart';
import 'package:user/screens/otp_verification_screen.dart';
import 'package:user/theme/style.dart';
import 'package:user/widgets/bottom_button.dart';
import 'package:user/widgets/my_text_field.dart';
import 'package:user/widgets/profile_picture.dart';

class SignUpScreen extends BaseRoute {
  final CurrentUser? user;
  final int? loginType;
  const SignUpScreen({super.key, super.analytics, super.observer, super.routeName = 'SignUpScreen', this.user, this.loginType});

  @override
  BaseRouteState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends BaseRouteState<SignUpScreen> {
  final TextEditingController _cName = TextEditingController();

  final TextEditingController _cPhoneNumber = TextEditingController();
  final TextEditingController _cEmail = TextEditingController();
  final TextEditingController _cPassword = TextEditingController();
  final TextEditingController _cConfirmPassword = TextEditingController();
  final TextEditingController _cCity = TextEditingController();
  final TextEditingController _cSociety = TextEditingController();
  final TextEditingController _cReferral = TextEditingController();
  final TextEditingController _cSearchCity = TextEditingController();
  final TextEditingController _cSearchSociety = TextEditingController();
  final FocusNode _fName = FocusNode();
  final FocusNode _fPhoneNumber = FocusNode();
  final FocusNode _fEmail = FocusNode();
  final FocusNode _fCity = FocusNode();
  final FocusNode _fSociety = FocusNode();
  final FocusNode _fReferral = FocusNode();
  final FocusNode _fPassword = FocusNode();
  final FocusNode _fConfirmPassword = FocusNode();
  final FocusNode _fSearchCity = FocusNode();
  final FocusNode _fSearchSociety = FocusNode();
  final FocusNode _fDismiss = FocusNode();
  bool _isPasswordVisible = true;

  bool _isConfirmPasswordVisible = true;
  List<City>? _citiesList = [];
  List<Society>? _societyList = [];
  final List<City> _tCityList = [];
  final List<Society> _tSocietyList = [];
  City? _selectedCity = City();
  Society? _selectedSociety = Society();
  GlobalKey<ScaffoldState>? _scaffoldKey;
  _SignUpScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(
                  child: ProfilePicture(
                    isShow: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                key: const Key('6'),
                controller: _cName,
                focusNode: _fName,
                hintText: AppLocalizations.of(context)!.lbl_name,
                autofocus: false,
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_fPhoneNumber);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                key: const Key('7'),
                controller: _cPhoneNumber,
                focusNode: _fPhoneNumber,
                hintText: 'Mobile No.',
                readOnly: widget.loginType==0,
                autofocus: false,
                maxLines: 1,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(global.appInfo!.phoneNumberLength)],
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_fEmail);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                key: const Key('8'),
                controller: _cEmail,
                focusNode: _fEmail,
                hintText: AppLocalizations.of(context)!.lbl_email,
                autofocus: false,
                maxLines: 1,
                readOnly: widget.loginType==1,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_fPassword);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _cPassword,
                focusNode: _fPassword,
                obscureText: _isPasswordVisible,
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
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: IconTheme.of(context).color),
                    onPressed: () {
                      _isPasswordVisible = !_isPasswordVisible;
                      setState(() {});
                    },
                  ),
                  hintStyle: textFieldHintStyle(context),
                ),
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_fConfirmPassword);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _cConfirmPassword,
                focusNode: _fConfirmPassword,
                obscureText: _isConfirmPasswordVisible,
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
                  hintText: AppLocalizations.of(context)!.lbl_confirm_password,
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: IconTheme.of(context).color),
                    onPressed: () {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      setState(() {});
                    },
                  ),
                  hintStyle: textFieldHintStyle(context),
                ),
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_fCity);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                child: MyTextField(
                  key: const Key('111'),
                  controller: _cCity,
                  focusNode: _fCity,
                  readOnly: true,
                  autofocus: false,
                  hintText: AppLocalizations.of(context)!.hnt_select_city,
                  onTap: () {
                    if (_citiesList != null && _citiesList!.isNotEmpty) {
                      _cCity.clear();
                      _cSociety.clear();
                      _cSearchCity.clear();
                      _cSearchSociety.clear();
                      _selectedCity = City();
                      _selectedSociety = Society();
                      _showCitySelectDialog();
                    } else {
                      showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_no_city);
                    }

                    setState(() {});
                  },
                  onFieldSubmitted: (val) {
                    FocusScope.of(context).requestFocus(_fSociety);
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                key: const Key('11'),
                controller: _cSociety,
                focusNode: _fSociety,
                hintText: AppLocalizations.of(context)!.hnt_select_society,
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_fReferral);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MyTextField(
                  key: const Key('112'),
                  controller: _cReferral,
                  focusNode: _fReferral,
                  hintText: 'Referral Code',
                  onFieldSubmitted: (val) {
                    FocusScope.of(context).requestFocus(_fDismiss);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 13, right: 13, top: 5),
              child: BottomButton(
                loadingState: false,
                disabledState: false,
                onPressed: () {
                  _onSignUp();
                },
                child: Text(AppLocalizations.of(context)!.btn_signup),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.lbl_already_have_account),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.btn_login),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _filldata() {
    try {
      _cPhoneNumber.text = widget.user!.userPhone!;
      _cEmail.text = widget.user!.email!;
      _cName.text = widget.user!.name!;
    } catch (e) {
      debugPrint("Exception - signup_screen.dart - _filldata():$e");
    }
  }

  _getCities() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getCity().then((result) {
          if (result != null && result.statusCode == 200 && result.status == '1') {
            _citiesList = result.data;
            _tCityList.addAll(_citiesList!);
          } else {
            _citiesList = [];
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - signup_screen.dart - _getCities():$e");
    }
  }

  _getSociety() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getSociety(_selectedCity!.cityId).then((result) {
          if(!mounted) return;
          if (result != null && result.statusCode == 200 && result.status == '1') {
            _societyList = result.data;
            _tSocietyList.addAll(_societyList!);
            Navigator.of(context).pop();
            _cSearchCity.clear();
            _showSocietySelectDialog();
            setState(() {});
          } else {
            Navigator.of(context).pop();
            _cSearchCity.clear();
            _societyList = [];
            showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - signup_screen.dart - _getSociety():$e");
    }
  }

  _init() async {
    try {
      _filldata();
      await _getCities();
      setState(() {});
    } catch (e) {
      debugPrint("Exception - signup_screen.dart - _init():$e");
    }
  }

  _onSignUp() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_cName.text.isNotEmpty && EmailValidator.validate(_cEmail.text) && _cEmail.text.isNotEmpty && _cPhoneNumber.text.isNotEmpty && _cPhoneNumber.text.trim().length == global.appInfo!.phoneNumberLength && _cPassword.text.isNotEmpty && _cPassword.text.trim().length >= 8 && _cConfirmPassword.text.isNotEmpty && _cPassword.text.trim().length == _cConfirmPassword.text.trim().length && _cPassword.text.trim() == _cConfirmPassword.text.trim() && _selectedCity != null && _selectedCity!.cityId != null) {
          showOnlyLoaderDialog();
          CurrentUser user = CurrentUser();

          user.name = _cName.text.trim();
          user.email = _cEmail.text.trim();
          user.userPhone = _cPhoneNumber.text.trim();
          user.password = _cPassword.text.trim();
          user.userImage = global.selectedImage;
          user.referralCode = _cReferral.text.trim();
          user.userCity = _selectedCity!.cityId;
          user.userArea = _selectedSociety!.societyId;
          user.facebookId = user.facebookId;

          await apiHelper.signUp(user).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                global.currentUser = result.data;
                global.userProfileController.currentUser = global.currentUser;

                if (global.appInfo!.firebase != 'off') {
                  // if firebase is enabled then only we need to send OTP through firebase.
                  await sendOTP(_cPhoneNumber.text.trim());
                } else {
                  hideLoader();
                  Get.to(() => OtpVerificationScreen(
                        analytics: widget.analytics,
                        observer: widget.observer,
                        phoneNumber: _cPhoneNumber.text.trim(),
                        referralCode: _cReferral.text.trim(),
                      ));
                }
              } else {
                hideLoader();
                showSnackBar(key: _scaffoldKey, snackBarMessage: result.message.toString());
              }
            }
          });
        } else if (_cName.text.isEmpty) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_enter_your_name);
        } else if (_cEmail.text.isEmpty) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_enter_your_email);
        } else if (_cEmail.text.isNotEmpty && !EmailValidator.validate(_cEmail.text)) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_enter_your_valid_email);
        } else if (_cPhoneNumber.text.isEmpty || (_cPhoneNumber.text.isNotEmpty && _cPhoneNumber.text.trim().length != global.appInfo!.phoneNumberLength)) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_enter_valid_mobile_number);
        } else if (_cPassword.text.isEmpty) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_enter_your_password);
        } else if (_cPassword.text.isNotEmpty && _cPassword.text.trim().length < 8) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_password_should_be_of_minimum_8_character);
        } else if (_cConfirmPassword.text.isEmpty && _cPassword.text.isNotEmpty) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_reEnter_your_password);
        } else if (_cConfirmPassword.text.isNotEmpty && _cPassword.text.isNotEmpty && (_cConfirmPassword.text.trim() != _cPassword.text.trim())) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_password_do_not_match);
        } else if (_selectedCity!.cityId == null) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_select_city);
        } else if (_selectedSociety!.societyId == null) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_select_society);
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - signup_screen.dart - _onSignUp():$e");
    }
  }

  _showCitySelectDialog() {
    try {
      showDialog(
          context: context,
          barrierColor: Colors.black38,
          builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) => AlertDialog(
                  elevation: 2,
                  scrollable: false,
                  contentPadding: EdgeInsets.zero,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.hnt_select_city),
                      Container(
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.only(),
                        child: MyTextField(
                          key: const Key('12'),
                          controller: _cSearchCity,
                          focusNode: _fSearchCity,
                          hintText: AppLocalizations.of(context)!.hnt_search_city,
                          onChanged: (val) {
                            _citiesList!.clear();
                            if (val.isNotEmpty && val.length > 2) {
                              _citiesList!.addAll(_tCityList.where((e) => e.cityName!.toLowerCase().contains(val.toLowerCase())));
                            } else {
                              _citiesList!.addAll(_tCityList);
                            }

                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: _citiesList != null && _citiesList!.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _citiesList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RadioListTile(
                                  title: Text('${_citiesList![index].cityName}'),
                                  value: _citiesList![index],
                                  groupValue: _selectedCity,
                                  onChanged: (dynamic value) async {
                                    _selectedCity = value;
                                    _cCity.text = _selectedCity!.cityName!;
                                    await _getSociety();
                                    setState(() {});
                                  });
                            })
                        : Center(
                            child: Text(
                              AppLocalizations.of(context)!.txt_no_city,
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Text(AppLocalizations.of(context)!.btn_close))
                  ],
                ),
              ));
    } catch (e) {
      debugPrint("Exception - signup_screen.dart - _showCitySelectDialog():$e");
    }
  }

  _showSocietySelectDialog() {
    try {
      showDialog(
          context: context,
          useRootNavigator: true,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.hnt_select_society),
                      Container(
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.only(),
                        child: TextFormField(
                          controller: _cSearchSociety,
                          focusNode: _fSearchSociety,
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            hintText: AppLocalizations.of(context)!.htn_search_society,
                            contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                          ),
                          onChanged: (val) {
                            _societyList!.clear();
                            if (val.isNotEmpty && val.length > 2) {
                              _societyList!.addAll(_tSocietyList.where((e) => e.societyName!.toLowerCase().contains(val.toLowerCase())));
                            } else {
                              _societyList!.addAll(_tSocietyList);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: _societyList != null && _societyList!.isNotEmpty
                        ? ListView.builder(
                            itemCount: _cSearchSociety.text.isNotEmpty && _tSocietyList.isNotEmpty ? _tSocietyList.length : _societyList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RadioListTile(
                                  title: Text(_cSearchSociety.text.isNotEmpty && _tSocietyList.isNotEmpty ? '${_tSocietyList[index].societyName}' : '${_societyList![index].societyName}'),
                                  value: _cSearchSociety.text.isNotEmpty && _tSocietyList.isNotEmpty ? _tSocietyList[index] : _societyList![index],
                                  groupValue: _selectedSociety,
                                  onChanged: (dynamic value) async {
                                    _selectedSociety = value;
                                    _cSociety.text = _selectedSociety!.societyName!;
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  });
                            })
                        : Center(
                            child: Text(
                            AppLocalizations.of(context)!.txt_no_society,
                            textAlign: TextAlign.center,
                          )),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Text(AppLocalizations.of(context)!.btn_close))
                  ],
                ),
              ));
    } catch (e) {
      debugPrint("Exception - signup_screen.dart - _showSocietySelectDialog():$e");
    }
  }
}
