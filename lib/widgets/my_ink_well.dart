import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MyInkWell extends StatefulWidget {
  final String introText;
  final TextStyle? textStyle;
  final String mainText;
  final Function()? onPressed;
  const MyInkWell({super.key, 
    required this.onPressed,
    required this.introText,
    required this.mainText,
    this.textStyle,
  });

  @override
  State<MyInkWell> createState() => _MyInkWellState();
}

class _MyInkWellState extends State<MyInkWell> {

  _MyInkWellState();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        style: widget.textStyle ?? textTheme.titleLarge,
        children: [
          TextSpan(
            text: widget.introText,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: widget.mainText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTap = widget.onPressed,
          ),
        ],
      ),
    );
  }
}
