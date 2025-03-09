import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user/models/order_model.dart';

class OrderStatusCard extends StatefulWidget {
  final Order? order;
  const OrderStatusCard(this.order, {super.key});

  @override
  State<OrderStatusCard> createState() => _OrderStatusCardState();
}

class _OrderStatusCardState extends State<OrderStatusCard> {
  _OrderStatusCardState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.lbl_order_id} #${widget.order!.cartid}",
                  style: textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.order!.completedTime != null && widget.order!.orderStatus == 'Completed' ? "Delivered at ${widget.order!.completedTime}" : '',
                    style: textTheme.bodySmall,
                  ),
                ),
                SizedBox(height: widget.order!.completedTime != null && widget.order!.orderStatus == 'Completed' ? 32 : 0),
                Text(
                  AppLocalizations.of(context)!.lbl_payment_method,
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "${((widget.order!.paymentMethod!=null && '${widget.order!.paymentMethod}'.toUpperCase()=='COD')?'Pay Cash':widget.order!.paymentMethod)}",
                    style: textTheme.bodySmall!.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              radius: 10,
              backgroundColor: widget.order!.orderStatus == 'Pending'
                  ? Colors.blue
                  : widget.order!.orderStatus == 'Confirmed'
                      ? Colors.amber
                      : widget.order!.orderStatus == 'Out_For_Delivery'
                          ? Colors.green
                          : widget.order!.orderStatus == 'Completed'
                              ? Colors.purple
                              : Colors.grey,
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${('${widget.order!.orderStatus}'.toUpperCase()=='PENDING'?'Order Placed':widget.order!.orderStatus)}",
              style: textTheme.bodyLarge!.copyWith(
                  color: widget.order!.orderStatus == 'Pending'
                      ? Colors.amber
                      : widget.order!.orderStatus == 'Confirmed'
                          ? Colors.amber
                          : widget.order!.orderStatus == 'Out_For_Delivery'
                              ? Colors.green
                              : widget.order!.orderStatus == 'Completed'
                                  ? Colors.purple
                                  : Colors.grey,
                  fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
