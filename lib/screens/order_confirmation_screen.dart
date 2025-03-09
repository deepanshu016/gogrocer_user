import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/order_model.dart';
import 'package:user/screens/home_screen.dart';

class OrderConfirmationScreen extends BaseRoute {
  final int? screenId;
  final Order? order;
  final int? status;

  const OrderConfirmationScreen({super.key, super.analytics, super.observer, super.routeName = 'OrderConfirmationScreen', this.order, this.screenId, this.status});

  @override
  BaseRouteState<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends BaseRouteState<OrderConfirmationScreen> {

  _OrderConfirmationScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: screenHeight * 0.3,
          ),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  widget.status == 5 ? Icons.info : Icons.check,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                widget.screenId == 3
                    ? AppLocalizations.of(context)!.txt_wallet_recharge_successfully
                    : widget.screenId == 0
                        ? AppLocalizations.of(context)!.txt_reward_to_wallet
                        : widget.screenId == 2
                            ? widget.status == 5
                                ? AppLocalizations.of(context)!.tle_membership_expiry
                                : "${AppLocalizations.of(context)!.tle_membership_bought_sucessfully} "
                            : AppLocalizations.of(context)!.txt_order_success_description,
                style: textTheme.titleLarge,
              ),
            ),
          ),
          widget.screenId == 3 || widget.screenId == 0 || widget.screenId == 2
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    "${AppLocalizations.of(context)!.lbl_order_id}:  #${widget.order!.cartid}",
                    style: textTheme.bodySmall!.copyWith(fontSize: 17),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(AppLocalizations.of(context)!.btn_go_home),
                  ),
                  onPressed: () {
                    if (widget.screenId != 1 || widget.screenId != 0 || widget.screenId != 2) {
                      global.cartCount = 0;
                    }

                    Get.offAll(() => HomeScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ));
                    setState(() {});
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
