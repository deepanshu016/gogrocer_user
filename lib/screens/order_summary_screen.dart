import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:user/controllers/order_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/order_model.dart';
import 'package:user/screens/cancel_order_screen.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/map_screen.dart';
import 'package:user/widgets/bottom_button.dart';
import 'package:user/widgets/delivery_details.dart';
import 'package:user/widgets/order_details_card.dart';
import 'package:user/widgets/order_status_card.dart';
import 'package:user/widgets/toastfile.dart';

class OrderSummaryScreen extends BaseRoute {
  final Order? order;
  final OrderController? orderController;
  const OrderSummaryScreen({super.key, super.analytics, super.observer, super.routeName = 'OrderSummaryScreen', this.order, this.orderController});
  @override
  BaseRouteState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends BaseRouteState<OrderSummaryScreen> {
  int? screenId;
  GlobalKey<ScaffoldState>? _scaffoldKey;

  _OrderSummaryScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.tle_order_summary,
          style: textTheme.titleLarge,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              OrderStatusCard(widget.order),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: OrderDetailsCard(
                  widget.order,
                  analytics: widget.analytics,
                  observer: widget.observer,
                ),
              ),
              DeliveryDetails(
                order: widget.order,
                address: widget.order!.deliveryAddress,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: BottomButton(
                  loadingState: false,
                  disabledState: false,
                  onPressed: () {
                    _trackOrder();
                  },
                  child: Text(AppLocalizations.of(context)!.tle_track_order),
                ),
              ),
              widget.order!.orderStatus == 'Pending' || widget.order!.orderStatus == 'Completed' || widget.order!.orderStatus == 'Confirmed'
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: BottomButton(
                        loadingState: false,
                        disabledState: false,
                        onPressed: () {
                          if (widget.order!.orderStatus == 'Pending' || widget.order!.orderStatus == 'Confirmed') {
                            Get.to(() => CancelOrderScreen(
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                  order: widget.order,
                                  orderController: widget.orderController,
                                ));
                          } else {
                            // reorder
                            _reOrderItems();
                          }
                        },
                        child: Text(
                          widget.order!.orderStatus == 'Pending' || widget.order!.orderStatus == 'Confirmed' ? AppLocalizations.of(context)!.tle_cancel_order : AppLocalizations.of(context)!.btn_re_order,
                        ),
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(width: 32),
            ],
          ),
        ),
      ),
    );
  }


  _reOrderItems() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
      await apiHelper.reOrder(widget.order!.cartid).then((result) async {
        if (result != null) {
          if(!mounted) return;
          if (result.status == "1") {
            Navigator.of(context).pop();
            Get.to(() => CartScreen(
                  analytics: widget.analytics,
                  observer: widget.observer,
                ));
          } else {
            Navigator.of(context).pop();
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content: Text(
            //     '${AppLocalizations.of(context).txt_something_went_wrong}.',
            //     textAlign: TextAlign.center,
            //   ),
            //   duration: Duration(seconds: 2),
            // ));
            showToast(AppLocalizations.of(context)!.txt_something_went_wrong);
          }
        }
      });
      setState(() {});
    } catch (e) {
      debugPrint("Exception -  order_summary_screen.dart - reOrderItems():$e");
    }
  }

  _trackOrder() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.trackOrder(widget.order!.cartid).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              Order? newOrder = Order();
              newOrder = result.data;
              Get.to(() => MapScreen(
                    newOrder,
                widget.orderController,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  ));
            } else {
              showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - order_summary_screen.dart - _trackOrder():$e");
    }
  }
}
