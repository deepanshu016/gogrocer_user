import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/app_setting_model.dart';
import 'package:user/models/businessLayer/base_route.dart';

class SettingScreen extends BaseRoute {
  const SettingScreen({super.key, super.analytics, super.observer, super.routeName = 'SettingScreen'});

  @override
  BaseRouteState createState() => _SettingScreenState();
}

class _SettingScreenState extends BaseRouteState {
  bool isFavourite = false;
  bool isSmsEnable = true;
  bool isInAppEnable = true;
  bool isEmailEnable = true;
  bool _isDataLoaded = false;
  int selectedLanguage = 0;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  AppSetting? _appSetting = AppSetting();

  _SettingScreenState() : super();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${AppLocalizations.of(context)!.btn_app_setting} ",
          style: textTheme.titleLarge,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: SafeArea(
        child: _isDataLoaded
            ? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  child: SwitchListTile(
                    value: _appSetting?.sms ?? false,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) async {
                      _appSetting?.sms = val;
                      bool isSuccessfull = await updateAppSetting();
                      hideLoader();
                      if (!isSuccessfull) {
                        _appSetting?.sms = !(_appSetting?.sms ?? false);
                        if(!context.mounted) return;
                        showSnackBar(key: _scaffoldKey, snackBarMessage: '${AppLocalizations.of(context)!.txt_something_went_wrong} ');
                      }

                      setState(() {});
                    },
                    title: Text(
                      "${AppLocalizations.of(context)!.lbl_sms} ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Card(
                    child: SwitchListTile(
                      value: _appSetting?.app ?? false,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) async {
                        _appSetting?.app = val;
                        bool isSuccessfull = await updateAppSetting();
                        hideLoader();
                        if (!isSuccessfull) {
                          _appSetting!.app = !(_appSetting?.app ?? false);
                          if(!context.mounted) return;
                          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_something_went_wrong);
                        }

                        setState(() {});
                      },
                      title: Text(
                        "${AppLocalizations.of(context)!.lbl_inapp} ",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Card(
                    child: SwitchListTile(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: _appSetting?.email ?? false,
                      onChanged: (val) async {
                        _appSetting?.email = val;
                        bool isSuccessfull = await updateAppSetting();
                        hideLoader();
                        if (!isSuccessfull) {
                          _appSetting?.email = !(_appSetting?.email ?? false);
                          if(!context.mounted) return;
                          showSnackBar(key: _scaffoldKey, snackBarMessage: ' ${AppLocalizations.of(context)!.txt_something_went_wrong}');
                        }
                        setState(() {});
                      },
                      title: Text(
                        " ${AppLocalizations.of(context)!.lbl_email}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
            : _shimmerWidget(),
      )
    );
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<bool> updateAppSetting() async {
    bool isSuccessFullyUpdated = false;
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.updateAppSetting(_appSetting!).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              isSuccessFullyUpdated = true;
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
      return isSuccessFullyUpdated;
    } catch (e) {
      debugPrint("Exception - app_setting_screen.dart - updateAppSetting()$e");
      return isSuccessFullyUpdated;
    }
  }

  _init() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getAppSetting().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _appSetting = result.data;
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - app_setting_screen.dart- _init():$e");
    }
  }

  Widget _shimmerWidget() {
    try {
      return ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 8, bottom: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
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
      debugPrint("Exception - app_setting_screen.dart - _shimmerWidget():$e");
      return const SizedBox();
    }
  }
}
