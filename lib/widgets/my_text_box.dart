import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user/theme/style.dart';

class MyTextBox extends StatefulWidget {
  // Hint text for text field
  final String? hintText;

  // Callback functions
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Function? onEditingComplete;
  final Function(String?)? onSaved;

  // Other properties
  final TextInputType? keyboardType;
  final double? height;
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final Function()? onTap;
  final String? initialText;
  final bool? readOnly;
  final int? maxLines;
  final TextCapitalization? textCapitalization;
  final bool? autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;

  // Constructor of text field
  const MyTextBox({
    super.key,
    this.onSaved,
    this.onTap,
    this.prefixIcon,
    this.textCapitalization,
    this.maxLines,
    this.onEditingComplete,
    this.controller,
    this.height,
    this.readOnly,
    this.suffixIcon,
    this.initialText,
    this.inputFormatters,
    this.onChanged,
    this.hintText,
    this.keyboardType,
    this.autofocus,
    this.obscureText,
    this.onFieldSubmitted
  });

  @override
  State<MyTextBox> createState() => _MyTextBoxState();
}

class _MyTextBoxState extends State<MyTextBox> {

  // Constructor of text field
  _MyTextBoxState();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        cursorColor: Colors.grey[800],
        controller: widget.controller,
        style: textFieldHintStyle(context),
        keyboardType: widget.keyboardType ?? TextInputType.text,
        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
        obscureText: widget.obscureText ?? false,
        autofocus: widget.autofocus ?? false,
        readOnly: widget.readOnly ?? false,
        maxLines: widget.maxLines ?? 1,
        initialValue: widget.initialText,
        onTap: widget.onTap,
        inputFormatters: widget.inputFormatters ?? [],
        decoration: InputDecoration(
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.secondary, style: BorderStyle.none),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.secondary, style: BorderStyle.none),
          ),
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          hintStyle: textFieldHintStyle(context),
          contentPadding: const EdgeInsets.only(bottom: 12.0),
        ),
        onSaved: (value) => widget.onSaved!(value),
        onEditingComplete: () => widget.onEditingComplete!(),
        onFieldSubmitted: widget.onFieldSubmitted != null ? (val) => val != "" ? widget.onFieldSubmitted!(val) : null : null,
        onChanged: widget.onChanged != null ? (value) => widget.onChanged!(value) : null,
      ),
    );
  }
}
