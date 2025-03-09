import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/society_model.dart';
import 'package:user/widgets/bottom_button.dart';
import 'package:user/widgets/my_text_field.dart';

class AddAddressScreen extends BaseRoute {
  final Address? address;
  final int? screenId;
  const AddAddressScreen(this.address, {super.key, super.analytics, super.observer, super.routeName = 'AddAddressScreen', this.screenId});
  @override
  BaseRouteState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends BaseRouteState<AddAddressScreen> {
  final _cAddress = TextEditingController();
  final _cLandmark = TextEditingController();
  final _cPincode = TextEditingController();
  final _cState = TextEditingController();
  final _cCity = TextEditingController();
  final _cName = TextEditingController();
  final _cPhone = TextEditingController();
  final _cSociety = TextEditingController();
  final _cSearchSociety = TextEditingController();
  final _fSociety = FocusNode();
  final _fName = FocusNode();
  final _fPhone = FocusNode();
  final _fAddress = FocusNode();
  final _fLandmark = FocusNode();
  final _fPincode = FocusNode();
  final _fState = FocusNode();
  final _fCity = FocusNode();
  final _fDismiss = FocusNode();
  GlobalKey<ScaffoldState>? _scaffoldKey;
  Society? _selectedSociety = Society();
  String type = 'Home';
  bool _isDataLoaded = false;
  List<Society>? _societyList = [];
  final List<Society> _tSocietyList = [];
  final _fSearchSociety = FocusNode();

  _AddAddressScreenState() : super();

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.keyboard_arrow_left,
            ),
          ),
          title: widget.address!.addressId == null
              ? Text(
                  AppLocalizations.of(context)!.tle_add_new_address,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              : Text(
                  AppLocalizations.of(context)!.tle_edit_address,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
        ),
        body: SafeArea(
            child: global.nearStoreModel != null && global.nearStoreModel!.id != null
            ? _isDataLoaded
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                          margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
                          padding: const EdgeInsets.only(),
                          child: MyTextField(
                            key: const Key('19'),
                            controller: _cName,
                            focusNode: _fName,
                            autofocus: false,
                            textCapitalization: TextCapitalization.words,
                            hintText: AppLocalizations.of(context)!.lbl_name,
                            onFieldSubmitted: (val) {
                              setState(() {});
                              FocusScope.of(context).requestFocus(_fPhone);
                            },
                            onChanged: (value) {},
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                          margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
                          padding: const EdgeInsets.only(),
                          child: MyTextField(
                            key: const Key('20'),
                            controller: _cPhone,
                            focusNode: _fPhone,
                            autofocus: false,
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(global.appInfo!.phoneNumberLength)],
                            hintText: '${AppLocalizations.of(context)!.lbl_phone_number} ',
                            onFieldSubmitted: (val) {
                              FocusScope.of(context).requestFocus(_fAddress);
                            },
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                          margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
                          padding: const EdgeInsets.only(),
                          child: MyTextField(
                            key: const Key('21'),
                            controller: _cAddress,
                            focusNode: _fAddress,
                            hintText: '${AppLocalizations.of(context)!.txt_address} ',
                            onFieldSubmitted: (val) {
                              FocusScope.of(context).requestFocus(_fLandmark);
                            },
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                          margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
                          padding: const EdgeInsets.only(),
                          child: MyTextField(
                            key: const Key('22'),
                            controller: _cLandmark,
                            focusNode: _fLandmark,
                            hintText: '${AppLocalizations.of(context)!.hnt_near_landmark} ',
                            onFieldSubmitted: (val) {
                              FocusScope.of(context).requestFocus(_fPincode);
                            },
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                          margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
                          padding: const EdgeInsets.only(),
                          child: MyTextField(
                            key: const Key('23'),
                            controller: _cPincode,
                            focusNode: _fPincode,
                            hintText: ' ${AppLocalizations.of(context)!.hnt_pincode}',
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(global.appInfo!.phoneNumberLength)],
                            onFieldSubmitted: (val) {
                              FocusScope.of(context).requestFocus(_fSociety);
                            },
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                          margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
                          padding: const EdgeInsets.only(),
                          child: MyTextField(
                            key: const Key('24'),
                            controller: _cSociety,
                            focusNode: _fSociety,
                            readOnly: true,
                            maxLines: 3,
                            hintText: '${AppLocalizations.of(context)!.lbl_society} ',
                            onFieldSubmitted: (val) {
                              FocusScope.of(context).requestFocus(_fCity);
                            },
                            onTap: () {
                              _showSocietySelectDialog();
                            },
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                                margin: const EdgeInsets.only(top: 15, left: 16, right: 8),
                                padding: const EdgeInsets.only(),
                                child: MyTextField(
                                  key: const Key('25'),
                                  controller: _cCity,
                                  focusNode: _fCity,
                                  hintText: '${AppLocalizations.of(context)!.lbl_city} ',
                                  readOnly: true,
                                  onFieldSubmitted: (val) {
                                    FocusScope.of(context).requestFocus(_fState);
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                                margin: const EdgeInsets.only(top: 15, left: 8, right: 16),
                                padding: const EdgeInsets.only(),
                                child: MyTextField(
                                  key: const Key('26'),
                                  controller: _cState,
                                  focusNode: _fState,
                                  readOnly: widget.address!.addressId != null ? true : false,
                                  hintText: '${AppLocalizations.of(context)!.hnt_state} ',
                                  onFieldSubmitted: (val) {
                                    FocusScope.of(context).requestFocus(_fDismiss);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.lbl_save_address,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: InkWell(
                                  onTap: () {
                                    type = 'Home';
                                    setState(() {});
                                  },
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          color: type == 'Home' ? Theme.of(context).colorScheme.primary : Theme.of(context).scaffoldBackgroundColor),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${AppLocalizations.of(context)!.txt_home} ",
                                        style: TextStyle(
                                          color: type == 'Home' ? Colors.white : Colors.black,
                                          fontWeight: type == 'Home' ? FontWeight.w400 : FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      )),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  type = 'Office';
                                  setState(() {});
                                },
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        color: type == 'Office' ? Theme.of(context).colorScheme.primary : Theme.of(context).scaffoldBackgroundColor),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${AppLocalizations.of(context)!.txt_office} ",
                                      style: TextStyle(
                                        color: type == 'Office' ? Colors.white : Colors.black,
                                        fontWeight: type == 'Office' ? FontWeight.w400 : FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: InkWell(
                                  onTap: () {
                                    type = 'Others';
                                    setState(() {});
                                  },
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          color: type == 'Others' ? Theme.of(context).colorScheme.primary : Theme.of(context).scaffoldBackgroundColor),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      alignment: Alignment.center,
                                      child: Text(AppLocalizations.of(context)!.txt_others,
                                          style: TextStyle(
                                            color: type == 'Others' ? Colors.white : Colors.black,
                                            fontWeight: type == 'Others' ? FontWeight.w400 : FontWeight.w700,
                                            fontSize: 13,
                                          ))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : _shimmerList()
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(global.locationMessage!),
                ),
              )),
        bottomNavigationBar: _isDataLoaded
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: BottomButton(
                    key: UniqueKey(),
                    loadingState: false,
                    disabledState: false,
                    onPressed: () {
                      _save();
                    },
                    child: Text(AppLocalizations.of(context)!.btn_save_address)),
              )
            : null,
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    if (global.nearStoreModel != null && global.nearStoreModel!.id != null) {
      _init();
    }
  }

  _fillData() {
    try {
      _cName.text = widget.address!.receiverName!;
      _cPhone.text = widget.address!.receiverPhone!;
      _cPincode.text = widget.address!.pincode!;
      _cAddress.text = widget.address!.houseNo!;
      _cSociety.text = widget.address!.society!;
      _cState.text = widget.address!.state!;
      _cCity.text = widget.address!.city!;
      _cLandmark.text = widget.address!.landmark!;
    } catch (e) {
      debugPrint("Excetion - addAddessScreen.dart - _fillData():$e");
    }
  }

  _getSocietyList() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getSocietyForAddress().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _societyList = result.data;
              _tSocietyList.addAll(_societyList!);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - add_address_screen.dart -  _getSocietyList():$e");
    }
  }

  _init() async {
    try {
      await _getSocietyList();
      if (widget.address!.addressId != null) {
        _fillData();
      } else {
        // debugPrint("USER CITY N AREA${global.currentUser.userCity}, ${global.currentUser.userArea}");
        // _cCity.text = global.userProfileController.currentUser.userCity.
        _cCity.text = global.nearStoreModel!.city!;
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - add_address_screen.dart -  _init():$e");
    }
  }

  _save() async {
    try {
      if (_cName.text.isNotEmpty && _cPhone.text.isNotEmpty && _cPhone.text.length == global.appInfo!.phoneNumberLength && _cPincode.text.isNotEmpty && _cAddress.text.isNotEmpty && _cLandmark.text.isNotEmpty && _cSociety.text.isNotEmpty && _cCity.text.isNotEmpty) {
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          showOnlyLoaderDialog();
          Address tAddress = Address();
          tAddress.receiverName = _cName.text;
          tAddress.receiverPhone = _cPhone.text;
          tAddress.houseNo = _cAddress.text;
          tAddress.landmark = _cLandmark.text;
          tAddress.pincode = _cPincode.text;
          tAddress.society = _cSociety.text;
          tAddress.state = _cState.text;
          tAddress.city = _cCity.text;
          tAddress.type = type;
          String? latlng = await getLocationFromAddress('${_cAddress.text}, ${_cLandmark.text}, ${_cSociety.text}');
          debugPrint(latlng);
          if(latlng!=null){
            List<String> tList = latlng.split("|");
            tAddress.lat = tList[0];
            tAddress.lng = tList[1];
            if(tAddress.lat!=null && tAddress.lat!=null){
              if (widget.address!.addressId != null) {
                tAddress.addressId = widget.address!.addressId;
                await apiHelper.editAddress(tAddress).then((result) async {
                  if (result != null) {
                    if (result.status == "1") {
                      await global.userProfileController.getUserAddressList();

                      hideLoader();
                      if(!mounted) return;
                      Navigator.of(context).pop();
                    } else {
                      hideLoader();
                      showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
                    }
                  }else{
                    hideLoader();
                    showSnackBar(key: _scaffoldKey, snackBarMessage: 'Some error occurred please try again.');
                  }
                });
              }
              else {
                await apiHelper.addAddress(tAddress).then((result) async {
                  if (result != null) {
                    if (result.status == "1") {
                      await global.userProfileController.getUserAddressList();
                      hideLoader();
                      if(!mounted) return;
                      Navigator.of(context).pop();
                    }
                  }else{
                    hideLoader();
                    showSnackBar(key: _scaffoldKey, snackBarMessage: 'Some error occurred please try again.');
                  }
                });
                setState(() {});
              }
            }else{
              hideLoader();
              showSnackBar(key: _scaffoldKey, snackBarMessage: 'we are not able to find this location please input correct address');
            }
          }else{
            hideLoader();
            showSnackBar(key: _scaffoldKey, snackBarMessage: 'we are not able to find this location please input correct address');
          }
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      } else if (_cName.text.isEmpty) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: '${AppLocalizations.of(context)!.txt_please_enter_your_name} ');
      } else if (_cPhone.text.isEmpty || (_cPhone.text.isNotEmpty && _cPhone.text.trim().length != global.appInfo!.phoneNumberLength)) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_enter_valid_mobile_number);
      } else if (_cAddress.text.trim().isEmpty) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_enter_houseNo);
      } else if (_cLandmark.text.trim().isEmpty) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: '${AppLocalizations.of(context)!.txt_enter_landmark} ');
      } else if (_cPincode.text.trim().isEmpty) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_enter_pincode);
      } else if (_selectedSociety!.societyId == null) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_select_society);
      } else if (_cCity.text.isEmpty) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: ' ${AppLocalizations.of(context)!.txt_select_city}');
      } else if (_cState.text.isEmpty) {
        showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_select_state);
      }
    } catch (e) {
      debugPrint("Exception - add_address_screen.dart - _save():$e");
    }
  }

  Widget _shimmerList() {
    try {
      return ListView.builder(
        itemCount: 7,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 52,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - add_address_screen.dart - _shimmerList():$e");
      return const SizedBox();
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
                  backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                  title: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.hnt_select_society,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
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
                                    List<String> listString = _selectedSociety!.societyName!.split(",");

                                    _cState.text = listString[listString.length - 2];

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
      debugPrint("Exception - add_address_screen.dart - _showSocietySelectDialog():$e");
    }
  }
}
