import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/coupons_model.dart';
import 'package:user/models/order_model.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/payment_screen.dart';
import 'package:user/widgets/coupon_card.dart';
import 'package:user/widgets/toastfile.dart';

class CouponsScreen extends BaseRoute {
  final int? screenId;
  final int? screenIdO;
  final String? cartId;
  final CartController? cartController;

  const CouponsScreen({super.key, 
    super.analytics,
    super.observer,
    super.routeName = 'CouponsScreen',
    this.screenId,
    this.cartId,
    this.cartController,
    this.screenIdO
  });

  @override
  BaseRouteState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends BaseRouteState<CouponsScreen> {
  List<Coupon>? _couponList = [];
  bool _isDataLoaded = false;
  final Color color = const Color(0xffFF0000);
  GlobalKey<ScaffoldState>? _scaffoldKey;
  String? _selectedCouponCode;
  Order? order;

  _CouponsScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
        actions: [
          global.cartCount > 0
              ? FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  heroTag: null,
                  mini: true,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CartScreen(analytics: widget.analytics, observer: widget.observer),
                      ),
                    );
                  },
                  child: badges.Badge(
                    badgeContent: Text(
                      "${global.cartCount}",
                      style: const TextStyle(color: Colors.white, fontSize: 08),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      padding: EdgeInsets.all(6),
                      badgeColor: Colors.red,
                    ),
                    child: Icon(
                      MdiIcons.shoppingOutline,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              : const SizedBox(),
          const SizedBox(
            width: 15,
          ),
        ],
        // backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "${AppLocalizations.of(context)!.lbl_my_coupons}  ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isDataLoaded
          ? _couponList != null && _couponList!.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await _onRefresh();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        itemCount: _couponList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CouponsCard(
                            coupon: _couponList![index],
                            onRedeem: () async {
                              _selectedCouponCode =
                                  _couponList![index].couponCode;
                              setState(() {});
                              if (widget.screenId == 0) {
                                await _applyCoupon();
                              } else {
                                Clipboard.setData(
                                    ClipboardData(text: _selectedCouponCode!));
                                // ScaffoldMessenger.of(context)
                                //     .showSnackBar(SnackBar(
                                //   content: Text(
                                //     '${AppLocalizations.of(context).lbl_code_copied}',
                                //     textAlign: TextAlign.center,
                                //   ),
                                //   duration: Duration(seconds: 2),
                                // ));
                                showToast(AppLocalizations.of(context)!.lbl_code_copied);
                              }
                            },
                          );
                        }),
                  ),
                )
              : Center(
                  child:
                      Text(AppLocalizations.of(context)!.txt_no_coupon_msg),
                )
          : _shimmer(),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _applyCoupon() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.applyCoupon(cartId: widget.cartId, couponCode: _selectedCouponCode)
            .then((result) async {
          if (result != null) {
            if (result.status == "1") {
              order = result.data;
              showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
              Get.to(() => PaymentGatewayScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    cartController: widget.cartController,
                    order: order,
                    screenId: widget.screenIdO,
                totalAmount: order!.remPrice,
                  ));
            } else {
              if(!mounted) return;
              Navigator.of(context).pop();
              order = null;
              showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }

      setState(() {});
    } catch (e) {
      debugPrint("Exception - coupons_screen.dart - _applyCoupon():$e");
    }
  }

  _getCouponsList() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (widget.screenId == 0) {
          await apiHelper.getCoupons(cartId: widget.cartId).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                _couponList = result.data;
              }
            }
          });
        } else {
          await apiHelper.getStoreCoupons().then((result) async {
            if (result != null) {
              if (result.status == "1") {
                _couponList = result.data;
              }
            }
          });
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }

      setState(() {});
    } catch (e) {
      debugPrint("Exception - coupons_screen.dart - _getCouponsList():$e");
    }
  }

  _init() async {
    try {
      await _getCouponsList();
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - coupons_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      setState(() {});
      await _init();
    } catch (e) {
      debugPrint("Exception - coupons_screen.dart - _onRefresh():$e");
    }
  }

  _shimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 4,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.18,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(
                      elevation: 0,
                    ));
              })),
    );
  }
}
