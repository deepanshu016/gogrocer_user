import 'package:flutter/material.dart';
import 'package:user/models/businessLayer/base_route.dart';

class ImageViewScreen extends BaseRoute {
  final String? url;
  const ImageViewScreen({super.key, super.analytics, super.observer, super.routeName = 'ImageViewScreen', this.url});

  @override
  BaseRouteState<ImageViewScreen> createState() => _ImageDetilsScreenState();
}

class _ImageDetilsScreenState extends BaseRouteState<ImageViewScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isReadyToCheckOut = false;
  _ImageDetilsScreenState();

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(),
          body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(widget.url!)),
              )),
        ));
  }

}
