import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;

class ContactUsScreen extends BaseRoute {
  const ContactUsScreen({super.key, super.analytics, super.observer, super.routeName = 'ContactUsScreen'});
  @override
  BaseRouteState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends BaseRouteState {
  final _cFeedback = TextEditingController();
  final _fFeedback = FocusNode();
  GlobalKey<ScaffoldState>? _scaffoldKey;
  final List<String?> _storeName = ['Admin'];
  String? _selectedStore = 'Admin';
  _ContactUsScreenState() : super();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.tle_contact_us} ", style: textTheme.titleLarge),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  value: _selectedStore,
                  items: _storeName
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(label.toString(), style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          ))
                      .toList(),
                  hint: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      '${AppLocalizations.of(context)!.lbl_select_store} ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedStore = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 35,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      AppLocalizations.of(context)!.lbl_callback_desc,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () async {
                          await _sendCallbackRequest();
                        },
                        child: Text(AppLocalizations.of(context)!.btn_callback_request)),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.lbl_contact_desc,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "${AppLocalizations.of(context)!.lbl_your_feedback} ",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                  margin: const EdgeInsets.only(top: 5, bottom: 15),
                  padding: const EdgeInsets.only(),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: _cFeedback,
                    focusNode: _fFeedback,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      hintText: AppLocalizations.of(context)!.txt_type_here,
                      contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: FilledButton(
                onPressed: () async {
                  await _submitFeedBack();
                },
                child: Text(AppLocalizations.of(context)!.btn_submit)),
          ),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    if (global.nearStoreModel!=null && global.nearStoreModel!.id != null) {
      _storeName.insert(0, global.nearStoreModel!.storeName);
    }
  }

  _sendCallbackRequest() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.calbackRequest(_selectedStore == 'Admin' ? null : _selectedStore).then((result) async {
          if (result != null) {
            if(!mounted) return;
            if (result.status == "1") {
              hideLoader();
              showSnackBar(snackBarMessage: '${AppLocalizations.of(context)!.txt_callback_request_sent} ', key: _scaffoldKey);
            } else {
              hideLoader();
              showSnackBar(snackBarMessage: '${AppLocalizations.of(context)!.txt_something_went_wrong}, ${AppLocalizations.of(context)!.txt_please_try_again_after_sometime}', key: _scaffoldKey);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - contact_us_screen.dart - _submitFeedBack():$e");
    }
  }

  _submitFeedBack() async {
    try {
      if (_cFeedback.text.trim().isNotEmpty) {
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          showOnlyLoaderDialog();
          await apiHelper.sendUserFeedback(_cFeedback.text.trim()).then((result) async {
            if (result != null) {
              if(!mounted) return;
              if (result.status == "1") {
                hideLoader();
                showSnackBar(snackBarMessage: AppLocalizations.of(context)!.txt_feedback_sent, key: _scaffoldKey);
              } else {
                hideLoader();
                showSnackBar(snackBarMessage: '${AppLocalizations.of(context)!.txt_something_went_wrong}, ${AppLocalizations.of(context)!.txt_please_try_again_after_sometime}', key: _scaffoldKey);
              }
            }
          });
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      } else {
        showSnackBar(snackBarMessage: AppLocalizations.of(context)!.txt_enter_feedback, key: _scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - contact_us_screen.dart - _submitFeedBack():$e");
    }
  }
}
