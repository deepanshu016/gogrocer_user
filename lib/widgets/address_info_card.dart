import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:user/models/address_model.dart';
import 'package:user/screens/add_address_screen.dart';

class AddressInfoCard extends StatefulWidget {
  @required
  final bool? isSelected;
  final Address? value;
  final Address? groupValue;
  final Function(Address?)? onChanged;
  final Address? address;
  final dynamic analytics;
  final dynamic observer;

  const AddressInfoCard({super.key, this.value, this.groupValue, this.isSelected, this.onChanged, this.address, this.analytics, this.observer});

  @override
  State<AddressInfoCard> createState() => _AddressInfoCardState();
}

class _AddressInfoCardState extends State<AddressInfoCard> {

  _AddressInfoCardState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    TextStyle subHeadingStyle = textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSecondaryContainer,
    );

    return Card(
      elevation: widget.isSelected! ? 5 : 0,
      color: widget.isSelected! ? Theme.of(context).colorScheme.secondaryContainer.withAlpha(100) : Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio(
                value: widget.value,
                groupValue: widget.groupValue,
                onChanged: (dynamic value) => widget.onChanged!(value),
              ),
              const SizedBox(width: 8),
              Text(
                widget.address!.type!,
                style: subHeadingStyle,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () => Get.to(() => AddAddressScreen(
                    widget.address,
                        analytics: widget.analytics,
                        observer: widget.observer,
                        screenId: 0,
                      )),
                  child: const Icon(
                    Icons.edit_outlined,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              '${widget.address!.houseNo} ${widget.address!.society} ${widget.address!.city} ${widget.address!.state} ${widget.address!.pincode}',
              style: textTheme.bodyLarge!.copyWith(fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 16,
              bottom: 16,
            ),
            child: Text(
              widget.address!.receiverPhone!,
              style: textTheme.bodySmall!.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
