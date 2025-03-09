import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:user/models/businessLayer/base.dart';

class BaseRoute extends Base {
  const BaseRoute({super.key, super.analytics, super.observer, super.routeName});

  @override
  BaseRouteState createState() => BaseRouteState();
}

class BaseRouteState<T extends BaseRoute> extends BaseState<T> with RouteAware {
  BaseRouteState() : super();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.observer?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _setCurrentScreen();
    _sendAnalyticsEvent();
  }

  @override
  void didPush() {
    _setCurrentScreen();
    _sendAnalyticsEvent();
  }

  @override
  void dispose() {
    widget.observer!.unsubscribe(this);
    super.dispose();
  }

  Future<String?> getLocationFromAddress(String address) async {
    try {
      List<Location> locationList = await locationFromAddress(address);
      return '${locationList[0].latitude}|${locationList[0].longitude}';
    } catch (e) {
      debugPrint("Exception -  base.dart - getLocationFromAddress():$e");
      return null;
    }
  }

  @override
  void hideLoader() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _setCurrentScreen();
    _sendAnalyticsEvent();
  }

  Future<void> _sendAnalyticsEvent() async {
    await widget.observer!.analytics.logEvent(
      name: widget.routeName!,
      parameters: <String, dynamic>{},
    );
  }

  Future<void> _setCurrentScreen() async {
    await widget.observer!.analytics.logScreenView(
      screenName: widget.routeName,
      screenClass: widget.routeName!,
    );
  }
}
