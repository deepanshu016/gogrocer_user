import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/rate_model.dart';

class RatingListScreen extends BaseRoute {
  final int? variantId;
  const RatingListScreen(this.variantId, {super.key, super.analytics, super.observer, super.routeName = 'RatingListScreen'});
  @override
  BaseRouteState<RatingListScreen> createState() => _RatingListScreenState();
}

class _RatingListScreenState extends BaseRouteState<RatingListScreen> {
  final List<Rate> _ratingList = [];
  bool _isDataLoaded = false;
  int page = 1;
  bool _isRecordPending = true;
  bool _isMoreDataLoaded = false;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  final ScrollController _scrollController = ScrollController();

  _RatingListScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Align(
              alignment: Alignment.center,
              child: Icon(MdiIcons.arrowLeft),
            ),
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.tle_product_rating,
            style: textTheme.titleLarge,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: RefreshIndicator(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              _isDataLoaded = false;
              _isRecordPending = true;
              _ratingList.clear();
              setState(() {});
              await _init();
            },
            child: _isDataLoaded
                ? _ratingList.isNotEmpty
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _ratingList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Text(
                                        _ratingList[index].userName!,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      subtitle: Text('${_ratingList[index].description}', style: Theme.of(context).textTheme.bodyLarge),
                                      trailing: RatingBar.builder(
                                        initialRating: _ratingList[index].rating!,
                                        minRating: 0,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 25,
                                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        ignoreGestures: true,
                                        updateOnDrag: false,
                                        onRatingUpdate: (val) {},
                                        tapOnlyMode: false,
                                      ),
                                    ),
                                    Divider(
                                      color: Theme.of(context).dividerTheme.color,
                                    ),
                                  ],
                                );
                              },
                            ),
                            _isMoreDataLoaded
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          AppLocalizations.of(context)!.txt_nothing_to_show,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                : _shimmerWidget(),
          ),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  _getData() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_isRecordPending) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          if (_ratingList.isEmpty) {
            page = 1;
          } else {
            page++;
          }
          await apiHelper.getProductRating(page, widget.variantId).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                List<Rate> tList = result.data;
                if (tList.isEmpty) {
                  _isRecordPending = false;
                }
                _ratingList.addAll(tList);
                setState(() {
                  _isMoreDataLoaded = false;
                });
              }
            }
          });
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - RatingListScreen.dart - _getData():$e");
    }
  }

  _init() async {
    try {
      await _getData();
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isMoreDataLoaded) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          await _getData();
          setState(() {
            _isMoreDataLoaded = false;
          });
        }
      });
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - RatingListScreen.dart - _init():$e");
    }
  }

  Widget _shimmerWidget() {
    try {
      return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                  Divider(
                    color: Theme.of(context).dividerTheme.color,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - RatingListScreen.dart - _shimmerWidget():$e");
      return const SizedBox();
    }
  }
}
