import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart' as mapbox_autocomplete;
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/businessLayer/place_service.dart';
import 'package:user/models/nearby_store_model.dart';
import 'package:user/screens/google_address_search_screen.dart';
import 'package:mapbox_search/mapbox_search.dart' as mapbox_search;
import 'package:uuid/uuid.dart';

class LocationScreen extends BaseRoute {
  final int? screenId;
  const LocationScreen({super.key, super.analytics, super.observer, super.routeName = 'LocationScreen', this.screenId});
  @override
  BaseRouteState createState() => _LocationScreenState();
}

class _LocationScreenState extends BaseRouteState {

  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  double? _lat;
  double? _lng;
  final TextEditingController _cSearch = TextEditingController();

  final FocusNode _fSearch = FocusNode();
  bool _isDataLoaded = false;
  bool _isShowConfirmLocationWidget = false;
  late Placemark setPlace;

  _LocationScreenState();

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
              elevation: 2,
              leading: InkWell(
                onTap: () async {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                ),
              ),
              automaticallyImplyLeading: false,
              title: TextFormField(
                textAlign: TextAlign.start,
                autofocus: false,
                cursorColor: const Color(0xFFFA692C),
                enabled: true,
                readOnly: true,
                style: Theme.of(context).textTheme.titleMedium,
                controller: _cSearch,
                focusNode: _fSearch,
                onFieldSubmitted: (text) async {},
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 14),
                  border: const UnderlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  hintText: global.currentLocation ?? ' ${AppLocalizations.of(context)!.txt_no_location_selected}',
                ),
                onTap: () async {
                  if (global.mapby != null) {
                    if (global.mapby!.mapbox == 1) {
                      // search through map box
                      Navigator.push(context, MaterialPageRoute(builder: (context) => searchLocation()));
                    } else {
                      // search to google map api

                      final sessionToken = const Uuid().v4();
                      final Suggestion? result = await showSearch<Suggestion?>(
                        context: context,
                        delegate: AddressSearch(sessionToken),
                      );
                      if (result != null) {
                        if (result.description != null) {
                          _cSearch.text = result.description ?? '';
                          String latlng = await getLocationFromAddress(
                              result.description!) ?? '';
                          debugPrint('ℹ️ latlng: $latlng');
                          List<String> tList = latlng.split("|");

                          _lat = double.parse(tList[0]).toDouble();
                          _lng = double.parse(tList[1]).toDouble();
                          showOnlyLoaderDialog();
                          final GoogleMapController controller = await _controller
                              .future;
                          await controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                  CameraPosition(target: LatLng(_lat!, _lng!),
                                      tilt: 59.440717697143555,
                                      zoom: 15)));
                          await _updateMarker(_lat, _lng).then((_) async {
                            List<
                                Placemark> placemarks = await placemarkFromCoordinates(
                                _lat!, _lng!);
                            setPlace = placemarks[0];
                            hideLoader();
                            _isShowConfirmLocationWidget = true;
                            setState(() {});
                          });
                          setState(() {});
                        }
                      }
                    }
                  }
                },
              )),
          body: _isDataLoaded
              ? Stack(
                  children: [
                    GoogleMap(
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_lat!, _lng!),
                        zoom: 15,
                      ),
                      myLocationButtonEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        setState(() {});
                      },
                      markers: Set<Marker>.from(markers),
                      onTap: (latLng) async {
                        _lat = latLng.latitude;
                        _lng = latLng.longitude;
                        final GoogleMapController controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_lat!, _lng!), tilt: 59.440717697143555, zoom: 15)));
                        await _updateMarker(_lat, _lng).then((value) async {
                          List<Placemark> placemarks = await placemarkFromCoordinates(_lat!, _lng!);
                          setPlace = placemarks[0];
                          _isShowConfirmLocationWidget = true;
                          setState(() {});
                        });
                        setState(() {});
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25, left: 8, right: 8),
                      child: Align(alignment: Alignment.bottomCenter, child: SizedBox(child: _isShowConfirmLocationWidget ? _setCurrentLocationWidget() : const SizedBox())),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }


  @override
  void initState() {
    super.initState();

    _init();
  }

  searchLocation() {
    try {
      return mapbox_autocomplete.MapBoxAutoCompleteWidget(
        apiKey: global.mapBox!.mapApiKey!,
        hint: '${AppLocalizations.of(context)!.txt_type_here} ',
        onSelect: (place) async {
          _cSearch.text = place.placeName!;
          Location location = await (_placesSearch(_cSearch.text) as FutureOr<Location>);
          _lat = location.latitude;
          _lng = location.longitude;
          showOnlyLoaderDialog();
          final GoogleMapController controller = await _controller.future;
          await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_lat!, _lng!), tilt: 59.440717697143555, zoom: 15)));
          await _updateMarker(_lat, _lng).then((_) async {
            List<Placemark> placemarks = await placemarkFromCoordinates(_lat!, _lng!);
            setPlace = placemarks[0];
            hideLoader();
            _isShowConfirmLocationWidget = true;
            setState(() {});
          });
          setState(() {});
        },
        limit: 5,
        // country: "IN",
      );
    } catch (e) {
      debugPrint("Exception - location_screen.dart - searchLocation():$e");
    }
  }

  _getNearByStore() async {
    try {
      await apiHelper.getNearbyStore().then((result) async {
        debugPrint('new data');
        debugPrint(result.status);
        if (result != null) {
          if ('${result.status}' == '1') {
            global.nearStoreModel = result.data;
            global.sp!.setString("lastloc", '${global.lat}|${global.lng}');
            if (global.currentUser!.id != null) {
              await global.userProfileController.getUserAddressList();
            }
            Get.back();
          } else if ('${result.status}' == '0') {
            debugPrint('in');
            global.nearStoreModel = NearStoreModel();
            global.locationMessage = result.message;
            _noStoresAvailableDialog();
          }
        }
      });
    } catch (e) {
      debugPrint("Exception t - location_screen.dart - _getNearByStore():$e");
    }
  }

  _init() async {
    try {
      _lat = global.lat;
      _lng = global.lng;
      _isDataLoaded = true;
      await _updateMarker(_lat, _lng);

      setState(() {});
    } catch (e) {
      debugPrint("Exception - location_screen.dart - _init():$e");
    }
  }

  _noStoresAvailableDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            content: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                AppLocalizations.of(context)!.lbl_no_store_at_loc_msg,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.btn_search_another_location)),
              global.sp!.getString('lastloc') != null
                  ? TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        if (global.sp!.getString('lastloc') != null) {
                          List<String> tlist = global.sp!.getString('lastloc')!.split("|");
                          global.lat = double.parse(tlist[0]);
                          global.lng = double.parse(tlist[1]);
                        }

                        final GoogleMapController controller = await _controller.future;
                        await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(global.lat!, global.lng!), tilt: 59.440717697143555, zoom: 15)));
                        await _updateMarker(global.lat, global.lng).then((value) async {
                          List<Placemark> placemarks = await placemarkFromCoordinates(global.lat!, global.lng!);
                          setPlace = placemarks[0];
                          setState(() {});
                        });
                        global.currentLocation = "${setPlace.name}, ${setPlace.locality} ";
                        await _getNearByStore();
                      },
                      child: Text(AppLocalizations.of(context)!.btn_continue_with_default_location))
                  : const SizedBox()
            ],
          );
        });
  }

  Future<Location?> _placesSearch(String searchText) async {
    try {
      var placesService = mapbox_search.PlacesSearch(
        apiKey: global.mapBox!.mapApiKey!,
        // country: "IN",
        limit: 1,
      );
      var places = await (placesService.getPlaces(
        searchText,
      ) as FutureOr<List<mapbox_search.MapBoxPlace>>);
      List<Location> location = await locationFromAddress(places[0].toString());
      return location[0];
    } catch (e) {
      debugPrint('Exception - location_screen.dart - _placesSearch(): $e');
      return null;
    }
  }

  _setCurrentLocationWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppLocalizations.of(context)!.txt_select_location} ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    '${setPlace.name}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Align(alignment: Alignment.centerLeft, child: Text("${setPlace.name!.trim()}, ${setPlace.locality}, ${setPlace.street}, ${setPlace.subAdministrativeArea}, ${setPlace.postalCode}")),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: FilledButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.btn_confirm_location),
                ),
                onPressed: () async {
                  _isShowConfirmLocationWidget = false;
                  global.lat = _lat;
                  global.lng = _lng;
                  global.currentLocation = "${setPlace.name}, ${setPlace.locality} ";
                  await _getNearByStore();

                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _updateMarker(lat, lng) async {
    try {
      if (markers.isNotEmpty) markers.clear();
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks[0];
      String startCoordinatesString = '($lat, $lng)';
      Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: '${place.name}, ${place.locality} ',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(0),
          onTap: () async {
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(lat, lng),
                  tilt: 50.0,
                  bearing: 45.0,
                  zoom: 20.0,
                ),
              ),
            );
          });
      mapController = await _controller.future;
      markers.add(startMarker);

      return true;
    } catch (e) {
      debugPrint('MAP Exception - location_screen.dart - _updateMarker():$e');
    }
    return false;
  }
}
