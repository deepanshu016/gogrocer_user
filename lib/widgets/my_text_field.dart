import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user/theme/style.dart';

class MyTextField extends StatefulWidget {
  // Hint text for text field
  final String? hintText;
  // Callback functions
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final Function(String)? onFieldSubmitted;

  // Other properties
  final TextInputType? keyboardType;
  final double? height;
  final String? prefixText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Icon? prefixIcon;
  final FontWeight? inputTextFontWeight;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Function? onTap;
  final String? initialText;
  final bool? readOnly;
  final int? maxLines;
  final int? maxlength;
  final TextCapitalization? textCapitalization;
  final bool? autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;
  final String? obscuringCharacter;

  // Constructor of text field
  const MyTextField({
    super.key,
    this.onSaved,
    this.inputTextFontWeight,
    this.onTap,
    this.prefixText,
    this.prefixIcon,
    this.textCapitalization,
    this.maxLines,
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
    this.maxlength,
    this.focusNode,
    this.onFieldSubmitted,
    this.obscuringCharacter,
    this.suffix
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool? _obscureText;

  _MyTextFieldState();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: widget.controller,
      style: textFieldInputStyle(context, widget.inputTextFontWeight),
      keyboardType: widget.keyboardType ?? TextInputType.text,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      obscureText: _obscureText!,
      autofocus: widget.autofocus ?? false,
      readOnly: widget.readOnly ?? false,
      maxLines: widget.maxLines ?? 1,
      initialValue: widget.initialText,
      maxLength: widget.maxlength,
      onTap: widget.onTap as void Function()?,
      focusNode: widget.focusNode,
      obscuringCharacter: '*',
      inputFormatters: widget.inputFormatters ?? [],
      decoration: InputDecoration(
        suffix: widget.suffix,
        prefixText: widget.prefixText,
        prefixStyle: textFieldInputStyle(context, widget.inputTextFontWeight),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
            color: Colors.black,
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 0.7,
            color: Colors.black,
          ),
        ),
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        hintStyle: textFieldHintStyle(context),
      ),
      onFieldSubmitted: widget.onFieldSubmitted != null ? (val) => widget.onFieldSubmitted!(val) : null,
      onChanged: widget.onChanged != null ? (value) => widget.onChanged!(value) : null,
      onSaved: (value) => widget.onSaved!(value),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.obscureText != null) {
      _obscureText = widget.obscureText;
    } else {
      _obscureText = false;
    }
  }
}
