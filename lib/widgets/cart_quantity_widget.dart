import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final class CartQuantityWidget extends StatelessWidget {
  final int? quantity;
  final VoidCallback? addTapped;
  final VoidCallback? deleteTapped;

  const CartQuantityWidget({
    super.key,
    required this.quantity,
    required this.addTapped,
    required this.deleteTapped
  });

  @override
  Widget build(BuildContext context) {
    if(quantity == null || quantity == 0) {
      return IconButton.filledTonal(onPressed: addTapped, icon: const Icon(Icons.add));
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            IconButton.filledTonal(
                onPressed: deleteTapped,
                icon: Icon(MdiIcons.minus)
            ),
            Container(
              height: 23,
              width: 23,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5.0)
                )
              ),
              child: Center(
                child: Text(quantity.toString()),
              ),
            ),
            IconButton.filledTonal(onPressed: addTapped, icon: const Icon(Icons.add))
          ],
        ),
      );
    }
  }
}