import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/user_profile_controller.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/add_address_screen.dart';

class AddressListScreen extends BaseRoute {
  const AddressListScreen({super.key, super.analytics, super.observer, super.routeName = 'AddressListScreen'});
  @override
  BaseRouteState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends BaseRouteState {
  bool _isDataLoaded = false;

  GlobalKey<ScaffoldState>? _scaffoldKey;
  _AddressListScreenState() : super();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
        canPop: true,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: const BackButton(),
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.tle_my_address,
              style: textTheme.titleLarge,
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddAddressScreen(Address(), analytics: widget.analytics, observer: widget.observer),
                    ),
                  ).then((value){
                    setState(() { });
                  });
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _isDataLoaded = false;
                setState(() {});
                await _getMyAddressList();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isDataLoaded
                    ? global.userProfileController.addressList.isNotEmpty
                        ? GetBuilder<UserProfileController>(
                            init: global.userProfileController,
                            builder: (value) => ListView.builder(
                              itemCount: global.userProfileController.addressList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(7),
                                    title: Text(
                                      global.userProfileController.addressList[index].type!,
                                      style: textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${global.userProfileController.addressList[index].houseNo}, ${global.userProfileController.addressList[index].landmark}, ${global.userProfileController.addressList[index].society}",
                                          style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => AddAddressScreen(global.userProfileController.addressList[index], analytics: widget.analytics, observer: widget.observer),
                                                    ),
                                                  ).then((value){
                                                    setState(() { });
                                                  });
                                                },
                                                icon: const Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () async {
                                                  await deleteConfirmationDialog(index);
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Theme.of(context).colorScheme.primary,
                                                )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(AppLocalizations.of(context)!.txt_no_address),
                          )
                    : _shimmerList(),
              ),
            ),
          ),
        ));
  }

  Future deleteConfirmationDialog(int index) async {
    try {
      await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => Theme(
          data: ThemeData(dialogBackgroundColor: Colors.white),
          child: CupertinoAlertDialog(
            title: Text(
              " ${AppLocalizations.of(context)!.tle_delete_address} ",
            ),
            content: Text(
              "${AppLocalizations.of(context)!.lbl_delete_address_desc}  ",
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  AppLocalizations.of(context)!.btn_ok,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  showOnlyLoaderDialog();
                  await _removeAddress(index);
                },
              ),
              CupertinoDialogAction(
                child: Text("${AppLocalizations.of(context)!.lbl_cancel} "),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint("Exception - address_list_screen.dart - deleteConfirmationDialog():$e");
      return false;
    }
  }


  @override
  void initState() {
    super.initState();
    _getMyAddressList();
  }

  _getMyAddressList() async {
    try {
      if (global.nearStoreModel != null) {
        await global.userProfileController.getUserAddressList();
      }
      if (global.userProfileController.isDataLoaded.value == true) {
        _isDataLoaded = true;
      } else {
        _isDataLoaded = false;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Exception - address_list_screen.dart - _getMyAddressList():$e");
    }
  }

  _removeAddress(int index) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        global.userProfileController.removeUserAddress(index);
        hideLoader();
      } else {
        hideLoader();
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - address_list_screen.dart - _removeAddress():$e");
    }
  }

  Widget _shimmerList() {
    try {
      return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(
              top: 8,
            ),
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
                    height: 112,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                  const Divider(),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - address_list_screen.dart - _shimmerList():$e");
      return const SizedBox();
    }
  }
}
