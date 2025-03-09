import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/models/order_model.dart';
import 'package:user/screens/rate_order_screen.dart';
import 'package:user/theme/style.dart';

class OrderDetailsCard extends StatefulWidget {
  final Order? order;
  final dynamic analytics;
  final dynamic observer;
  const OrderDetailsCard(this.order, {super.key, this.analytics, this.observer});

  @override
  State<OrderDetailsCard> createState() => _OrderDetailsCardState();
}

class OrderedProductsMenuItem extends StatefulWidget {
  final Product product;

  const OrderedProductsMenuItem({super.key, 
    required this.product,
  });

  @override
  State<OrderedProductsMenuItem> createState() => _OrderedProductsMenuItemState();
}

class _OrderDetailsCardState extends State<OrderDetailsCard> {

  _OrderDetailsCardState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.lbl_items,
                style: textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.order!.productList.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OrderedProductsMenuItem(product: widget.order!.productList[index]),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${widget.order!.productList[index].qty}",
                                  style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  ' | ',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Text(
                                  "${global.appInfo!.currencySign} ${widget.order!.productList[index].price}",
                                  style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            widget.order!.orderStatus == "Completed"
                                ? widget.order!.productList[index].userRating != null && widget.order!.productList[index].userRating!.toDouble() > 0.0
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: RatingBar.builder(
                                              initialRating: widget.order!.productList[index].userRating != null ? double.parse(widget.order!.productList[index].userRating.toString()).toDouble() : 0,
                                              minRating: 0,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              ignoreGestures: true,
                                              itemCount: 5,
                                              itemSize: 15,
                                              itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              updateOnDrag: false,
                                              onRatingUpdate: (double value) {},
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: SizedBox(
                                              height: 25,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Get.to(() => RateOrderScreen(
                                                      widget.order,
                                                          index,
                                                          analytics: widget.analytics,
                                                          observer: widget.observer,
                                                        ));
                                                  },
                                                  child: Text(AppLocalizations.of(context)!.btn_edit_review, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white, fontSize: 13))),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: SizedBox(
                                          height: 25,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Get.to(() => RateOrderScreen(
                                                  widget.order,
                                                      index,
                                                      analytics: widget.analytics,
                                                      observer: widget.observer,
                                                    ));
                                              },
                                              child: Text(AppLocalizations.of(context)!.btn_write_review, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white, fontSize: 13))),
                                        ),
                                      )
                                : const SizedBox(),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
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
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.txt_discount_price,
                    style: textTheme.bodyLarge,
                  ),
                  Text(
                    widget.order!.discountonmrp != null && widget.order!.discountonmrp! > 0 ? "- ${global.appInfo!.currencySign} ${widget.order!.discountonmrp!.toStringAsFixed(2)}" : '${global.appInfo!.currencySign} 0',
                    style: textTheme.titleSmall,
                  )
                ],
              ),
            ),
            Padding(
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
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.txt_coupon_discount,
                    style: textTheme.bodyLarge,
                  ),
                  Text(
                    widget.order!.couponDiscount != null && widget.order!.couponDiscount! > 0 ? "- ${global.appInfo!.currencySign} ${widget.order!.couponDiscount!.toStringAsFixed(2)}" : '${global.appInfo!.currencySign} 0',
                    style: textTheme.titleSmall,
                  )
                ],
              ),
            ),
            Padding(
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
            Padding(
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
              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Amount",
                    style: textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  Text(
                    "${global.appInfo!.currencySign} ${(widget.order!.priceWithoutDelivery! - widget.order!.couponDiscount!).toStringAsFixed(2)}",
                    style: textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primary),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.lbl_paid_by_wallet,
                    style: textTheme.bodyLarge,
                  ),
                  Text(
                    "-${global.appInfo!.currencySign} ${widget.order!.paidByWallet!.toStringAsFixed(2)}",
                    style: textTheme.titleSmall,
                  )
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Remaining Amount\n(Paid Online/COD)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${global.appInfo!.currencySign} ${widget.order!.remPrice!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderedProductsMenuItemState extends State<OrderedProductsMenuItem> {

  _OrderedProductsMenuItemState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: 100 * screenHeight / 830,
      child: Card(
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: global.appInfo!.imageUrl! + widget.product.varientImage!,
              imageBuilder: (context, imageProvider) => Container(
                color: const Color(0xffF7F7F7),
                padding: const EdgeInsets.all(5),
                child: Container(
                  height: 80,
                  width: 40,
                  decoration: BoxDecoration(color: const Color(0xffF7F7F7), image: DecorationImage(image: imageProvider, fit: BoxFit.contain)),
                ),
              ),
              placeholder: (context, url) => const SizedBox(height: 80, width: 40, child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => SizedBox(
                height: 80,
                width: 40,
                child: Icon(
                  Icons.image,
                  color: Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    widget.product.productName!,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: 140,
                  child: Text(
                    widget.product.description != null && widget.product.description != '' ? widget.product.description! : widget.product.type!,
                    overflow: TextOverflow.ellipsis,
                    style: normalCaptionStyle(context),
                  ),
                ),
                Text(
                  '${widget.product.quantity} ${widget.product.unit}',
                  overflow: TextOverflow.ellipsis,
                  style: normalCaptionStyle(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
