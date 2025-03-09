import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user/models/order_model.dart';

class DeliveryDetails extends StatefulWidget {
  final Order? order;
  final String? address;
  const DeliveryDetails({super.key, this.order, this.address});

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {

  _DeliveryDetailsState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xffF4F4F4),
          width: 1.5,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 250,
                  child: Text(
                    "${AppLocalizations.of(context)!.txt_date_of_delivery} : ${widget.order!.deliveryDate}, ${widget.order!.timeSlot}",
                    maxLines: 2,
                    style: textTheme.bodyLarge!.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 250,
                  child: Text(
                    '${widget.address}',
                    maxLines: 2,
                    style: textTheme.bodyLarge!.copyWith(fontSize: 14),
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
