import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_polyline_points_plus/flutter_polyline_points_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:user/controllers/order_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/order_model.dart';
import 'package:user/screens/cancel_order_screen.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/home_screen.dart';
import 'package:user/widgets/bottom_button.dart';
import 'package:user/widgets/toastfile.dart';

class BezierPainter extends CustomPainter {
  final Color? color;

  final bool drawStart;
  final bool drawEnd;
  const BezierPainter({
    this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color!;

    final radius = size.width / 2;

    double angle;
    Offset offset1;
    Offset offset2;

    Path path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius, radius)
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius, radius)
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BezierPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.drawStart != drawStart || oldDelegate.drawEnd != drawEnd;
  }

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }
}

class MapScreen extends BaseRoute {
  final Order? order;
  final OrderController? orderController;
  const MapScreen(this.order, this.orderController, {super.key, super.analytics, super.observer, super.routeName = 'MapScreen'});
  @override
  BaseRouteState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends BaseRouteState<MapScreen> {
  late GoogleMapController mapController;
  final CameraPosition _initialLocation = CameraPosition(target: LatLng(global.lat!, global.lng!));

  final Completer<GoogleMapController> _controller = Completer();
  String? bicycleTime;
  String? drivingTime;
  String? trainTime;
  String? walkingTime;
  Set<Marker> markers = {};
  bool _isDataLoaded = false;
  late PolylinePoints polylinePoints;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  GlobalKey<ScaffoldState>? _scaffoldKey;

  final List<String?> _processes = [];
  int _processIndex = 0;

  Color completeColor = const Color(0xff5e6172);
  Color inProgressColor = const Color(0xff5ec792);

  Color todoColor = const Color(0xffd1d2d7);
  List<Circle> circleList = [];

  _MapScreenState() : super();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: SizedBox(
          height: height,
          width: width,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.keyboard_arrow_left)),
              centerTitle: true,
              title: Text(
                AppLocalizations.of(context)!.tle_track_order,
                style: textTheme.titleLarge,
              ),
              actions: [
                IconButton(
                    onPressed: () async {
                      await _trackOrder();
                    },
                    icon: Icon(
                      MdiIcons.syncIcon,
                    )),
              ],
            ),
            body: _isDataLoaded
                ? Stack(
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      // Map View
                      GoogleMap(
                        markers: Set<Marker>.from(markers),
                        circles: Set<Circle>.from(circleList),
                        initialCameraPosition: _initialLocation,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: true,
                        mapType: MapType.terrain,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        polylines: Set<Polyline>.of(polylines.values),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);

                          setState(() {});
                        },
                      ),

                      widget.order!.estimatedTime != null
                          ? Container(
                              padding: const EdgeInsets.all(2),
                              width: 100,
                              height: 25,
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  width: 100,
                                  height: 25,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "ETA: ${widget.order!.estimatedTime}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w400),
                                  )),
                            )
                          : const SizedBox()

                      //   showing the route
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            bottomNavigationBar: Container(
              width: width,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    height: 130,
                    child: Timeline.tileBuilder(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      theme: TimelineThemeData(
                        direction: Axis.horizontal,
                        connectorTheme: const ConnectorThemeData(
                          space: 30.0,
                          thickness: 5.0,
                        ),
                      ),
                      builder: TimelineTileBuilder.connected(
                        connectionDirection: ConnectionDirection.before,
                        itemExtentBuilder: (_, __) => MediaQuery.of(context).size.width / _processes.length,
                        contentsBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(_processes[index]!, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: getColor(index))),
                          );
                        },
                        indicatorBuilder: (_, index) {
                          Color color;
                          Widget child = Container();
                          if (index == _processIndex) {
                            color = inProgressColor;
                            child = _processes[index] == 'Completed'
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15.0,
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  );
                          } else if (index < _processIndex) {
                            color = completeColor;
                            child = const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15.0,
                            );
                          } else {
                            color = todoColor;
                          }

                          if (index <= _processIndex) {
                            return Stack(
                              children: [
                                CustomPaint(
                                  size: const Size(25.0, 25.0),
                                  painter: BezierPainter(
                                    color: color,
                                    drawStart: index > 0,
                                    drawEnd: index < _processIndex,
                                  ),
                                ),
                                DotIndicator(
                                  size: 25.0,
                                  color: color,
                                  child: child,
                                ),
                              ],
                            );
                          } else {
                            return Stack(
                              children: [
                                CustomPaint(
                                  size: const Size(15.0, 15.0),
                                  painter: BezierPainter(
                                    color: color,
                                    drawEnd: index < _processes.length - 1,
                                  ),
                                ),
                                OutlinedDotIndicator(
                                  borderWidth: 4.0,
                                  color: color,
                                ),
                              ],
                            );
                          }
                        },
                        connectorBuilder: (_, index, type) {
                          if (index > 0) {
                            if (index == _processIndex) {
                              final prevColor = getColor(index - 1);
                              final color = getColor(index);
                              List<Color?> gradientColors;
                              if (type == ConnectorType.start) {
                                gradientColors = [Color.lerp(prevColor, color, 0.5), color];
                              } else {
                                gradientColors = [prevColor, Color.lerp(prevColor, color, 0.5)];
                              }
                              return DecoratedLineConnector(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradientColors as List<Color>,
                                  ),
                                ),
                              );
                            } else {
                              return SolidLineConnector(
                                color: getColor(index),
                              );
                            }
                          } else {
                            return null;
                          }
                        },
                        itemCount: _processes.length,
                      ),
                    ),
                  ),
                  widget.order!.orderStatus == 'Out_For_Delivery'
                      ? ListTile(
                          minLeadingWidth: 2,
                          title: Text(
                            widget.order!.deliveryBoyName ?? '${AppLocalizations.of(context)!.txt_delivery_boy} ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            widget.order!.deliveryBoyPhone ?? AppLocalizations.of(context)!.txt_no_contact,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: widget.order!.deliveryBoyPhone != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          await launchCaller(widget.order!.deliveryBoyPhone);
                                        },
                                        icon: Icon(Icons.call, color: Theme.of(context).primaryColor)),
                                    IconButton(
                                      onPressed: () async {
                                        await textMe(widget.order!.deliveryBoyPhone);
                                      },
                                      icon: Icon(Icons.message_outlined, color: Theme.of(context).primaryColor),
                                    ),
                                  ],
                                )
                              : null,
                        )
                      : widget.order!.orderStatus == 'Pending' || widget.order!.orderStatus == 'Confirmed' || widget.order!.orderStatus == 'Completed'
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BottomButton(
                                loadingState: false,
                                disabledState: false,
                                onPressed: () async {
                                  if (widget.order!.orderStatus == 'Pending' || widget.order!.orderStatus == 'Confirmed') {
                                    Get.to(() => CancelOrderScreen(
                                          analytics: widget.analytics,
                                          observer: widget.observer,
                                          order: widget.order,
                                          orderController: widget.orderController,
                                        ));
                                  } else {
                                    // reorder
                                    await _reOrderItems();
                                  }
                                },
                                child: Text(widget.order!.orderStatus == 'Pending' || widget.order!.orderStatus == 'Confirmed' ? AppLocalizations.of(context)!.tle_cancel_order : AppLocalizations.of(context)!.btn_re_order),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                gradient: LinearGradient(
                                  stops: const [0, .90],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                                ),
                              ),
                              margin: const EdgeInsets.all(8.0),
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              child: TextButton(
                                  onPressed: () async {
                                    Get.to(() => HomeScreen(
                                          analytics: widget.analytics,
                                          observer: widget.observer,
                                        ));
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.btn_browse_more,
                                  )),
                            )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/images/scooter.png");
    return byteData.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();

    if (widget.order!.orderStatus == "Cancelled") {
      _processes.add('Placed');
      _processes.add('Cancelled');
    } else {
      _processes.add('Placed');
      _processes.add('Confirmed');
      _processes.add('Out_For_Delivery');
      _processes.add('Completed');
    }

    updateMarker();
    _processIndex = _processes.indexOf(widget.order!.orderStatus);
    _init();
  }

  launchCaller(String? phone) async {
    String url = "tel:$phone";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  textMe(String? phone) async {
    // Android
    String uri = 'sms:$phone?body=hello%20there';
    if (await canLaunchUrlString(uri)) {
      await launchUrlString(uri);
    } else {
      // iOS
      String uri = 'sms:$phone?body=hello%20there';
      if (await canLaunchUrlString(uri)) {
        await launchUrlString(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  Future<bool> updateMarker() async {
    try {
      if (markers.isNotEmpty) markers.clear();
      if (polylines.isNotEmpty) polylines.clear();
      if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();

      double startLatitude = widget.order!.storeLat!;
      double startLongitude = widget.order!.storeLng!;

      String destinationCoordinatesString = '(${widget.order!.userLat}, ${widget.order!.userLng})';
      String startCoordinatesString = '($startLatitude, $startLongitude)';

      // Start - Store Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(180),
      );
      mapController = await _controller.future;

      // Desitination - user  Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(widget.order!.userLat!, widget.order!.userLng!),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(startMarker);

      if (widget.order!.currentLng != null && widget.order!.currentLat != null) {
        markers.add(
          Marker(
            markerId: const MarkerId("home"),
            position: LatLng(double.parse(widget.order!.currentLat!), double.parse(widget.order!.currentLng!)),
            draggable: false,
            zIndex: 2,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            icon: BitmapDescriptor.bytes(
              await getMarker(),
            ),
          ),
        );
        circleList.add(
          Circle(
            circleId: const CircleId("car"),
            zIndex: 1,
            strokeColor: Colors.blue,
            center: LatLng(double.parse(widget.order!.currentLat!), double.parse(widget.order!.currentLng!)),
            fillColor: Colors.blue.withAlpha(70),
          ),
        );
      }
      markers.add(destinationMarker);

      double miny = (widget.order!.userLat! <= startLatitude) ? widget.order!.userLat! : startLatitude;
      double minx = (widget.order!.userLng! <= startLongitude) ? widget.order!.userLng! : startLongitude;
      double maxy = (widget.order!.userLat! <= startLatitude) ? startLatitude : widget.order!.userLat!;
      double maxx = (widget.order!.userLng! <= startLongitude) ? startLongitude : widget.order!.userLng!;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;
      Future.value(markers);
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          50.0,
        ),
      );

      try {
        await _createPolylines(widget.order!.userLat!, widget.order!.userLng!, startLatitude, startLongitude);
      } catch (e) {
        debugPrint("MAP Exeption - map_screen.dart - updateMarker() - _createPolylines$e");
      }

      return true;
    } catch (e) {
      debugPrint('MAP Exception - map_screen.dart - updateMarker():$e');
    }
    return false;
  }

  _createPolylines(double startLatitude, double startLongitude, double destinationLatitude, double destinationLongitude) async {
    try {
      polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        global.googleMap!.mapApiKey!, //Google Maps API Key

        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      PolylineId id = const PolylineId('poly1');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );
      polylines[id] = polyline;
      setState(() {});
    } catch (e) {
      debugPrint("MAP Exception - map_screen.dart - _createPolylines():$e");
    }
  }

  _init() async {
    try {
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("MAP Exception - map_screen.dart - _init():$e");
    }
  }

  // Create the polylines for showing the route between two places
  _reOrderItems() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
      await apiHelper.reOrder(widget.order!.cartid).then((result) async {
        if (result != null) {
          if(!mounted) return;
          if (result.status == "1") {
            Navigator.of(context).pop();
            Get.to(() => CartScreen(
                  analytics: widget.analytics,
                  observer: widget.observer,
                ));
          } else {
            Navigator.of(context).pop();
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content: Text(
            //     '${AppLocalizations.of(context).txt_something_went_wrong}.',
            //     textAlign: TextAlign.center,
            //   ),
            //   duration: Duration(seconds: 2),
            // ));
            showToast(AppLocalizations.of(context)!.txt_something_went_wrong);
          }
        }
      });
      setState(() {});
    } catch (e) {
      debugPrint("Exception -  map_screen.dart - reOrderItems():$e");
    }
  }

  _trackOrder() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.trackOrder(widget.order!.cartid).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              Order? tOrder = Order();
              tOrder = result.data;
              hideLoader();
              Get.to(() => MapScreen(
                    tOrder,
                widget.orderController,
                    analytics: widget.analytics,
                    observer: widget.observer,
                  ));
            } else {
              hideLoader();
              showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - map_screen.dart - _trackOrder(): $e");
    }
  }
}
