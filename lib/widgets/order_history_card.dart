import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/controllers/order_controller.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/order_model.dart';
import 'package:user/screens/cancel_order_screen.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/map_screen.dart';
import 'package:user/screens/order_summary_screen.dart';
import 'package:user/utils/string_formatter.dart';
import 'package:user/widgets/toastfile.dart';

class OrderHistoryCard extends StatefulWidget {
  final Order? order;
  final dynamic analytics;
  final dynamic observer;
  final int? index;

  const OrderHistoryCard({super.key, this.order, this.analytics, this.observer, this.index});

  @override
  State<OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<OrderHistoryCard> {
  final OrderController orderController = Get.find();
  int? index;
  APIHelper apiHelper = APIHelper();
  final CartController cartController = Get.put(CartController());
  List<String?> _productName = [];

  _OrderHistoryCardState();

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.order!.productList.length; i++) {
      _productName.add(widget.order!.productList[i].productName);
    }
    _productName = _productName.toSet().toList();

    TextTheme textTheme = Theme.of(context).textTheme;
    return GetBuilder<OrderController>(
      init: orderController,
      builder: (orderController) => InkWell(
        onTap: () {
          Get.to(() => OrderSummaryScreen(
                analytics: widget.analytics,
                observer: widget.observer,
                order: widget.order,
                orderController: orderController,
              ));
        },
        child: Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Color(0xffF4F4F4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EE, dd MMMM').format(DateTime.parse((widget.order!.productList[0].orderDate).toString())),
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "${global.appInfo!.currencySign} ${(widget.order!.remPrice!+widget.order!.paidByWallet!).toStringAsFixed(2)} >",
                      style: textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 16,
                  ),
                  child: Text(
                    "${AppLocalizations.of(context)!.lbl_order_id}: ${widget.order!.cartid}",
                    style: textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).brightness == Brightness.light? Colors.grey[800] : Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    StringFormatter.convertListItemsToString(_productName)!,
                    style: textTheme.bodySmall!.copyWith(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _orderStatusNotifier(widget.order!, textTheme),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderStatusNotifier(Order order, TextTheme textTheme) {
    if (order.orderStatus == "Pending" || order.orderStatus == "Confirmed") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 5,
                backgroundColor: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                "${('${order.orderStatus}'.toUpperCase()=='PENDING'?'Order Placed':order.orderStatus)}",
                style: textTheme.bodyLarge!.copyWith(color: Colors.blue, fontSize: 15),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Get.to(() => CancelOrderScreen(
                        analytics: widget.analytics,
                        observer: widget.observer,
                        order: order,
                        orderController: orderController,
                      )),
                  child: Text(
                    AppLocalizations.of(context)!.tle_cancel_order,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.grey[600] : Colors.grey[300],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _trackOrder(),
                  child: Text(
                    AppLocalizations.of(context)!.tle_track_order,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    } else if (order.orderStatus == "Out_For_Delivery") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 5,
                backgroundColor: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.lbl_out_of_delivery,
                style: textTheme.bodyLarge!.copyWith(
                  color: Colors.green,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => _trackOrder(),
                  child: Text(
                    AppLocalizations.of(context)!.tle_track_order,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    } else if (order.orderStatus == "Completed") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 5,
                backgroundColor: Colors.purple,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.txt_completed,
                style: textTheme.bodyLarge!.copyWith(
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                global.nearStoreModel != null
                    ? TextButton(
                        onPressed: () {
                          _reOrderItems();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.btn_reorder_items,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : const SizedBox(),
                TextButton(
                  onPressed: () => _trackOrder(),
                  child: Text(
                    AppLocalizations.of(context)!.tle_track_order,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    } else if (order.orderStatus == "Cancelled") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 5,
                backgroundColor: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.lbl_order_cancel,
                style: textTheme.bodyLarge!.copyWith(
                  color: Colors.grey[600],
                ),
              )
            ],
          ),
          TextButton(
            onPressed: () => _trackOrder(),
            child: Text(
              AppLocalizations.of(context)!.tle_track_order,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        ],
      );
    } else {
      return const SizedBox();
    }
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
      debugPrint("Exception - order_history_card.dart - reOrderItems():$e");
    }
  }

  _trackOrder() async {
    try {
      await apiHelper.trackOrder(widget.order!.cartid).then((result) async {
        if (result != null) {
          if (result.status == "1") {
            Order? newOrder = Order();
            newOrder = result.data;
            Get.to(() => MapScreen(
                  newOrder,
                  orderController,
                  analytics: widget.analytics,
                  observer: widget.observer,
                ));
          }
        }
      });
    } catch (e) {
      debugPrint("Exception - order_history_card.dart - _trackOrder():$e");
    }
  }
}
