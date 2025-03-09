import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/membership_model.dart';
import 'package:user/screens/subscription_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class MemberShipScreen extends BaseRoute {
  const MemberShipScreen({super.key, super.analytics, super.observer, super.routeName = 'MemberShipScreen'});
  @override
  BaseRouteState createState() => _MemberShipScreenState();
}

class _MemberShipScreenState extends BaseRouteState {
  bool isloading = true;

  List<MembershipModel>? _memberShipList = [];

  GlobalKey<ScaffoldState>? _scaffoldKey;

  bool _isDataLoaded = false;
  _MemberShipScreenState() : super();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(
              AppLocalizations.of(context)!.tle_membership,
              style: textTheme.titleLarge,
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.keyboard_arrow_left)),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                  child: Text(AppLocalizations.of(context)!.lbl_choose_plan, style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 35, right: 35, bottom: 15),
                  child: Text(
                    AppLocalizations.of(context)!.txt_membership_desc,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                    child: _isDataLoaded
                        ? _memberShipList!.isNotEmpty
                            ? ListView.builder(
                                itemCount: _memberShipList!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SubscriptionDetailScreen(_memberShipList![index], analytics: widget.analytics, observer: widget.observer),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
                                      width: MediaQuery.of(context).size.width,
                                      height: 100,
                                      child: CachedNetworkImage(
                                        imageUrl: global.appInfo!.imageUrl! + _memberShipList![index].image!,
                                        imageBuilder: (context, imageProvider) => Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            color: Colors.red,
                                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            image: const DecorationImage(image: AssetImage('assets/icon.png'), fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            : Center(
                                child: Text(
                                  AppLocalizations.of(context)!.txt_nothing_to_show,
                                  style: Theme.of(context).primaryTextTheme.bodyLarge,
                                ),
                              )
                        : _shimmerWidget()),
              ],
            ),
          )),
    );
  }


  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getMembershipList().then((result) {
          if (result != null && result.statusCode == 200 && result.status == '1') {
            _memberShipList = result.data;
          }
        });
        _isDataLoaded = true;
        setState(() {});
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - membership_screen.dart - _getData():$e");
    }
  }

  Widget _shimmerWidget() {
    try {
      return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
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
                    height: 100,
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
      debugPrint("Exception - membership_screen.dart - _shimmerWidget():$e");
      return const SizedBox();
    }
  }
}
