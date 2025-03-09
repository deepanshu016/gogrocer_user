import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/add_address_screen.dart';
import 'package:user/widgets/address_info_card.dart';

class ProductRequestScreen extends BaseRoute {
  const ProductRequestScreen({super.key, super.analytics, super.observer, super.routeName = 'ProductRequestScreen'});

  @override
  BaseRouteState createState() => _ProductRequestScreenState();
}

class _ProductRequestScreenState extends BaseRouteState {
  final double height = Get.height;
  final double width = Get.width;
  XFile? tImage;
  Address? _selectedAddress;
  GlobalKey<ScaffoldState>? _scaffoldKey;

  late Timer _timer;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primaryContainer;
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.lbl_make_product_request,
            style: textTheme.titleLarge,
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.keyboard_arrow_left)),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  AppLocalizations.of(context)!.tle_cant_find_product,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: ListTile(
                  onTap: () async {
                    await _showCupertinoModalSheet();
                  },
                  leading: Icon(
                    Icons.cloud_upload_outlined,
                    color: color,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.lbl_upload_image,
                    style: const TextStyle(
                    ),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.txt_choose_image_from_gallery,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: tImage != null
                    ? Container(
                        height: 220,
                        width: 250,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(10), image: DecorationImage(fit: BoxFit.contain, image: FileImage(File(tImage!.path)))),
                      )
                    : Container(
                        height: 220,
                        width: 250,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(10)),
                        child: InkWell(
                          onTap: () async {
                            await _showCupertinoModalSheet();
                          },
                          child: const Center(
                              child: Icon(
                            Icons.file_upload,
                            size: 50,
                          )),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color: color,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.lbl_select_address,
                    style: const TextStyle(
                    ),
                  ),
                ),
              ),
              global.userProfileController.addressList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: global.userProfileController.addressList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: AddressInfoCard(
                            analytics: widget.analytics,
                            observer: widget.observer,
                            key: UniqueKey(),
                            address: global.userProfileController.addressList[index],
                            isSelected: global.userProfileController.addressList[index].isSelected,
                            value: global.userProfileController.addressList[index],
                            groupValue: _selectedAddress,
                            onChanged: (value) {
                              setState(() {
                                _selectedAddress = value;
                                global.userProfileController.addressList[index].isSelected = !global.userProfileController.addressList[index].isSelected;
                              });
                            },
                          ),
                        );
                      })
                  : InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddAddressScreen(Address(), analytics: widget.analytics, observer: widget.observer))).then((value){
                          setState(() { });
                        });
                      },
                      child: SizedBox(
                          height: 150,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_location_alt_sharp),
                              Text(AppLocalizations.of(context)!.tle_add_new_address),
                            ],
                          )))),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: () async {
              await _makeProductRequest();
            },
            child: Container(
              height: height * 0.07,
              width: width * 0.9,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(7)),
              ),
              child: Center(
                  child: Text(
                AppLocalizations.of(context)!.btn_submit,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }


  _makeProductRequest() async {
    try {
      showOnlyLoaderDialog();
      await apiHelper.makeProductRequest(_selectedAddress!.addressId, File(tImage!.path)).then((result) async {
        if (result != null) {
          if (result.status == "1") {
            hideLoader();
            _showProductRequestConfirmationDialog(result.message);
          } else if (result.status == '2') {
            hideLoader();
            _showProductRequestConfirmationDialog(result.message);
          } else {
            hideLoader();
            if(!mounted) return;
            showSnackBar(key: _scaffoldKey, snackBarMessage: '${AppLocalizations.of(context)!.txt_something_went_wrong}.');
          }
        }
      });
    } catch (e) {
      debugPrint("Exception - product_request_screen.dart - _makeProductRequest():$e");
    }
  }

  _showCupertinoModalSheet() {
    try {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(AppLocalizations.of(context)!.lbl_actions),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context)!.lbl_take_picture,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                showOnlyLoaderDialog();
                tImage = await br.openCamera();
                hideLoader();

                setState(() {});
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context)!.txt_upload_image_desc,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                showOnlyLoaderDialog();
                tImage = await br.selectImageFromGallery();
                hideLoader();

                setState(() {});
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context)!.lbl_cancel, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("Exception - product_request_screen.dart - _showCupertinoModalSheet():$e");
    }
  }

  _showProductRequestConfirmationDialog(String? message) {
    return showDialog(
        context: context,
        barrierColor: Colors.grey[300]!.withOpacity(0.5),
        builder: (BuildContext context) {
          _timer = Timer(const Duration(seconds: 5), () {
            Navigator.of(context).pop();
          });
          return SimpleDialog(
            children: [
              SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      message!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )))
            ],
          );
        }).then((val) {
      _timer.cancel();
      Get.back();
    });
  }
}
