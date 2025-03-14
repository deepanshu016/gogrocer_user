import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/inputFormaters/card_month_input_formatter.dart';
import 'package:user/inputFormaters/card_number_input_formatter.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/card_model.dart';
import 'package:user/models/membership_model.dart';
import 'package:user/models/order_model.dart';
import 'package:user/screens/coupons_screen.dart';
import 'package:user/screens/home_screen.dart';
import 'package:user/screens/order_confirmation_screen.dart';
import 'package:user/screens/stripe_payment_screen.dart';
import 'package:user/utils/navigation_utils.dart';

class PaymentGatewayScreen extends BaseRoute {
  final int? screenId;
  double? totalAmount;
  final MembershipModel? membershipModel;
  final Order? order;
  final CartController? cartController;

  PaymentGatewayScreen({super.key, super.analytics, super.observer, super.routeName = 'PaymentGatewayScreen', this.screenId, this.totalAmount, this.membershipModel, this.order, this.cartController});
  @override
  BaseRouteState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends BaseRouteState<PaymentGatewayScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;

  late Razorpay _razorpay;
  bool _isDataLoaded = false;
  var payPlugin = PaystackPlugin();
  final TextEditingController _cCardNumber = TextEditingController();
  final TextEditingController _cExpiry = TextEditingController();
  final TextEditingController _cCvv = TextEditingController();
  final TextEditingController _cName = TextEditingController();

  int? _month;
  int? _year;
  String? number;
  CardType? cardType;
  int _isWallet = 0;
  final _formKey = GlobalKey<FormState>();
  final bool _autovalidate = false;
  bool isLoading = false;

  _PaymentGatewayScreenState() : super();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle subHeadingStyle = textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic object) async {
        exitAppDialog();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.lbl_payment_method,
            style: textTheme.titleLarge,
          ),
          actions: [
            InkWell(
                onTap: () {
                  Get.to(() => HomeScreen(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ))
          ],
        ),
        body: _isDataLoaded
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    global.userProfileController.currentUser!.wallet! > 0 && widget.screenId != 3
                        ? RadioListTile(
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: 1,
                            groupValue: _isWallet,
                            title: Text(
                              AppLocalizations.of(context)!.lbl_wallet,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              '${global.appInfo!.currencySign} ${global.userProfileController.currentUser!.wallet}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            secondary: Icon(
                              MdiIcons.walletOutline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 25,
                            ),
                            toggleable: true,
                            onChanged: (dynamic val) async {
                              // debugPrint(val);
                              // debugPrint(order.remPrice);
                              // _isWallet = val;
                              if(val==null){
                                _isWallet = 0;
                                widget.totalAmount = widget.order!.remPrice;
                              }else{
                                _isWallet = 1;
                                if (global.userProfileController.currentUser!.wallet! >= widget.totalAmount!) {
                                  if (widget.screenId == 2 && widget.membershipModel != null) {
                                    showOnlyLoaderDialog();
                                    await _buyMemberShip('wallet', 'wallet', null);
                                  } else if (widget.screenId == 1 && widget.order != null) {
                                    showOnlyLoaderDialog();
                                    await _orderCheckOut('success', 'wallet', null, null);
                                  }
                                } else {
                                  widget.totalAmount = widget.totalAmount! - global.userProfileController.currentUser!.wallet!;
                                }
                              }
                              setState(() {});
                              // }
                            })
                        : const SizedBox(),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : ListTile(
                            contentPadding: const EdgeInsets.only(left: 10, right: 10),
                            title: Text(
                              AppLocalizations.of(context)!.txt_pay_on_delivery,
                              style: subHeadingStyle,
                            ),
                          ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : ListTile(
                            onTap: () async {
                              if (widget.screenId == 1 && widget.order != null) {
                                showOnlyLoaderDialog();
                                await _orderCheckOut('success', 'COD', null, null);
                              }

                              setState(() {});
                            },
                            leading: Icon(
                              FontAwesomeIcons.wallet,
                              size: 25,
                              color: Colors.green[500],
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.lbl_cash,
                              style: textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context)!.txt_pay_through_cash,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : ListTile(
                            title: Text(
                              AppLocalizations.of(context)!.lbl_other_methods,
                              style: subHeadingStyle,
                            ),
                          ),
                    global.paymentGateway!.razorpay!.razorpayStatus == 'Yes'
                        ? ListTile(
                            onTap: () {
                              showOnlyLoaderDialog();
                              createOrderId();
                            },
                            leading: Image.asset(
                              'assets/images/razorpay.png',
                              height: 25,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.lbl_rezorpay,
                              style: textTheme.bodyLarge,
                            ),
                          )
                        : const SizedBox(),
                    global.paymentGateway!.stripe!.stripeStatus == 'Yes'
                        ? ListTile(
                            onTap: () {
                              _cardDialog();
                            },
                            leading: Image.asset(
                              'assets/images/stripe.png',
                              height: 20,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.lbl_stripe,
                              style: textTheme.bodyLarge,
                            ),
                          )
                        : const SizedBox(),
                    global.paymentGateway!.paystack!.paystackStatus == 'Yes'
                        ? ListTile(
                            onTap: () {
                              _cardDialog(paymentCallId: 1);
                            },
                            leading: Image.asset(
                              'assets/images/paystack.png',
                              height: 25,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.lbl_paystack,
                              style: textTheme.bodyLarge,
                            ),
                          )
                        : const SizedBox(),
                    const Divider(),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  NavigationUtils.createAnimatedRoute(
                                    1.0,
                                    CouponsScreen(
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                      screenId: 0,
                                      screenIdO: widget.screenId,
                                      cartId: widget.order!.cartid,
                                      cartController: widget.cartController,
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.local_offer_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                label: Text(
                                  AppLocalizations.of(context)!.txt_apply_coupon_code,
                                  style: textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: widget.screenId! > 1 ? 0 : 50,
                    ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.txt_items_in_cart,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(
                                  "${widget.cartController!.cartItemsList!.totalItems}",
                                  style: textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.txt_total_price,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(
                                  "${global.appInfo!.currencySign} ${widget.order!.totalProductsMrp!.toStringAsFixed(2)}",
                                  style: textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.txt_discount_price,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(
                                  "${global.appInfo!.currencySign} ${widget.order!.discountonmrp!.toStringAsFixed(2)}",
                                  style: textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Discounted Price",
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${global.appInfo!.currencySign} ${widget.order!.priceWithoutDelivery!.toStringAsFixed(2)}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.txt_coupon_discount,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(
                                  widget.order!.couponDiscount != null && widget.order!.couponDiscount! > 0 ? "- ${global.appInfo!.currencySign} ${widget.order!.couponDiscount!.toStringAsFixed(2)}" : '- ${global.appInfo!.currencySign}0',
                                  style: textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.txt_delivery_charges,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(
                                  "${global.appInfo!.currencySign} ${widget.order!.deliveryCharge!.toStringAsFixed(2)}",
                                  style: textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                    widget.screenId! > 1
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.txt_tax,
                                  style: textTheme.bodyLarge,
                                ),
                                Text(
                                  "${global.appInfo!.currencySign} ${widget.order!.totalTaxPrice!.toStringAsFixed(2)}",
                                  style: textTheme.titleSmall,
                                )
                              ],
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.screenId == 3
                                ? AppLocalizations.of(context)!.lbl_wallet_recharge
                                : widget.screenId == 2
                                    ? AppLocalizations.of(context)!.tle_subscription
                                    : AppLocalizations.of(context)!.lbl_total_amount,
                            style: textTheme.bodyLarge,
                          ),
                          Text(
                            "${global.appInfo!.currencySign} ${widget.totalAmount}",
                            style: textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              )
            : _productShimmer(),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).colorScheme.primary,
          child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                    children: [
                      TextSpan(text: AppLocalizations.of(context)!.lbl_total_amount),
                      TextSpan(
                        text: ' ${global.appInfo!.currencySign} ${widget.totalAmount}',
                        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void createOrderId() async {
    var trasnId = 'order_trn_${DateTime.now().millisecond}';
    var authn = 'Basic ${base64Encode(utf8.encode('${global.paymentGateway!.razorpay!.razorpayKey}:${global.paymentGateway!.razorpay!.razorpaySecret}'))}';
    Map<String, String> headers = {
      'Authorization': authn,
      'Content-Type': 'application/json'
    };

    var body = {
      'amount': _amountInPaise(widget.totalAmount!),
      'currency': 'INR',
      'receipt': trasnId,
      'payment_capture': true,
    };

    //
    Client()
        .post(global.orderApiRazorpay, body: jsonEncode(body), headers: headers)
        .then((value) {
      // debugPrint('orderid data - ${value.body}');
      var jsData = jsonDecode(value.body);
      Timer(const Duration(seconds: 1), () async {
        openCheckout(jsData['id']);
      });
    }).catchError((e) {
      debugPrint(e);
      hideLoader();
    });
  }

  void openCheckout(dynamic orderId) async {
    Map<String, Object?> options;

    options = {
      'key': global.paymentGateway!.razorpay!.razorpayKey,
      'amount': _amountInPaise(widget.totalAmount!),
      'name': "${global.currentUser!.name}",
      'prefill': {'contact': global.currentUser!.userPhone, 'email': global.currentUser!.email},
      'currency': 'INR'
    };

    try {
      hideLoader();
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void payStack(String? key) async {
    try {
      payPlugin.initialize(publicKey: global.paymentGateway!.paystack!.paystackPublicKey!).then((value) {
        _startAfreshCharge(widget.totalAmount!.toInt() * 100);
      }).catchError((e) {
        debugPrint("Exception - internal error - paymentGatewaysScreen.dart - payStatck(): $e");
      });
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart - payStatck(): $e");
    }
  }

  _orderCheckOut(String paymentStatus, String paymentMethod, String? paymentId, String? paymentGateway) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.checkout(cartId: widget.order!.cartid, paymentStatus: paymentStatus, paymentMethod: paymentMethod, wallet: _isWallet == 1 ? 'yes' : 'no', paymentId: paymentId, paymentGateway: paymentGateway).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _getAppInfo();
              // if (_isWallet == 1) {
              //   if (global.userProfileController.currentUser.wallet >= totalAmount) {
              //     global.userProfileController.currentUser.wallet = global.userProfileController.currentUser.wallet - totalAmount;
              //   } else {
              //     global.userProfileController.currentUser.wallet = 0;
              //   }
              // }
              // hideLoader();
              // Get.to(() => OrderConfirmationScreen(
              //       a: widget.analytics,
              //       o: widget.observer,
              //       order: order,
              //       screenId: 1,
              //     ));
            } else {
              hideLoader();
              showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          } else {
            hideLoader();
            showSnackBar(key: _scaffoldKey, snackBarMessage: 'Something went wrong. Please try again later.');
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - paymentGatewayScreen.dart - _orderCheckOut():$e");
    }
  }

  _getAppInfo() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getAppInfo().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.appInfo = result.data;
              global.userProfileController.currentUser!.wallet = global.appInfo!.userwallet;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - splash_screen.dart - _getAppInfo():$e");
    }finally{
      hideLoader();
      Get.to(() => OrderConfirmationScreen(
        analytics: widget.analytics,
        observer: widget.observer,
        order: widget.order,
        screenId: 1,
      ));
    }
  }

  stripe({int? amount, required CardModel card, String? currency}) async {
    Map<String, dynamic>? customers;
    try {
      customers = await StripeService.createCustomer(email: global.currentUser!.email);

      var paymentMethodsObject = await StripeService.createPaymentMethod(card);

      var paymentIntent = await StripeService.createPaymentIntent(amount, currency, customerId: customers?["id"]);
      var response = await StripeService.confirmPaymentIntent(paymentIntent?["id"], paymentMethodsObject?["id"]);
      if (response?["status"] == 'succeeded') {
        if (widget.screenId == 2 && widget.membershipModel != null) {
          await _buyMemberShip('success', 'stripe', '${response?["id"]}');
        } else if (widget.screenId == 1 && widget.order != null) {
          await _orderCheckOut('success', 'stripe', '${response?["id"]}', 'stripe');
        } else if (widget.screenId == 3) {
          await _rechargeWallet('success', 'stripe', '${response?["id"]}');
        }
      } else {
        bool isConnected = await br.checkConnectivity();
        if (isConnected) {
          if (widget.screenId == 2 && widget.membershipModel != null) {
            await _buyMemberShip('failed', 'stripe', null);
          } else if (widget.screenId == 1 && widget.order != null) {
            await _orderCheckOut('failed', 'stripe', null, 'stripe');
          } else if (widget.screenId == 3) {
            await _rechargeWallet('failed', 'stripe', null);
          }
          _tryAgainDialog(stripe);
          setState(() {});
        } else {
          showNetworkErrorSnackBar(_scaffoldKey);
        }
      }
    } on PlatformException catch (err) {
      debugPrint('Platfrom Exception: paymentGatewaysScreen.dart -  stripe() : ${err.toString()}');
    } catch (err) {
      debugPrint('Exception: paymentGatewaysScreen.dart -  stripe() : ${err.toString()}');
      if(!mounted) return;
      return StripeTransactionResponse(message: '${AppLocalizations.of(context)!.lbl_transaction_failed}: ${err.toString()}', success: false);
    }
  }

  String _amountInPaise(double amount) {
    try {
      double x = amount * 100;
      return x.toString();
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart - _amountInPaise():$e");
      return '0';
    }
  }

  _buyMemberShip(String buyStatus, String paymentGateway, String? transactionId) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.buyMembership(buyStatus, paymentGateway, transactionId, widget.membershipModel!.planId).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              if (_isWallet == 1) {
                if (global.userProfileController.currentUser!.wallet! >= widget.totalAmount!) {
                  global.userProfileController.currentUser!.wallet = global.userProfileController.currentUser!.wallet! - widget.totalAmount!;
                } else {
                  global.userProfileController.currentUser!.wallet = 0;
                }
              }
              await global.userProfileController.getMyProfile();
              hideLoader();
              Get.to(() => OrderConfirmationScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    order: widget.order,
                    screenId: 2,
                  ));
            } else if (result.status == '5') {
              await global.userProfileController.getMyProfile();
              hideLoader();
              Get.to(() => OrderConfirmationScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    order: widget.order,
                    screenId: 2,
                    status: 5,
                  ));
            } else {
              hideLoader();
              showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - paymentGatewayScreen.dart - _buyMemberShip():$e");
    }
  }

  _rechargeWallet(String rechargeStatus, String paymentGateway, String? paymentId) async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.rechargeWallet(rechargeStatus, widget.totalAmount!, paymentId, paymentGateway).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.userProfileController.currentUser!.wallet = global.userProfileController.currentUser!.wallet! + widget.totalAmount!;
              hideLoader();
              Get.to(() => OrderConfirmationScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                    order: widget.order,
                    screenId: 3,
                  ));
            } else {
              hideLoader();
              showSnackBar(key: _scaffoldKey, snackBarMessage: '${result.message}');
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - paymentGatewayScreen.dart - _rechargeWallet():$e");
    }
  }

  _cardDialog({int? paymentCallId}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => AlertDialog(
                    backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(
                      AppLocalizations.of(context)!.lbl_card_Details,
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              child: Text(AppLocalizations.of(context)!.btn_close)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  _save(paymentCallId);
                                },
                                child: Text(AppLocalizations.of(context)!.lbl_pay)),
                          )
                        ],
                      )
                    ],
                    content: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              style: Theme.of(context).textTheme.titleMedium,
                              controller: _cCardNumber,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(16),
                                CardNumberInputFormatter(),
                              ],
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                                hintText: AppLocalizations.of(context)!.lbl_card_number,
                                prefixIcon: const Icon(
                                  Icons.credit_card,
                                ),
                              ),
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.number,
                              onSaved: (String? value) {
                                number = br.getCleanedNumber(value!);
                              },
                              // ignore: missing_return
                              validator: (input) {
                                if (input!.isEmpty) {
                                  return AppLocalizations.of(context)!.txt_enter_your_card_number;
                                }

                                input = br.getCleanedNumber(input);

                                if (input.length < 8) {
                                  return AppLocalizations.of(context)!.txt_enter_valid_card_number;
                                }

                                int sum = 0;
                                int length = input.length;
                                for (var i = 0; i < length; i++) {
                                  // get digits in reverse order
                                  int digit = int.parse(input[length - i - 1]);

                                  // every 2nd number multiply with 2
                                  if (i % 2 == 1) {
                                    digit *= 2;
                                  }
                                  sum += digit > 9 ? (digit - 9) : digit;
                                }

                                if (sum % 10 == 0) {
                                  return null;
                                }

                                return AppLocalizations.of(context)!.txt_enter_valid_card_number;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    style: Theme.of(context).textTheme.titleMedium,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(4),
                                      CardMonthInputFormatter(),
                                    ],
                                    controller: _cExpiry,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                                      contentPadding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                                      prefixIcon: const Icon(
                                        Icons.date_range,
                                      ),
                                      hintText: AppLocalizations.of(context)!.hnt_valid_through,
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                    keyboardType: TextInputType.number,
                                    onFieldSubmitted: (value) {
                                      List<int> expiryDate = br.getExpiryDate(value);
                                      _month = expiryDate[0];
                                      _year = expiryDate[1];
                                    },
                                    onEditingComplete: () {
                                      List<int> expiryDate = br.getExpiryDate(_cExpiry.text);
                                      _month = expiryDate[0];
                                      _year = expiryDate[1];
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!.txt_enter_your_expiry_date;
                                      }

                                      int year;
                                      int month;
                                      // The value contains a forward slash if the month and year has been
                                      // entered.
                                      if (value.contains(RegExp(r'(/)'))) {
                                        var split = value.split(RegExp(r'(/)'));
                                        // The value before the slash is the month while the value to right of
                                        // it is the year.
                                        month = int.parse(split[0]);
                                        year = int.parse(split[1]);
                                      } else {
                                        // Only the month was entered
                                        month = int.parse(value.substring(0, (value.length)));
                                        year = -1; // Lets use an invalid year intentionally
                                      }

                                      if ((month < 1) || (month > 12)) {
                                        // A valid month is between 1 (January) and 12 (December)
                                        return AppLocalizations.of(context)!.txt_expiry_month_is_invalid;
                                      }

                                      var fourDigitsYear = br.convertYearTo4Digits(year);
                                      if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
                                        // We are assuming a valid should be between 1 and 2099.
                                        // Note that, it's valid doesn't mean that it has not expired.
                                        return AppLocalizations.of(context)!.txt_expiry_year_is_invalid;
                                      }

                                      if (!br.hasDateExpired(month, year)) {
                                        return AppLocalizations.of(context)!.txt_card_has_expired;
                                      }

                                      if(_month == null && _year == null) {
                                        _month = month;
                                        _year = year;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    style: Theme.of(context).textTheme.titleMedium,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    controller: _cCvv,
                                    obscureText: true,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                                      contentPadding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                                      prefixIcon: Icon(
                                        MdiIcons.creditCard,
                                      ),
                                      hintText: AppLocalizations.of(context)!.lbl_cvv,
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return AppLocalizations.of(context)!.lbl_enter_cvv;
                                      } else if (value.length < 3 || value.length > 4) {
                                        return AppLocalizations.of(context)!.txt_cvv_is_invalid;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              style: Theme.of(context).textTheme.titleMedium,
                              controller: _cName,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
                              ],
                              decoration: InputDecoration(
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                                prefixIcon: const Icon(
                                  Icons.person,
                                ),
                                hintText: AppLocalizations.of(context)!.txt_card_holder_name,
                              ),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return null;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
        });
  }

  _chargeCard(Charge charge) async {
    try {
      payPlugin.chargeCard(context, charge: charge).then((value) async {
        if (value.status && value.message == "Success") {
          bool isConnected = await br.checkConnectivity();
          if (isConnected) {
            if (widget.screenId == 2 && widget.membershipModel != null) {
              await _buyMemberShip('success', 'paystack', null);
            } else if (widget.screenId == 1 && widget.order != null) {
              await _orderCheckOut('success', 'paystack', null, 'paystack');
            } else if (widget.screenId == 3) {
              await _rechargeWallet('sucess', 'paystack', null);
            }

            setState(() {});
          } else {
            showNetworkErrorSnackBar(_scaffoldKey);
          }
        } else {
          bool isConnected = await br.checkConnectivity();
          if (isConnected) {
            if (widget.screenId == 2 && widget.membershipModel != null) {
              await _buyMemberShip('failed', 'paystack', null);
            } else if (widget.screenId == 1 && widget.order != null) {
              await _orderCheckOut('failed', 'paystack', null, 'paystack');
            } else if (widget.screenId == 3) {
              await _rechargeWallet('failed', 'paystack', null);
            }
            _tryAgainDialog(payStack);
            setState(() {});
          } else {
            showNetworkErrorSnackBar(_scaffoldKey);
          }
        }
      }).catchError((e) {
        debugPrint("Exception - inner error - paymentGatewaysScreen.dart - paystack - _chargeCard(): $e");
      });
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart - _chargeCard(): $e");
    }
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cCardNumber.text,
      cvc: _cCvv.text,
      expiryMonth: _month,
      expiryYear: _year,
    );
  }

  Future _getPaymentGateways() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getPaymentGateways().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.paymentGateway = result.data;
            } else {
              showSnackBar(key: _scaffoldKey, snackBarMessage: result.message.toString());
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart.dart - _getPaymentGateways():$e");
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    try {
      debugPrint("_handlePaymentError ${response.code} ${response.message}");
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();

        showOnlyLoaderDialog();
        if (widget.screenId == 2 && widget.membershipModel != null) {
          await _buyMemberShip('failed', 'razorpay', null);
        } else if (widget.screenId == 1 && widget.order != null) {
          await _orderCheckOut('failed', 'razorpay', null, 'razorpay');
        } else if (widget.screenId == 3) {
          await _rechargeWallet('failed', 'razorpay', null);
        }

        hideLoader();
        _tryAgainDialog(openCheckout);
        setState(() {});
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
      if(!mounted) return;
      showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.lbl_transaction_failed);
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart -  _handlePaymentError$e");
    }
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      debugPrint("response   -  _handlePaymentSuccess   ${response.orderId} ${response.paymentId}");
      if (response.paymentId != null) {
        showOnlyLoaderDialog();

        if (widget.screenId == 2 && widget.membershipModel != null) {
          await _buyMemberShip('success', 'razorpay', '${response.paymentId}');
        } else if (widget.screenId == 1 && widget.order != null) {
          await _orderCheckOut('success', 'razorpay', '${response.paymentId}', 'razorpay');
        } else if (widget.screenId == 3) {
          await _rechargeWallet('success', 'razorpay', '${response.paymentId}');
        }
      }
    } catch (e) {
      debugPrint("Exception - paymentGetwaysScreen.dart- _handlePaymentSuccess():$e");
    }
  }

  _init() async {
    try {
      await _getPaymentGateways();
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      if (widget.totalAmount != null) {
        if (widget.screenId == 2 && widget.membershipModel != null) {
          widget.totalAmount = widget.membershipModel!.price;
        }
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart.dart - _init():$e");
    }
  }

  Widget _productShimmer() {
    try {
      return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            //      margin: EdgeInsets.only(top: 15, bottom: 8),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: const Card(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - productDetailScreen.dart - _productShimmer():$e");
      return const SizedBox();
    }
  }

  Future _save(int? callId) async {
    try {
      if (_cCardNumber.text.trim().isNotEmpty && _cExpiry.text.trim().isNotEmpty && _cCvv.text.trim().isNotEmpty && _cName.text.trim().isNotEmpty) {
        if (_formKey.currentState!.validate()) {
          bool isConnected = await br.checkConnectivity();
          if (isConnected) {
            showOnlyLoaderDialog();
            CardModel stripeCard = CardModel(
              number: _cCardNumber.text,
              name: _cName.text.trim(),
              expiryMonth: _month,
              expiryYear: _year,
              cvv: _cCvv.text,
            );

            if (callId == 1) {
              payStack(global.paymentGateway!.paystack!.paystackSeckeyKey);
            } else {
              await stripe(card: stripeCard, amount: widget.totalAmount!.toInt() * 100, currency: '${global.appInfo!.paymentCurrency}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart - _save(): $e");
    }
  }

  _startAfreshCharge(int price) async {
    try {
      Charge charge = Charge()
        ..amount = price
        ..email = '${global.currentUser!.email}'
        ..currency = '${global.appInfo!.paymentCurrency}'
        ..card = _getCardFromUI()
        ..reference = _getReference();

      _chargeCard(charge);
    } catch (e) {
      debugPrint("Exception - paymentGatewaysScreen.dart - _startAfreshCharge(): $e");
    }
  }

  _tryAgainDialog(Function onClickAction) {
    try {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return Theme(
              data: ThemeData(dialogBackgroundColor: Colors.white),
              child: CupertinoAlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.lbl_transaction_failed,
                ),
                content: Text(
                  AppLocalizations.of(context)!.txt_please_try_again,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      AppLocalizations.of(context)!.lbl_cancel,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.lbl_try_again),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      showOnlyLoaderDialog();
                      onClickAction();

                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          });
    } catch (e) {
      debugPrint('Exception - paymentGatewaysScreen.dart - _tryAgainDialog(): $e');
    }
  }
}
