import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircularImageCover extends StatefulWidget {
  final Color? backgroundColor;
  final String? imageUrl;
  final Icon? icon;
  const CircularImageCover({super.key, this.backgroundColor, this.imageUrl, this.icon});

  @override
  State<CircularImageCover> createState() => _CircularImageCoverState();
}

class _CircularImageCoverState extends State<CircularImageCover> {

  _CircularImageCoverState();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      child: Center(
        child: widget.imageUrl != null
            ? Padding(
                padding: const EdgeInsetsDirectional.all(12.0),
                child: SvgPicture.asset(
                  widget.imageUrl!,
                  height: 100,
                ),
              )
            : widget.icon,
      ),
    );
  }
}
