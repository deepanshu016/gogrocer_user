import 'package:flutter/material.dart';

class MyChip extends StatefulWidget {
  final Function()? onPressed;
  final String? label;
  final bool? isSelected;

  const MyChip({super.key, this.onPressed, this.label, this.isSelected});
  @override
  State<MyChip> createState() => _MyChipState();
}

class _MyChipState extends State<MyChip> {

  _MyChipState();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.isSelected! ? Theme.of(context).colorScheme.primary : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: widget.isSelected! ? Theme.of(context).colorScheme.primary : Colors.white,
            width: 0.7,
          ),
        ),
      ),
      child: Text(
        widget.label!,
        style: TextStyle(
          color: widget.isSelected! ? Theme.of(context).colorScheme.onPrimary : Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
